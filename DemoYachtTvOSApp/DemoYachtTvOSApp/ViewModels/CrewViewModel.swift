//
//  CrewViewModel.swift
//  DemoYachtTvOSApp
//
//  Created by Haitham Gado on 06/10/2025.
//


import Foundation
import Combine

@MainActor
final class CrewViewModel: ObservableObject {
    enum LoadState: Equatable { case idle, firstLoading, loaded, failed(String) }

    @Published private(set) var state: LoadState = .idle
    @Published private(set) var crew: [CrewMember] = []
    @Published private(set) var departments: [Department] = []
    @Published var selectedDepartment: Department? = nil 

    private var bag = Set<AnyCancellable>()
    private let api: CrewAPI
    private var didFirstLoad = false

    init(api: CrewAPI) {
        self.api = api

        // Auto-refresh every 30s (silent, no spinner)
        Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task { await self?.refresh(silent: true) }
            }
            .store(in: &bag)
    }

    convenience init() {
        self.init(api: APIClient.shared)
    }

    func onAppear() {
        if !didFirstLoad {
            Task { await refresh(silent: false) }
        }
    }

    func refresh(silent: Bool) async {
        if !silent { state = .firstLoading }
        await fetch()
        didFirstLoad = true
    }

    private func fetch() async {
        await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
            api.fetchCrew()
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    defer { cont.resume(returning: ()) }
                    guard let self else { return }
                    switch completion {
                    case .failure(let err):
                        if self.didFirstLoad {
                            self.state = .loaded // keep showing last known data
                        } else {
                            self.state = .failed(err.localizedDescription)
                        }
                    case .finished: break
                    }
                } receiveValue: { [weak self] members in
                    guard let self else { return }
                    let sorted = members.sortedByBusinessOrder()
                    self.crew = sorted

                    // unique departments sorted by order
                    let unique = Dictionary(grouping: sorted.map(\.department), by: \.id)
                        .compactMap { $0.value.first }
                        .sorted { $0.order < $1.order }
                    self.departments = unique

                    // Reset filter if selected dept disappeared
                    if let sel = self.selectedDepartment,
                       !unique.contains(where: { $0.id == sel.id }) {
                        self.selectedDepartment = nil
                    }
                    self.state = .loaded
                }
                .store(in: &bag)
        }
    }

    var filteredCrew: [CrewMember] {
        guard let department = selectedDepartment else { return crew }
        return crew.filter { $0.department.id == department.id }
    }

    func selectAll() { selectedDepartment = nil }
}

