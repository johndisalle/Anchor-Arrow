#!/usr/bin/env python3
"""
generate_audio.py — Generate the full Anchor & Arrow audio library.

Parses the actual Anchor & Arrow Swift source files to extract text,
calls ElevenLabs to generate MP3s, and uploads them to Firebase Storage
at the paths AudioService expects.

SETUP (one-time, on your Mac):
  pip install elevenlabs firebase-admin python-dotenv

  Create .env in the same folder as this script:
    ELEVENLABS_API_KEY=your_key
    ELEVENLABS_VOICE_ID=pNInz6obpgDQGcFmaJgB
    FIREBASE_BUCKET=anchorarrow-4efa7.appspot.com
    FIREBASE_CREDENTIALS=./firebase-admin-key.json

  Download the Firebase Admin SDK key:
    Firebase Console > Project Settings > Service Accounts > Generate Private Key
    Save as firebase-admin-key.json in this folder.

  Add .env and firebase-admin-key.json to .gitignore.

USAGE:
  python3 generate_audio.py --dry-run                    # show plan + cost
  python3 generate_audio.py --only prayers --dry-run     # plan one category
  python3 generate_audio.py --only prayers               # generate one category
  python3 generate_audio.py                              # generate everything
  python3 generate_audio.py --resume                     # skip existing files
  python3 generate_audio.py --limit 5                    # first 5 files only (smoke test)

SCOPES (use with --only):
  anchor_scripture, anchor_prompts, morning_prayers,
  arrow_scripture, arrow_prompts, evening_prayers, journeys
"""

import argparse
import json
import os
import re
import sys
import time
from pathlib import Path

from dotenv import load_dotenv
from elevenlabs.client import ElevenLabs
import firebase_admin
from firebase_admin import credentials, storage

load_dotenv()

API_KEY = os.getenv("ELEVENLABS_API_KEY")
VOICE_ID = os.getenv("ELEVENLABS_VOICE_ID", "pNInz6obpgDQGcFmaJgB")
BUCKET = os.getenv("FIREBASE_BUCKET")
CREDS = os.getenv("FIREBASE_CREDENTIALS")

MODEL = "eleven_multilingual_v2"
OUTPUT_FORMAT = "mp3_44100_128"
VOICE_SETTINGS = {
    "stability": 0.6,
    "similarity_boost": 0.75,
    "style": 0.3,
    "use_speaker_boost": True,
}

# Resolve project root relative to this script.
# Script lives at <repo>/generator/generate_audio.py
# Models are at <repo>/AnchorArrow/AnchorArrow/Models/
ROOT = Path(__file__).resolve().parent.parent / "AnchorArrow" / "AnchorArrow" / "Models"

# =============================================================================
# Parsing
# =============================================================================

JOURNEY_SERIES_SLUGS = {
    "standFirm":         "stand_firm",
    "armorOfGod":        "armor_of_god",
    "surrenderFirst":    "surrender_first",
    "prophetPriestKing": "prophet_priest_king",
    "strengthInLove":    "strength_in_love",
    "guardTheGates":     "guard_the_gates",
    "theFathersHeart":   "the_fathers_heart",
    "warriorMindset":    "warrior_mindset",
    "theNarrowRoad":     "the_narrow_road",
    "rootedAndBuilt":    "rooted_and_built",
    "forgedInFire":      "forged_in_fire",
    "theSentLife":       "the_sent_life",
}


def read(name):
    p = ROOT / name
    if not p.exists():
        raise FileNotFoundError(f"Missing expected file: {p}")
    return p.read_text()


