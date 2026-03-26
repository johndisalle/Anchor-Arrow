// JournalHistoryView.swift
// Premium — browse and search full journal entry history

import SwiftUI
import FirebaseAuth

struct JournalHistoryView: View {
    @EnvironmentObject var userStore: UserStore
    @State private var searchText = ""
    @State private var selectedEntry: DailyEntry?
    @State private var filterMode: FilterMode = .all

    enum FilterMode: String, CaseIterable {
        case all = "All"
        case anchor = "Anchors"
        case arrow = "Arrows"
        case both = "Full Days"
    }

    private var filteredEntries: [DailyEntry] {
        var entries = userStore.recentEntries

        // Apply filter
        switch filterMode {
        case .all:    break
        case .anchor: entries = entries.filter { $0.anchorCompleted }
        case .arrow:  entries = entries.filter { $0.arrowCompleted }
        case .both:   entries = entries.filter { $0.bothCompleted }
        }

        // Apply search
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            entries = entries.filter {
                $0.anchorReflection.lowercased().contains(query) ||
                $0.arrowReflection.lowercased().contains(query) ||
                $0.arrowRole.displayName.lowercased().contains(query) ||
                $0.anchorTags.contains { $0.displayName.lowercased().contains(query) }
            }
        }

        return entries
    }

    var body: some View {
        VStack(spacing: 0) {
            // Filter pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AATheme.paddingSmall) {
                    ForEach(FilterMode.allCases, id: \.self) { mode in
                        Button {
                            withAnimation(.spring(response: 0.3)) { filterMode = mode }
                        } label: {
                            Text(mode.rawValue)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(filterMode == mode ? .white : AATheme.secondaryText)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 7)
                                .background(filterMode == mode ? AATheme.steel : AATheme.cardBackground)
                                .cornerRadius(20)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }

            if filteredEntries.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: searchText.isEmpty ? "book.closed" : "magnifyingglass")
                        .font(.system(size: 36))
                        .foregroundColor(AATheme.secondaryText.opacity(0.4))
                    Text(searchText.isEmpty ? "No entries yet" : "No entries match your search")
                        .font(.system(size: 15))
                        .foregroundColor(AATheme.secondaryText)
                }
                Spacer()
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredEntries) { entry in
                            JournalEntryCard(entry: entry)
                                .onTapGesture { selectedEntry = entry }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
        }
        .aaScreenBackground()
        .navigationTitle("Journal History")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "Search reflections...")
        .sheet(item: $selectedEntry) { entry in
            JournalEntryDetailSheet(entry: entry)
        }
    }
}

// MARK: - JournalEntryCard
private struct JournalEntryCard: View {
    let entry: DailyEntry

    var body: some View {
        VStack(alignment: .leading, spacing: AATheme.paddingSmall + 2) {
            // Date + status
            HStack {
                Text(entry.date.displayShort)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AATheme.primaryText)

                Spacer()

                HStack(spacing: 6) {
                    if entry.anchorCompleted {
                        Image(systemName: "sunrise.fill")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(AATheme.steel)
                    }
                    if entry.arrowCompleted {
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(AATheme.amber)
                    }
                }
            }

            // Anchor reflection preview
            if entry.anchorCompleted && !entry.anchorReflection.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Label("Anchor", systemImage: "sunrise.fill")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(AATheme.steel)

                    Text(entry.anchorReflection)
                        .font(.system(size: 13))
                        .foregroundColor(AATheme.secondaryText)
                        .lineLimit(2)
                }
            }

            // Arrow reflection preview
            if entry.arrowCompleted && !entry.arrowReflection.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Label(entry.arrowRole.displayName, systemImage: entry.arrowRole.icon)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(AATheme.amber)

                    Text(entry.arrowReflection)
                        .font(.system(size: 13))
                        .foregroundColor(AATheme.secondaryText)
                        .lineLimit(2)
                }
            }

            // Drift tags if present
            if !entry.anchorTags.isEmpty {
                HStack(spacing: 6) {
                    ForEach(entry.anchorTags) { tag in
                        HStack(spacing: 3) {
                            Image(systemName: tag.icon)
                                .font(.system(size: 9))
                            Text(tag.displayName)
                                .font(.system(size: 10, weight: .medium))
                        }
                        .foregroundColor(AATheme.warning)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(AATheme.warning.opacity(0.1))
                        .cornerRadius(6)
                    }
                }
            }
        }
        .padding(14)
        .background(AATheme.cardBackground)
        .cornerRadius(AATheme.cornerRadius)
        .shadow(color: AATheme.cardShadow, radius: AATheme.cardShadowRadius, x: 0, y: 2)
    }
}

