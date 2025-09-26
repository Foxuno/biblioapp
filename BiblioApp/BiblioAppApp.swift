import SwiftUI

@main
@MainActor
struct BiblioAppApp: App {
    @StateObject private var favorites = FavoritesStore()
    @StateObject private var reservations = ReservationsStore()

    var body: some Scene {
        WindowGroup {
            ContentView(vm: {
                let repository: BooksRepository
                if let base = Bundle.main.object(forInfoDictionaryKey: "BooksAPIBaseURL") as? String,
                   let url = URL(string: base) {
                    repository = NetworkBooksRepository(baseURL: url)
                } else {
                    repository = NetworkBooksRepository(baseURL: URL(string: "http://localhost:9999")!)
                }
                return BooksViewModel(repository: repository)
            }())
            .environmentObject(favorites)
            .environmentObject(reservations)
        }
    }
}
