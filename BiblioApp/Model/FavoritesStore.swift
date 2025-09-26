import Foundation
import Combine

final class FavoritesStore: ObservableObject {
    @Published private(set) var favoriteIDs: Set<Int> = []
    private let defaultsKey = "favoriteBookIDs"

    init() {
        load()
    }

    func isFavorite(_ id: Int) -> Bool {
        favoriteIDs.contains(id)
    }

    func toggle(_ id: Int) {
        if favoriteIDs.contains(id) {
            favoriteIDs.remove(id)
        } else {
            favoriteIDs.insert(id)
        }
        save()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: defaultsKey) else { return }
        if let decoded = try? JSONDecoder().decode([Int].self, from: data) {
            favoriteIDs = Set(decoded)
        } else {
            favoriteIDs = []
        }
    }

    private func save() {
        let array = Array(favoriteIDs)
        if let data = try? JSONEncoder().encode(array) {
            UserDefaults.standard.set(data, forKey: defaultsKey)
        }
    }
}

