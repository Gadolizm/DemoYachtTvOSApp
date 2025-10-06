//
//  HomeScreen.swift
//  DemoYachtTvOSApp
//
//  Created by Haitham Gado on 06/10/2025.
//


import SwiftUI
import Combine


struct HomeScreen: View {
    // Clock (top-right)
    @State private var now = Date()
    private let clock = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    // ViewModel + selection
    @StateObject private var vm = CrewViewModel()
    @State private var selectedMember: CrewMember?

    // 🔹 Track which card has focus
    @FocusState private var focusedCrewID: String?

    // Grid layout (tuned for tvOS 4K)
    private let columns = Array(
        repeating: GridItem(.flexible(minimum: 300, maximum: 420), spacing: 28),
        count: 4
    )

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.06, green: 0.18, blue: 0.30),
                    Color(red: 0.04, green: 0.30, blue: 0.40)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 26) {
                TopBar(now: now)
                    .padding(.horizontal, 48)

                // Main content
                switch vm.state {
                case .idle, .firstLoading:
                    Spacer()
                    ProgressView("Loading…")
                        .scaleEffect(1.4)
                        .tint(.white)
                    Spacer()

                case .failed(let message):
                    Spacer()
                    VStack(spacing: 16) {
                        Text("Couldn't load crew")
                            .font(.title2)
                            .foregroundStyle(.white)
                        Text(message)
                            .foregroundStyle(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 900)
                        Button("Retry") {
                            Task { await vm.refresh(silent: false) }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.white)
                        .foregroundStyle(.black)
                        .focusable(true)
                    }
                    Spacer()

                case .loaded:
                    // Header / filters
                    header

                    // Grid
                    ScrollView {
                        LazyVGrid(columns: columns, alignment: .leading, spacing: 28) {
                            ForEach(vm.filteredCrew) { m in
                                RemoteCrewCardView(
                                    name: m.name.isEmpty ? "Unnamed" : m.name,
                                    role: m.role.isEmpty ? m.department.name : m.role,
                                    imageURL: m.imageURL,
                                    flag: m.flagEmoji,
                                    age: (m.age > 0 ? m.age : nil)
                                )
                                // 🔹 Make each card focusable & bind to its ID
                                .focused($focusedCrewID, equals: m.id)
                                .onTapGesture { selectedMember = m }
                                .accessibilityLabel("\(m.name.isEmpty ? "Crew Member" : m.name), \(m.role.isEmpty ? m.department.name : m.role)")
                            }
                        }
                        .padding(.horizontal, 48)
                        .padding(.bottom, 48)
                        .scrollIndicators(.hidden)
                    }
                    // Group focus so tvOS knows to keep it within the grid
                    .focusSection()
                }
            }
        }
        // Modal
        .fullScreenCover(item: $selectedMember) { member in
            CrewDetailView(
                name: member.name.isEmpty ? "Crew Member" : member.name,
                role: member.role.isEmpty ? member.department.name : member.role,
                age: (member.age > 0 ? member.age : nil),
                countryCode: member.country,
                bio: member.description,
                imageURL: member.imageURL
            )
        }
        // Lifecycle
        .onAppear {
            vm.onAppear()
            // 🔹 Give focus to the first card on first load
            if focusedCrewID == nil, let first = vm.filteredCrew.first?.id {
                focusedCrewID = first
            }
        }
        // 🔹 Keep focus valid when data/filters change
        .onChange(of: vm.filteredCrew.map(\.id)) { _, ids in
            if ids.isEmpty { focusedCrewID = nil }
            else if let current = focusedCrewID, ids.contains(current) {
                // keep current focus
            } else {
                focusedCrewID = ids.first
            }
        }
        .onReceive(clock) { now = $0 }
    }

    // MARK: Header / filters
    private var header: some View {
        HStack(spacing: 16) {
            Text("Crew")
                .font(.title)
                .bold()
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.9)
                .layoutPriority(0) // lower than picker so picker gets room

            Picker("Department", selection: Binding(
                get: { vm.selectedDepartment?.id ?? "ALL" },
                set: { id in
                    if id == "ALL" { vm.selectAll() }
                    else if let dep = vm.departments.first(where: { $0.id == id }) {
                        vm.selectedDepartment = dep
                    }
                })) {
                    Text("All")
                        .lineLimit(1)
                        .minimumScaleFactor(0.9)
                        .tag("ALL")

                    ForEach(vm.departments) { d in
                        Text(d.name)
                          .font(.callout)
                          .minimumScaleFactor(0.9)
                          .tag(d.id)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 1400) // give segments room to breathe

            Spacer(minLength: 12)

            Button {
                Task { await vm.refresh(silent: true) } // manual silent refresh
            } label: {
                Label("Refresh", systemImage: "arrow.clockwise")
                    .labelStyle(.iconOnly)
                    .imageScale(.large)
            }
            .focusable(true)
            .accessibilityLabel("Refresh")
        }
        .padding(.horizontal, 48)
    }
}

// MARK: - Top Bar
private struct TopBar: View {
    let now: Date

    var body: some View {
        HStack {
            Text("DemoYacht")
                .font(.title2).bold()
                .foregroundStyle(.white.opacity(0.95))

            Spacer()

            HStack(spacing: 12) {
                Text(dateString(now))
                    .font(.callout)
                    .foregroundStyle(.white.opacity(0.85))
                Image(systemName: "line.3.horizontal.circle")
                    .imageScale(.large)
                    .foregroundStyle(.white.opacity(0.9))
            }
        }
    }

    private func dateString(_ d: Date) -> String {
        let f = DateFormatter()
        f.locale = .init(identifier: "en_US_POSIX")
        f.dateFormat = "EEE d MMM   HH:mm" // e.g., Wed 4 Jun   16:19
        return f.string(from: d)
    }
}

