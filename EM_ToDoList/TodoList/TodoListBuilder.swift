import SwiftUI

@MainActor
enum TodoListBuilder {
    static func build() -> TodoListView {
        let repository = TodoRepository(container: CoreDataStack.shared.persistentContainer)
        let speechRecognizer = SpeechRecognizer()
        let interactor = TodoListInteractor(repository: repository, network: NetworkService(urlManager: URLManager()), speechRecognizer: speechRecognizer)
        let router = TodoListRouter()
        let presenter = TodoListPresenter(interactor: interactor, router: router)
        speechRecognizer.delegate = presenter
        interactor.presenter = presenter
        return TodoListView(presenter: presenter, router: router)
    }
}
