@testable import EM_ToDoList

final class NetworkServiceMock: NetworkServiceProtocol {
    
    var isValidFetch = true
    
    func fetchTodos(completion: @escaping (Result<[EM_ToDoList.TodoDTO], any Error>) -> Void) {
        if isValidFetch {
            completion(.success([TodoDTO(id: 0, todo: "1111", completed: false, userId: 4),
                                 TodoDTO(id: 1, todo: "2222", completed: true, userId: 6),
                                 TodoDTO(id: 2, todo: "3333", completed: false, userId: 8)]))
        } else {
            completion(.failure(NetworkError.badResponse))
        }
    }
}
