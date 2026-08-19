import SwiftUI

@MainActor
enum TodoDetailBuilder {
    static func build(todo: Todo?, router: TodoListRouter) -> TodoDetailPresenter {
        let repository = TodoRepository(container: CoreDataStack.shared.persistentContainer)
        let interactor = TodoDetailInteractor(repository: repository, todo: todo)
        let presenter = TodoDetailPresenter(todo: todo, interactor: interactor, router: router)
        interactor.presenter = presenter
        return presenter
    }
}
