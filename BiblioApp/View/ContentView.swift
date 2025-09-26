import SwiftUI

struct ContentView: View {
    @StateObject private var vm: BooksViewModel
    @EnvironmentObject private var favorites: FavoritesStore
    @State private var favoritesOnly: Bool = false

    init(vm: BooksViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }

    private var displayedBooks: [Book] {
        let base = vm.filteredBooks
        return favoritesOnly ? base.filter { favorites.isFavorite($0.id) } : base
    }

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading {
                    VStack(spacing: 12) {
                        ProgressView()
                        Text(UIStrings.loading)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = vm.errorMessage {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundStyle(.orange)
                        Text(error)
                            .multilineTextAlignment(.center)
                        Button(UIStrings.retry) {
                            Task { await vm.load() }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack(spacing: 8) {
                        if vm.genres.count > 1 {
                            Picker(UIStrings.genre, selection: Binding(
                                get: { vm.selectedGenre ?? UIStrings.all },
                                set: { newValue in vm.selectedGenre = (newValue == UIStrings.all ? nil : newValue) }
                            )) {
                                ForEach(vm.genres, id: \.self) { g in
                                    Text(g).tag(g)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal)
                        }

                        Toggle(UIStrings.favoritesOnly, isOn: $favoritesOnly)
                            .padding(.horizontal)

                        if displayedBooks.isEmpty {
                            VStack(spacing: 8) {
                                Image(systemName: "book")
                                    .font(.largeTitle)
                                    .foregroundStyle(.secondary)
                                Text(UIStrings.emptyTitle)
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            List(displayedBooks) { book in
                                NavigationLink(value: book.id) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(book.nombre)
                                                .font(.headline)
                                            Text(book.autor)
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        if favorites.isFavorite(book.id) {
                                            Image(systemName: "heart.fill")
                                                .foregroundStyle(.red)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                            .listStyle(.insetGrouped)
                        }
                    }
                }
            }
            .navigationTitle(UIStrings.appTitle)
            .navigationDestination(for: Int.self) { id in
                if let selected = vm.allBooks.first(where: { $0.id == id }) {
                    BookDetailView(book: selected)
                } else {
                    Text(UIStrings.errorGeneric)
                }
            }
        }
        .searchable(text: $vm.query, placement: .navigationBarDrawer(displayMode: .automatic), prompt: Text(UIStrings.searchPrompt))
        .task { await vm.load() }
    }
}

#Preview {
    ContentView(vm: BooksViewModel())
        .environmentObject(FavoritesStore())
        .environmentObject(ReservationsStore())
}

