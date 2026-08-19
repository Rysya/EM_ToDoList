import Foundation

protocol TodoListInteractorProtocol: AnyObject {
    func load()
    func search(_ query: String)
    func delete(_ todo: Todo)
    func toggle(_ todo: Todo)
}

protocol TodoListRouterProtocol: AnyObject {
    func showCreate()
    func showEdit(_ todo: Todo)
}
