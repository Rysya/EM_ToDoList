import Foundation

final class TodoListInteractor: TodoListInteractorProtocol {
    weak var presenter: TodoListPresenter?
    private let repository: TodoRepositoryProtocol
    private let network: NetworkServiceProtocol
    private var allTodos: [Todo] = []
    private var speechRecognizer: SpeechRecognizer

    init(repository: TodoRepositoryProtocol, network: NetworkServiceProtocol, speechRecognizer: SpeechRecognizer) {
        self.repository = repository
        self.network = network
        self.speechRecognizer = speechRecognizer
    }
    
    func load() {
        repository.fetchTodos { [weak self] result in
            guard let self else { return }
            switch result {
                case .success(let todos) where !todos.isEmpty:
                    allTodos = todos
                    presenter?.didLoad(todos)
                    presenter?.setLoading(.ready)
                case .success:
                    presenter?.setLoading(.loading)
                    network.fetchTodos { [weak self] result in
                        self?.importFromAPI(result)
                    }
                case .failure(let error): presenter?.didError(error)
            }
        }
    }
    
    private func importFromAPI(_ result: Result<[TodoDTO], Error>) {
        switch result {
            case .success(let dtos):
                let todos = dtos.map { Todo(id: $0.id, title: $0.todo, description: "", createdAt: Date(), isCompleted: $0.completed) }
                repository.replaceTodos(todos) { [weak self] saveResult in
                    guard let self else { return }
                    presenter?.setLoading(.ready)
                    switch saveResult {
                        case .success: allTodos = todos; presenter?.didLoad(todos)
                        case .failure(let error): presenter?.didError(error)
                    }
                }
            case .failure(let error):
                presenter?.setLoading(.empty)
                presenter?.didError(error)
        }
    }
    
    func search(_ query: String) {
        let snapshot = allTodos
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let normalized = query.trimmingCharacters(in: .whitespacesAndNewlines)
            let result = normalized.isEmpty ? snapshot : snapshot.filter {
                $0.title.localizedCaseInsensitiveContains(normalized) || $0.description.localizedCaseInsensitiveContains(normalized)
            }
            DispatchQueue.main.async { self?.presenter?.didLoad(result) }
        }
    }
    
    func delete(_ todo: Todo) {
        repository.delete(id: todo.id) { [weak self] result in
            guard let self else { return }
            switch result {
                case .success: allTodos.removeAll { $0.id == todo.id }
                    presenter?.didLoad(allTodos)
                case .failure(let error): presenter?.didError(error)
            }
        }
    }
    
    func toggle(_ todo: Todo) {
        var updated = todo
        updated.isCompleted.toggle()
        repository.update(updated) { [weak self] result in
            guard let self else { return }
            switch result {
                case .success:
                    if let index = allTodos.firstIndex(where: { $0.id == todo.id }) { allTodos[index] = updated }
                    presenter?.didLoad(allTodos)
                case .failure(let error): presenter?.didError(error)
            }
        }
    }

    func startVoiceRecording(with searchText: String) {
        Task {
            let allowed = await speechRecognizer.requestPermission()
            guard allowed else { return }
            speechRecognizer.toggleRecording(with: searchText)
        }
    }
}