def parse_anchor_prompts():
    """Returns [{id, scripture, reference, question}] from all 200 prompts."""
    results = []

    # Format 1: struct initializer in Prompts.swift (first 10 with id "anchor_XXX")
    text = read("Prompts.swift")
    for m in re.finditer(
        r'AnchorPrompt\(\s*'
        r'id:\s*"(?P<id>[^"]+)"\s*,\s*'
        r'theme:[^,]+,\s*'
        r'scripture:\s*"(?P<scripture>[^"]+)"\s*,\s*'
        r'reference:\s*"(?P<reference>[^"]+)"\s*,\s*'
        r'reflectionQuestion:\s*"(?P<q>[^"]+)"',
        text, re.MULTILINE
    ):
        results.append(m.groupdict())

    # Format 2: tuples in PromptLibrary+Extended.swift (190 with id "xa_XXX")
    text = read("PromptLibrary+Extended.swift")
    for m in re.finditer(
        r'\(\s*'
        r'"(?P<id>xa_\d+)"\s*,\s*'
        r'\.\w+\s*,\s*'
        r'"(?P<scripture>[^"]+)"\s*,\s*'
        r'"(?P<reference>[^"]+)"\s*,\s*'
        r'"(?P<q>[^"]+)"\s*,\s*'
        r'"[^"]*"\s*\)',
        text
    ):
        results.append({"id": m["id"], "scripture": m["scripture"],
                        "reference": m["reference"], "q": m["q"]})
    return results


def parse_arrow_prompts():
    """Returns [{id, question, verseReference}] from all 200 arrow prompts."""
    results = []

    # Format 1: struct init (first 7 with id "arrow_XXX")
    text = read("Prompts.swift")
    for m in re.finditer(
        r'ArrowPrompt\(\s*'
        r'id:\s*"(?P<id>[^"]+)"\s*,\s*'
        r'role:[^,]+,\s*'
        r'question:\s*"(?P<q>[^"]+)"\s*,\s*'
        r'example:\s*"[^"]*"\s*,\s*'
        r'verseReference:\s*"(?P<ref>[^"]+)"',
        text, re.MULTILINE
    ):
        results.append(m.groupdict())

    # Format 2: tuples with id "xr_XXX"
    text = read("PromptLibrary+Extended.swift")
    for m in re.finditer(
        r'\(\s*'
        r'"(?P<id>xr_\d+)"\s*,\s*'
        r'\.\w+\s*,\s*'
        r'"(?P<q>[^"]+)"\s*,\s*'
        r'"[^"]*"\s*,\s*'
        r'"(?P<ref>[^"]+)"\s*\)',
        text
    ):
        results.append({"id": m["id"], "q": m["q"], "ref": m["ref"]})
    return results


def parse_prayers(which):
    """Returns a list of prayer strings. which='morning'|'evening'."""
    text = read("PrayerLibrary.swift")
    if which == "morning":
        start = text.index("static let morningPrayers")
        end = text.index("static let eveningPrayers")
        block = text[start:end]
    else:
        start = text.index("static let eveningPrayers")
        # Slice until the closing bracket of that array
        block = text[start:]
    # Extract quoted strings (these arrays hold raw strings, not structs)
    # Stop at the first `]` that's at proper indentation
    prayers = re.findall(r'^\s*"((?:[^"\\]|\\.)+)"\s*,?\s*$', block, re.MULTILINE)
    return prayers


