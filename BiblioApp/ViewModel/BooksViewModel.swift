import Foundation
import Combine

@MainActor
final class BooksViewModel: ObservableObject {
    @Published private(set) var allBooks: [Book] = []
    @Published var query: String = ""
    @Published var selectedGenre: String? = nil
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String? = nil

    var genres: [String] {
        let set = Set(allBooks.map { $0.genero })
        return [UIStrings.all] + set.sorted()
    }

    private let repository: BooksRepository

    init(repository: BooksRepository = LocalBooksRepository()) {
        self.repository = repository
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let books = try await repository.fetchBooks()
            self.allBooks = books
        } catch {
            self.errorMessage = (error as? LocalizedError)?.errorDescription ?? UIStrings.errorGeneric
        }
    }

    var filteredBooks: [Book] {
        var result = allBooks
        if let selectedGenre {
            result = result.filter { $0.genero == selectedGenre }
        }
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            result = result.filter { book in
                book.nombre.localizedCaseInsensitiveContains(trimmed) ||
                book.autor.localizedCaseInsensitiveContains(trimmed) ||
                book.genero.localizedCaseInsensitiveContains(trimmed)
            }
        }
        return result
    }
}
