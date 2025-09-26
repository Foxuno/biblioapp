import Foundation

struct Book: Identifiable, Codable {
    let id: Int
    let nombre: String
    let autor: String
    let descripcion: String
    let genero: String

    init(id: Int, nombre: String, autor: String, descripcion: String, genero: String) {
        self.id = id
        self.nombre = nombre
        self.autor = autor
        self.descripcion = descripcion
        self.genero = genero
    }
}

