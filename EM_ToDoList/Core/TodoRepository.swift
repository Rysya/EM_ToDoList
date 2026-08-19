import CoreData

protocol TodoRepositoryProtocol {
    func fetchTodos(completion: @escaping (Result<[Todo], Error>) -> Void)
    func replaceTodos(_ todos: [Todo], completion: @escaping (Result<Void, Error>) -> Void)
    func add(_ todo: Todo, completion: @escaping (Result<Void, Error>) -> Void)
    func update(_ todo: Todo, completion: @escaping (Result<Void, Error>) -> Void)
    func delete(id: Int, completion: @escaping (Result<Void, Error>) -> Void)
}

enum TodoRepositoryError: LocalizedError {
    case notFound
    var errorDescription: String? { "Задача не найдена" }
}

final class TodoRepository: TodoRepositoryProtocol {
    private let container: NSPersistentContainer

    init(container: NSPersistentContainer) { self.container = container }

    func fetchTodos(completion: @escaping (Result<[Todo], Error>) -> Void) {
        container.performBackgroundTask { context in
            do {
                let request = TodoEntity.fetchRequest()
                request.sortDescriptors = [NSSortDescriptor(key: #keyPath(TodoEntity.createdAt), ascending: false)]
                let result = try context.fetch(request).map(Self.map)
                DispatchQueue.main.async { completion(.success(result)) }
            } catch { DispatchQueue.main.async { completion(.failure(error)) } }
        }
    }

    func replaceTodos(_ todos: [Todo], completion: @escaping (Result<Void, Error>) -> Void) {
        container.performBackgroundTask { context in
            do {
                try context.fetch(TodoEntity.fetchRequest()).forEach(context.delete)
                todos.forEach { todo in Self.makeEntity(todo, in: context) }
                try context.save()
                DispatchQueue.main.async { completion(.success(())) }
            } catch { DispatchQueue.main.async { completion(.failure(error)) } }
        }
    }

    func add(_ todo: Todo, completion: @escaping (Result<Void, Error>) -> Void) {
        container.performBackgroundTask { context in
            do {
                Self.makeEntity(todo, in: context)
                try context.save()
                DispatchQueue.main.async { completion(.success(())) }
            } catch { DispatchQueue.main.async { completion(.failure(error)) } }
        }
    }

    func update(_ todo: Todo, completion: @escaping (Result<Void, Error>) -> Void) {
        container.performBackgroundTask { context in
            do {
                let request = TodoEntity.fetchRequest()
                request.predicate = NSPredicate(format: "id == %d", todo.id)
                guard let entity = try context.fetch(request).first else { throw TodoRepositoryError.notFound }
                entity.title = todo.title
                entity.todoDescription = todo.description
                entity.isCompleted = todo.isCompleted
                try context.save()
                DispatchQueue.main.async { completion(.success(())) }
            } catch { DispatchQueue.main.async { completion(.failure(error)) } }
        }
    }

    func delete(id: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        container.performBackgroundTask { context in
            do {
                let request = TodoEntity.fetchRequest()
                request.predicate = NSPredicate(format: "id == %d", id)
                if let entity = try context.fetch(request).first { context.delete(entity) }
                try context.save()
                DispatchQueue.main.async { completion(.success(())) }
            } catch { DispatchQueue.main.async { completion(.failure(error)) } }
        }
    }

    private static func makeEntity(_ todo: Todo, in context: NSManagedObjectContext) {
        let entity = TodoEntity(context: context)
        entity.id = Int64(todo.id)
        entity.title = todo.title
        entity.todoDescription = todo.description
        entity.createdAt = todo.createdAt
        entity.isCompleted = todo.isCompleted
    }

    private static func map(_ entity: TodoEntity) -> Todo {
        Todo(id: Int(entity.id), title: entity.title ?? "", description: entity.todoDescription ?? "", createdAt: entity.createdAt ?? Date(), isCompleted: entity.isCompleted)
    }
}

extension TodoEntity {
    @nonobjc static func fetchRequest() -> NSFetchRequest<TodoEntity> {
        NSFetchRequest<TodoEntity>(entityName: "TodoEntity")
    }
}
