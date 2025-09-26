import Foundation
import Combine

struct Reservation: Codable, Identifiable, Equatable {
    let id: Int
    let expiry: Date
}

final class ReservationsStore: ObservableObject {
    @Published private(set) var reservations: [Int: Date] = [:]
    private let defaultsKey = "bookReservations"
    private let calendar = Calendar.current
    private let reservationDays: Int = 21
    private let maxActiveReservations: Int = 2

    init() {
        load()
        purgeExpired()
    }

    func isReserved(_ id: Int) -> Bool {
        guard let date = reservations[id] else { return false }
        return date > Date()
    }

    func expiry(for id: Int) -> Date? {
        guard let date = reservations[id], date > Date() else { return nil }
        return date
    }

    func canReserve(_ id: Int) -> Bool {
        let activeCount = reservations.values.filter { $0 > Date() }.count
        return isReserved(id) || activeCount < maxActiveReservations
    }

    func reserve(_ id: Int) {
        guard canReserve(id) else { return }
        if let expiry = calendar.date(byAdding: .day, value: reservationDays, to: Date()) {
            reservations[id] = expiry
            save()
        }
    }

    func cancel(_ id: Int) {
        reservations.removeValue(forKey: id)
        save()
    }

    func purgeExpired() {
        let now = Date()
        reservations = reservations.filter { $0.value > now }
        save()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: defaultsKey) else { return }
        let decoder = JSONDecoder()
        if let decoded = try? decoder.decode([Int: Date].self, from: data) {
            reservations = decoded
        } else {
            if (try? decoder.decode([UUID: Date].self, from: data)) != nil {
                reservations = [:]
            }
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(reservations) {
            UserDefaults.standard.set(data, forKey: defaultsKey)
        }
    }
}
