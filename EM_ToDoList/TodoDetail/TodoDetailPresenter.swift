import Foundation
import Combine
import SwiftUI

@MainActor
final class TodoDetailPresenter: ObservableObject {
    let todo: Todo?
    @Published var title: String
    @Published var description: String
    @Published var errorMessage: String?

    private let interactor: TodoDetailInteractor
    private weak var router: TodoListRouter?

    init(todo: Todo?, interactor: TodoDetailInteractor, router: TodoListRouter) {
        self.todo = todo
        self.interactor = interactor
        self.router = router
        _title = Published(initialValue: todo?.title ?? "")
        _description = Published(initialValue: todo?.description ?? "")
    }

    func save() { interactor.save(title: title, description: description) }
    func didSave() { router?.path.removeLast() }
    func didError(_ error: Error) { errorMessage = error.localizedDescription }
}
