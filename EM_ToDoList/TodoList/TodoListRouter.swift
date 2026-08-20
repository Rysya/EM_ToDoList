import Combine
import SwiftUI

@MainActor
final class TodoListRouter: ObservableObject, TodoListRouterProtocol {
    enum Route: Hashable {
        case create
        case edit(Todo)
    }

    @Published var path = NavigationPath()

    func showCreate() { path.append(Route.create) }
    func showEdit(_ todo: Todo) { path.append(Route.edit(todo)) }
    func close() { path.removeLast() }
}
