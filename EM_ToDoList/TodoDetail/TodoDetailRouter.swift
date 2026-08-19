import SwiftUI

protocol TodoDetailRouterProtocol: AnyObject {
    func close()
}

@MainActor
final class TodoDetailRouter: TodoDetailRouterProtocol {
    private weak var listRouter: TodoListRouter?
    init(listRouter: TodoListRouter) { self.listRouter = listRouter }
    func close() { listRouter?.path.removeLast() }
}
