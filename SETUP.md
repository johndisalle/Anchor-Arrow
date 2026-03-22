# Anchor & Arrow – Stand Firm Edition
## MVP Setup Guide

---

## 1. Xcode Project Creation

1. Open Xcode → **File → New → Project → iOS App**
2. Product Name: `AnchorArrow`
3. Team: Your Apple Developer Team
4. Bundle ID: `com.yourcompany.anchorarrow`
5. Interface: **SwiftUI**
6. Language: **Swift**
7. Minimum Deployment: **iOS 17.0**
8. Check: **Include Tests** (optional)
9. Uncheck: Core Data (we use Firestore)

---

## 2. Firebase Setup

### 2a. Firebase Console
1. Go to [console.firebase.google.com](https://console.firebase.google.com)
2. Create project: "AnchorArrow"
3. Enable **Authentication** → Sign-in methods:
   - Email/Password ✓
   - Apple ✓ (requires Apple Developer account config)
4. Enable **Firestore Database** → Start in production mode
5. Enable **Storage** (for audio files later)
6. Download `GoogleService-Info.plist` → drag into Xcode project root

### 2b. Firebase SPM Integration
In Xcode: **File → Add Package Dependencies**
URL: `https://github.com/firebase/firebase-ios-sdk`
Add these products:
- `FirebaseAuth`
- `FirebaseFirestore`
- `FirebaseFirestoreSwift`
- `FirebaseStorage`
- `FirebaseAnalytics` (optional)

### 2c. Firestore Security Rules
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      match /entries/{entryId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      match /driftLogs/{logId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    match /circles/{circleId} {
      allow read: if request.auth != null &&
                     resource.data.memberIds.hasAny([request.auth.uid]);
      allow write: if request.auth != null &&
                      resource.data.memberIds.hasAny([request.auth.uid]);
      match /posts/{postId} {
        allow read: if request.auth != null;
        allow create: if request.auth != null &&
                         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isPremium == true;
        allow update, delete: if request.auth != null &&
                                  resource.data.authorId == request.auth.uid;
      }
    }
  }
}
```

---

## 3. Apple Sign-In Setup

1. In Xcode → Project → Signing & Capabilities → **+ Capability**
2. Add **Sign in with Apple**
3. In Firebase Console → Auth → Apple → configure with your Apple App ID
4. In `Info.plist` ensure `CFBundleURLSchemes` includes your reversed client ID from `GoogleService-Info.plist`

---

## 4. StoreKit Configuration (Testing)

1. **File → New → File → StoreKit Configuration File** → `Products.storekit`
2. Add subscriptions:
   - Monthly: `com.yourcompany.anchorarrow.premium.monthly` — $6.99/month
   - Annual: `com.yourcompany.anchorarrow.premium.annual` — $59.99/year
3. In scheme settings → Run → StoreKit Configuration → select `Products.storekit`

---

## 5. Push Notifications

1. Xcode → Signing & Capabilities → **Push Notifications**
2. Also add **Background Modes** → check **Remote notifications**
3. Upload APNs key to Firebase Console → Project Settings → Cloud Messaging

---

## 6. Info.plist Keys to Add

```xml
<!-- Microphone (future voice features) -->
<key>NSMicrophoneUsageDescription</key>
<string>Used for voice prayer recordings</string>

<!-- Push Notifications handled automatically via Firebase -->

<!-- App Transport Security (Firebase handles TLS) -->
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoads</key>
  <false/>
</dict>
```

---

## 7. Firestore Data Schema

```
/users/{uid}
  - uid: String
  - email: String
  - displayName: String
  - isPremium: Bool
  - premiumExpiry: Timestamp?
  - joinDate: Timestamp
  - currentStreak: Int
  - longestStreak: Int
  - totalAnchorDays: Int
  - totalArrowDays: Int
  - badges: [String]
  - journeyActive: Bool
  - journeyDay: Int
  - journeyStartDate: Timestamp?
  - notificationsEnabled: Bool
  - morningReminderHour: Int (default 7)
  - eveningReminderHour: Int (default 20)
  - theme: String ("system"|"dark"|"light")

/users/{uid}/entries/{dateString}   (dateString = "2024-01-15")
  - date: Timestamp
  - anchorCompleted: Bool
  - anchorPromptId: String
  - anchorReflection: String
  - anchorTags: [String]
  - arrowCompleted: Bool
  - arrowPromptId: String
  - arrowReflection: String
  - arrowRole: String

/users/{uid}/driftLogs/{logId}
  - timestamp: Timestamp
  - category: String
  - note: String

/circles/{circleId}
  - id: String
  - name: String
  - inviteCode: String
  - creatorId: String
  - memberIds: [String]
  - createdAt: Timestamp

/circles/{circleId}/posts/{postId}
  - authorId: String
  - content: String
  - type: String ("anchor"|"arrow"|"drift"|"prayer")
  - isAnonymous: Bool
  - timestamp: Timestamp
  - reactions: {String: Int}
```

---

## 8. Audio Files (Placeholder)

Place `.mp3` files in the Xcode project under `Resources/Audio/`:
- `anchor_morning.mp3` — Opening prayer (~30s, calm, grounding)
- `anchor_evening.mp3` — Evening reflection prayer
- `drift_anchor.mp3` — Quick anchoring prayer (~20s, firm, direct)
- `drift_pride.mp3` — Anti-pride prayer
- `drift_temptation.mp3` — Anti-temptation prayer
- `drift_anger.mp3` — Anti-anger prayer
- `drift_avoidance.mp3` — Anti-avoidance prayer

**Tone guidance for recordings**: Direct, masculine, grounded. Like a trusted older brother in faith — firm, not soft, but always rooted in love. Example: *"Lord Jesus, anchor me firm right now. I reject this lie. I stand on Your truth. Fill me with Your Spirit. Amen."*

---

## 9. App Store Submission Notes

**App Name**: Anchor & Arrow – Stand Firm Edition
**Subtitle**: Daily Habits for Biblical Men
**Category**: Health & Fitness (primary), Lifestyle (secondary)
**Age Rating**: 4+ (no mature content; drift categories are generic)

**Description**:
> Are you tired of drifting? Anchor & Arrow gives Christian men a daily structure to stand firm in faith and pursue God's purpose with strength and love. Based on 1 Corinthians 16:13-14 — "Be watchful, stand firm in the faith, act like men, be strong. Let all that you do be done in love." Track your daily anchor (stability in Christ) and arrow (purposeful action). Log drift moments and hear a grounding prayer in seconds. Join Iron Sharpeners circles with trusted brothers. Build your rooted tree and launch arrows for God's kingdom every single day.

**Keywords**: Christian men, faith habits, biblical manhood, daily devotional, accountability, prayer, spiritual growth, purpose, strength, 1 Corinthians

---

## 10. Next Steps After MVP

- [ ] Integrate OpenAI API for personalized prayer generation (premium)
- [ ] Add CloudKit sync as fallback
- [ ] Record professional audio prayers
- [ ] Add WidgetKit home screen widget (streak/daily prompt)
- [ ] Add WatchKit companion app (quick drift log + streak)
- [ ] Live monthly Q&A via StreamChat or in-app web view
- [ ] Analytics with Firebase Analytics + custom events
- [ ] A/B test onboarding flows
- [ ] Add social sharing (streak badges as images)
