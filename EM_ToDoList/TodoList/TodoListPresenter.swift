import Foundation
import Combine

@MainActor
final class TodoListPresenter: ObservableObject {
    enum State {
        case loading
        case empty
        case ready
    }
    
    @Published private(set) var todos: [Todo] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?
    
    var state: State = .loading

    private let interactor: TodoListInteractorProtocol
    private weak var router: TodoListRouterProtocol?

    init(interactor: TodoListInteractorProtocol, router: TodoListRouterProtocol) {
        self.interactor = interactor
        self.router = router
    }

    func viewDidLoad() { interactor.load() }
    func search(_ query: String) { interactor.search(query) }
    func delete(_ todo: Todo) { interactor.delete(todo) }
    func toggle(_ todo: Todo) { interactor.toggle(todo) }
    
    func add() { router?.showCreate() }
    func edit(_ todo: Todo) { router?.showEdit(todo) }

    func didLoad(_ todos: [Todo]) { self.todos = todos; state = .ready }
    func setLoading(_ state: State) {
        self.state = state
    }
    func didError(_ error: Error) { state = .loading; errorMessage = error.localizedDescription }
}