def parse_journeys():
    """Returns [{series, day, devotional, anchor, arrow}] for all 360 journey days.

    Journey data lives in two places:
    - Prompts.swift: journeys 1-6 as private funcs like standFirmJourneyDays()
    - JourneyLibrary.swift: journeys 7-12 as theFathersHeartDays() etc.

    Format is the same: DayData(week: N, theme: "...", scripture: "...",
                                  devotional: "...", anchor: "...", arrow: "...")
    """
    results = []

    # Maps the private func/struct method name to the series slug used in paths
    func_to_slug = {
        "standFirmJourneyDays":         "stand_firm",
        "armorOfGodJourneyDays":        "armor_of_god",
        "surrenderFirstJourneyDays":    "surrender_first",
        "prophetPriestKingJourneyDays": "prophet_priest_king",
        "strengthInLoveJourneyDays":    "strength_in_love",
        "guardTheGatesJourneyDays":     "guard_the_gates",
        "theFathersHeartDays":          "the_fathers_heart",
        "warriorMindsetDays":           "warrior_mindset",
        "theNarrowRoadDays":            "the_narrow_road",
        "rootedAndBuiltDays":           "rooted_and_built",
        "forgedInFireDays":             "forged_in_fire",
        "theSentLifeDays":              "the_sent_life",
    }

    for filename in ("Prompts.swift", "JourneyLibrary.swift"):
        text = read(filename)
        for func_name, slug in func_to_slug.items():
            # Find the function body
            func_match = re.search(
                rf'func\s+{func_name}\s*\(\s*\)\s*->\s*\[JourneyDay\]\s*\{{',
                text
            )
            if not func_match:
                continue
            body_start = func_match.end()
            # Find matching closing brace by counting
            depth = 1
            i = body_start
            while i < len(text) and depth > 0:
                if text[i] == '{': depth += 1
                elif text[i] == '}': depth -= 1
                i += 1
            body = text[body_start:i]

            # Extract each DayData(...) — multi-line, quotes may contain escaped chars
            day_num = 0
            # We match non-greedy, multi-line. Each DayData has 6 fields in order.
            pattern = re.compile(
                r'DayData\(\s*'
                r'week:\s*(?P<week>\d+)\s*,\s*'
                r'theme:\s*"(?P<theme>(?:[^"\\]|\\.)*)"\s*,\s*'
                r'scripture:\s*"(?P<scripture>(?:[^"\\]|\\.)*)"\s*,\s*'
                r'devotional:\s*"(?P<devotional>(?:[^"\\]|\\.)*)"\s*,\s*'
                r'anchor:\s*"(?P<anchor>(?:[^"\\]|\\.)*)"\s*,\s*'
                r'arrow:\s*"(?P<arrow>(?:[^"\\]|\\.)*)"\s*\)',
                re.DOTALL
            )
            for m in pattern.finditer(body):
                day_num += 1
                if day_num > 30:
                    break  # cap: some journeys have data for days 31+ that the app ignores
                results.append({
                    "series": slug,
                    "day": day_num,
                    "devotional": m["devotional"].replace('\\"', '"').replace("\\n", " "),
                    "anchor": m["anchor"].replace('\\"', '"').replace("\\n", " "),
                    "arrow": m["arrow"].replace('\\"', '"').replace("\\n", " "),
                })
    return results


# =============================================================================
# Job building
# =============================================================================

def build_job_list(only):
    """Return list of (scope, storage_path, text) tuples."""
    jobs = []

    if not only or "anchor_scripture" in only:
        for p in parse_anchor_prompts():
            text = f'{p["scripture"]} — {p["reference"]}'
            jobs.append(("anchor_scripture",
                         f'audio/anchor/scripture/{p["id"]}.mp3',
                         text))

    if not only or "anchor_prompts" in only:
        for p in parse_anchor_prompts():
            jobs.append(("anchor_prompts",
                         f'audio/anchor/prompts/{p["id"]}.mp3',
                         p["q"]))

    if not only or "morning_prayers" in only:
        for i, prayer in enumerate(parse_prayers("morning")):
            jobs.append(("morning_prayers",
                         f"audio/anchor/prayers/morning_{i+1:03d}.mp3",
                         prayer))

    if not only or "arrow_scripture" in only:
        for p in parse_arrow_prompts():
            # Arrow "scripture" is just the verse reference — it rotates
            # but there's no separate scripture text field.
            # Use the prompt question prefix + reference (matches what the app
            # displays on the scripture chip).
            text = f'{p["q"]} — {p["ref"]}'
            jobs.append(("arrow_scripture",
                         f'audio/arrow/scripture/{p["id"]}.mp3',
                         text))

    if not only or "arrow_prompts" in only:
        for p in parse_arrow_prompts():
            jobs.append(("arrow_prompts",
                         f'audio/arrow/prompts/{p["id"]}.mp3',
                         p["q"]))

    if not only or "evening_prayers" in only:
        for i, prayer in enumerate(parse_prayers("evening")):
            jobs.append(("evening_prayers",
                         f"audio/arrow/prayers/evening_{i+1:03d}.mp3",
                         prayer))

    if not only or "journeys" in only:
        for j in parse_journeys():
            base = f'audio/journey/{j["series"]}/day_{j["day"]:02d}'
            jobs.append(("journeys", f"{base}_devotional.mp3", j["devotional"]))
            jobs.append(("journeys", f"{base}_anchor.mp3", j["anchor"]))
            jobs.append(("journeys", f"{base}_arrow.mp3", j["arrow"]))

    return jobs


