import Foundation

struct Todo: Identifiable, Equatable, Hashable {
    let id: Int
    var title: String
    var description: String
    let createdAt: Date
    var isCompleted: Bool
}
