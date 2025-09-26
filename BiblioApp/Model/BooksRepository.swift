import Foundation

protocol BooksRepository {
    func fetchBooks() async throws -> [Book]
}

enum BooksRepositoryError: Error, LocalizedError {
    case failedToLoad
    case decoding

    var errorDescription: String? {
        switch self {
        case .failedToLoad: return "No se pudieron cargar los libros."
        case .decoding: return "Ocurrió un error al cargar los datos."
        }
    }
}

final class LocalBooksRepository: BooksRepository {
    private var cache: [Book]? = nil

    func fetchBooks() async throws -> [Book] {
        if let cache { return cache }
        try await Task.sleep(nanoseconds: 300_000_000)

        if let url = Bundle.main.url(forResource: "books", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                if let books = try? decoder.decode([Book].self, from: data) {
                    self.cache = books
                    return books
                }
                if let remote = try? decoder.decode([LocalRemoteBook].self, from: data) {
                    let books = remote.compactMap { $0.toBook() }
                    self.cache = books
                    return books
                }
                if let str = String(data: data, encoding: .utf8) {
                    print("Payload de books.json:\n\(str)")
                }
            } catch {
                print("LocalBooksRepository: error al decodificar books.json: \(error)")
                if let str = String(data: (try? Data(contentsOf: url)) ?? Data(), encoding: .utf8) {
                    print("Payload de books.json:\n\(str)")
                }
            }
        }
        
        let books: [Book] = []
        self.cache = books
        return books
    }
}

private struct LocalRemoteBook: Decodable {
    let id: Int?
    let name: String?
    let author: String?
    let description: String?
    let genre: String?

    func toBook() -> Book? {
        guard let bid = id else { return nil }
        return Book(
            id: bid,
            nombre: name ?? "Sin título",
            autor: author ?? "Desconocido",
            descripcion: description ?? "",
            genero: genre ?? "General"
        )
    }
}
