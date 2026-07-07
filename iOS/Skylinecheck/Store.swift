import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published var entries: [SkylinecheckEntry] = []
    @Published var isPro: Bool = false

    /// Free-tier cap. Always set safely above the seed count so a fresh
    /// install never hits the paywall immediately.
    static let freeLimit = 12

    private let fileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("skylinecheck_entries.json")
        load()
    }

    var canAddMore: Bool {
        isPro || entries.count < Store.freeLimit
    }

    @discardableResult
    func add(field1: String, field2: String, field3: String) -> Bool {
        guard canAddMore else { return false }
        let entry = SkylinecheckEntry(field1: field1, field2: field2, field3: field3)
        entries.insert(entry, at: 0)
        save()
        return true
    }

    func update(_ entry: SkylinecheckEntry) {
        guard let idx = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        entries[idx] = entry
        save()
    }

    func delete(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        save()
    }

    func delete(_ entry: SkylinecheckEntry) {
        entries.removeAll { $0.id == entry.id }
        save()
    }

    private func load() {
        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([SkylinecheckEntry].self, from: data) {
            entries = decoded
        } else {
            entries = [
            SkylinecheckEntry(field1: "Sample Landmark 1", field2: "Sample City 1", field3: "Sample Date Seen 1"),
            SkylinecheckEntry(field1: "Sample Landmark 2", field2: "Sample City 2", field3: "Sample Date Seen 2"),
            SkylinecheckEntry(field1: "Sample Landmark 3", field2: "Sample City 3", field3: "Sample Date Seen 3"),
            SkylinecheckEntry(field1: "Sample Landmark 4", field2: "Sample City 4", field3: "Sample Date Seen 4"),
            SkylinecheckEntry(field1: "Sample Landmark 5", field2: "Sample City 5", field3: "Sample Date Seen 5"),
            SkylinecheckEntry(field1: "Sample Landmark 6", field2: "Sample City 6", field3: "Sample Date Seen 6")
            ]
            save()
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(entries) {
            try? data.write(to: fileURL, options: .atomic)
        }
    }
}
