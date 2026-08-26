import Foundation

nonisolated
struct Todo: Identifiable, Hashable, Sendable {
    let id: Int
    var title: String
    var description: String
    let createdAt: Date
    var isCompleted: Bool
}
