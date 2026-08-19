import SwiftUI

@MainActor
enum TodoListBuilder {
    static func build() -> TodoListView {
        let repository = TodoRepository(container: CoreDataStack.shared.persistentContainer)
        let interactor = TodoListInteractor(repository: repository, network: NetworkService())
        let router = TodoListRouter()
        let presenter = TodoListPresenter(interactor: interactor, router: router)
        interactor.presenter = presenter
        return TodoListView(presenter: presenter, router: router)
    }
}
