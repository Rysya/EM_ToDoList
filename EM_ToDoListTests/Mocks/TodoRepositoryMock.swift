import Foundation
@testable import EM_ToDoList

final class TodoRepositoryMock: TodoRepositoryProtocol {
    
    var isValidFetch = true
    
    func fetchTodos(completion: @escaping (Result<[EM_ToDoList.Todo], any Error>) -> Void) {
        if isValidFetch {
            completion(.success([Todo(id: 1, title: "aaa", description: "a1a1a1", createdAt: Date(), isCompleted: false),
                                 Todo(id: 2, title: "bbb", description: "b2b2b2", createdAt: Date(), isCompleted: true),
                                 Todo(id: 3, title: "ccc", description: "a1b2c3", createdAt: Date(), isCompleted: false)]))
        } else {
            completion(.success([]))
        }
    }
    
    func replaceTodos(_ todos: [EM_ToDoList.Todo], completion: @escaping (Result<Void, any Error>) -> Void) {
        completion(.success(()))
    }
    
    func add(_ todo: EM_ToDoList.Todo, completion: @escaping (Result<Void, any Error>) -> Void) {
        
    }
    
    func update(_ todo: EM_ToDoList.Todo, completion: @escaping (Result<Void, any Error>) -> Void) {
        completion(.success(()))
    }
    
    func delete(id: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        completion(.success(()))
    }
    
}
