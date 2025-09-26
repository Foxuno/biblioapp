import Foundation

struct NetworkBooksRepository: BooksRepository {
    let baseURL: URL

    func fetchBooks() async throws -> [Book] {
        let url = baseURL.appendingPathComponent("books")

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw BooksRepositoryError.failedToLoad
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        if let remote = try? decoder.decode([RemoteBook].self, from: data) {
            return remote.compactMap { $0.toBook() }
        }

        throw BooksRepositoryError.decoding
    }
}

private struct RemoteBook: Decodable {
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