def estimate(jobs):
    chars = sum(len(t) for _, _, t in jobs)
    cost = chars * 0.00020
    return chars, cost


def summarize(jobs):
    by_scope = {}
    for scope, _, text in jobs:
        b = by_scope.setdefault(scope, [0, 0])
        b[0] += 1
        b[1] += len(text)
    for scope, (n, c) in by_scope.items():
        print(f"  {scope:22s} {n:4d} files   {c:>8,} chars")


# =============================================================================
# Generation
# =============================================================================

def generate(jobs, resume=False, limit=None):
    missing = [k for k, v in [("ELEVENLABS_API_KEY", API_KEY),
                              ("FIREBASE_BUCKET", BUCKET),
                              ("FIREBASE_CREDENTIALS", CREDS)] if not v]
    if missing:
        print(f"ERROR: Missing env vars: {missing}. Check .env file.")
        sys.exit(1)

    cred = credentials.Certificate(CREDS)
    firebase_admin.initialize_app(cred, {"storageBucket": BUCKET})
    bucket = storage.bucket()
    client = ElevenLabs(api_key=API_KEY)

    if resume:
        before = len(jobs)
        jobs = [j for j in jobs if not bucket.blob(j[1]).exists()]
        print(f"Resume: skipped {before - len(jobs)} existing files.\n")

    if limit:
        jobs = jobs[:limit]
        print(f"Limit: generating first {limit} files only.\n")

    failed = []
    for i, (scope, path, text) in enumerate(jobs, 1):
        print(f"[{i}/{len(jobs)}] {path}  ({len(text)} chars)")
        try:
            audio = b"".join(client.text_to_speech.convert(
                voice_id=VOICE_ID,
                model_id=MODEL,
                output_format=OUTPUT_FORMAT,
                text=text,
                voice_settings=VOICE_SETTINGS,
            ))
            blob = bucket.blob(path)
            blob.upload_from_string(audio, content_type="audio/mpeg")
            blob.cache_control = "public, max-age=31536000, immutable"
            blob.patch()
            time.sleep(0.25)  # gentle rate limiting
        except Exception as e:
            print(f"  FAILED: {e}")
            failed.append((path, str(e)))

    if failed:
        Path("audio_failures.json").write_text(json.dumps(failed, indent=2))
        print(f"\n{len(failed)} failures logged to audio_failures.json")
        print("Fix the issues and re-run with --resume to retry.")
    else:
        print("\nAll files generated and uploaded successfully.")


# =============================================================================
# CLI
# =============================================================================

if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--dry-run", action="store_true",
                    help="Show plan and cost estimate without generating")
    ap.add_argument("--resume", action="store_true",
                    help="Skip files already in Storage")
    ap.add_argument("--limit", type=int, default=None,
                    help="Generate only the first N files (smoke test)")
    ap.add_argument("--only", nargs="+", default=None,
                    choices=["anchor_scripture", "anchor_prompts",
                             "morning_prayers", "arrow_scripture",
                             "arrow_prompts", "evening_prayers", "journeys"])
    args = ap.parse_args()

    jobs = build_job_list(args.only)
    chars, cost = estimate(jobs)

    print(f"\n{len(jobs)} files, {chars:,} characters, estimated ${cost:.2f}\n")
    summarize(jobs)

    if args.dry_run:
        sys.exit(0)

    print()
    generate(jobs, resume=args.resume, limit=args.limit)
