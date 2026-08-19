import Foundation

@MainActor
final class TodoDetailInteractor {
    weak var presenter: TodoDetailPresenter?
    private let repository: TodoRepositoryProtocol
    private let todo: Todo?

    init(repository: TodoRepositoryProtocol, todo: Todo?) {
        self.repository = repository
        self.todo = todo
    }

    func save(title: String, description: String) {
        let title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { presenter?.didError(TodoDetailError.emptyTitle); return }

        if var todo {
            todo.title = title
            todo.description = description
            repository.update(todo) { [weak self] result in
                switch result {
                case .success: self?.presenter?.didSave()
                case .failure(let error): self?.presenter?.didError(error)
                }
            }
        } else {
            let todo = Todo(id: Int.random(in: 1_000_000...9_999_999), title: title, description: description, createdAt: Date(), isCompleted: false)
            repository.add(todo) { [weak self] result in
                switch result {
                case .success: self?.presenter?.didSave()
                case .failure(let error): self?.presenter?.didError(error)
                }
            }
        }
    }
}

enum TodoDetailError: LocalizedError {
    case emptyTitle
    var errorDescription: String? { "Введите название задачи" }
}
