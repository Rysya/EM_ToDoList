nonisolated
struct TodoDTO: Decodable, Sendable {
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int
}

nonisolated
struct TodosResponse: Decodable, Sendable {
    let todos: [TodoDTO]
    let total: Int
    let skip: Int
    let limit: Int
}
