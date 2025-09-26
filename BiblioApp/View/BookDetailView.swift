import SwiftUI

struct BookDetailView: View {
    let book: Book
    @EnvironmentObject private var favorites: FavoritesStore
    @EnvironmentObject private var reservations: ReservationsStore

    var body: some View {
        let isFavorite = favorites.isFavorite(book.id)
        let isReserved = reservations.isReserved(book.id)
        let canReserve = reservations.canReserve(book.id)
        let expiry = reservations.expiry(for: book.id)

        return ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(book.nombre)
                            .font(.title)
                            .bold()
                        Text(book.autor)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 12) {
                        Button(action: { favorites.toggle(book.id) }) {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .font(.title2)
                                .foregroundStyle(isFavorite ? .red : .primary)
                                .padding(8)
                                .background(.thinMaterial, in: Circle())
                        }
                        .accessibilityLabel(isFavorite ? UIStrings.removeFromFavorites : UIStrings.addToFavorites)

                        if isReserved {
                            Button(UIStrings.cancelReservation) { reservations.cancel(book.id) }
                                .buttonStyle(.bordered)
                            if let expiry {
                                Text("Vence: \(expiry.formatted(date: .abbreviated, time: .omitted))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } else {
                            Button(UIStrings.reserve) { reservations.reserve(book.id) }
                                .buttonStyle(.borderedProminent)
                                .disabled(!canReserve)
                            if !canReserve {
                                Text(UIStrings.twoReservationsLimit)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Text(UIStrings.descriptionHeader)
                        .font(.headline)
                    Text(book.descripcion)
                        .font(.body)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(UIStrings.genreHeader)
                        .font(.headline)
                    Text(book.genero)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(UIStrings.idHeader)
                        .font(.headline)
                    Text("\(book.id)")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)
            }
            .padding()
        }
        .navigationTitle(UIStrings.detailTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    BookDetailView(book: Book(
        id: 1,
        nombre: "Ejemplo",
        autor: "Autora/o",
        descripcion: "Descripción de ejemplo",
        genero: "Género"
    ))
    .environmentObject(FavoritesStore())
    .environmentObject(ReservationsStore())
}