// MARK: - JournalEntryDetailSheet
struct JournalEntryDetailSheet: View {
    let entry: DailyEntry
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: AATheme.paddingLarge) {

                    // Date header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.date.formatted(.dateTime.weekday(.wide).month(.wide).day()))
                                .font(AATheme.headlineFont)
                                .foregroundColor(AATheme.primaryText)

                            Text(entry.date.formatted(.dateTime.year()))
                                .font(.system(size: 14))
                                .foregroundColor(AATheme.secondaryText)
                        }
                        Spacer()

                        // Completion badge
                        if entry.bothCompleted {
                            Label("Full Day", systemImage: "checkmark.circle.fill")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(AATheme.warmGold)
                                .padding(.horizontal, AATheme.paddingSmall + 2)
                                .padding(.vertical, 5)
                                .background(AATheme.warmGold.opacity(0.12))
                                .cornerRadius(AATheme.cornerRadiusSmall)
                        }
                    }

                    // Anchor section
                    if entry.anchorCompleted {
                        VStack(alignment: .leading, spacing: AATheme.paddingSmall + 2) {
                            HStack(spacing: AATheme.paddingSmall) {
                                Image(systemName: "sunrise.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(AATheme.steel)
                                Text("Anchor — Morning Reflection")
                                    .font(AATheme.subheadlineFont)
                                    .foregroundColor(AATheme.primaryText)
                            }

                            if !entry.anchorReflection.isEmpty {
                                Text(entry.anchorReflection)
                                    .font(.system(size: 15))
                                    .foregroundColor(AATheme.primaryText)
                                    .lineSpacing(5)
                                    .padding(14)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(AATheme.steel.opacity(0.06))
                                    .cornerRadius(12)
                            }

                            if !entry.anchorTags.isEmpty {
                                HStack(spacing: AATheme.paddingSmall) {
                                    ForEach(entry.anchorTags) { tag in
                                        HStack(spacing: 4) {
                                            Image(systemName: tag.icon)
                                                .font(.system(size: 11))
                                            Text(tag.displayName)
                                                .font(.system(size: 12, weight: .medium))
                                        }
                                        .foregroundColor(AATheme.warning)
                                        .padding(.horizontal, 9)
                                        .padding(.vertical, 5)
                                        .background(AATheme.warning.opacity(0.1))
                                        .cornerRadius(AATheme.paddingSmall)
                                    }
                                }
                            }

                            if let time = entry.anchorCompletedAt {
                                Text("Completed at \(time.formatted(date: .omitted, time: .shortened))")
                                    .font(.system(size: 11))
                                    .foregroundColor(AATheme.secondaryText)
                            }
                        }
                    }

                    // Arrow section
                    if entry.arrowCompleted {
                        VStack(alignment: .leading, spacing: AATheme.paddingSmall + 2) {
                            HStack(spacing: AATheme.paddingSmall) {
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(AATheme.amber)
                                Text("Arrow — Evening Reflection")
                                    .font(AATheme.subheadlineFont)
                                    .foregroundColor(AATheme.primaryText)
                            }

                            HStack(spacing: 6) {
                                Image(systemName: entry.arrowRole.icon)
                                    .font(.system(size: 12))
                                Text(entry.arrowRole.displayName)
                                    .font(.system(size: 13, weight: .semibold))
                            }
                            .foregroundColor(AATheme.amber)

                            if !entry.arrowReflection.isEmpty {
                                Text(entry.arrowReflection)
                                    .font(.system(size: 15))
                                    .foregroundColor(AATheme.primaryText)
                                    .lineSpacing(5)
                                    .padding(14)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(AATheme.amber.opacity(0.06))
                                    .cornerRadius(12)
                            }

                            if let time = entry.arrowCompletedAt {
                                Text("Completed at \(time.formatted(date: .omitted, time: .shortened))")
                                    .font(.system(size: 11))
                                    .foregroundColor(AATheme.secondaryText)
                            }
                        }
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, AATheme.paddingMedium)
            }
            .aaScreenBackground()
            .navigationTitle("Entry Detail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(AATheme.steel)
                }
            }
        }
    }
}
