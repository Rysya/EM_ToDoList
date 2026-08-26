import XCTest
import Combine
@testable import EM_ToDoList

@MainActor
final class TodoListInteractorTests: XCTestCase {
    
    var interactor: TodoListInteractor?
    var networkService: NetworkServiceMock?
    var presenter: TodoListPresenter?
    var repository: TodoRepositoryMock?
    var speechRecognizer: SpeechRecognizer?
        
    override func setUpWithError() throws {
        repository = TodoRepositoryMock()
        let speechRecognizer = SpeechRecognizer()
        networkService = NetworkServiceMock()
        guard let networkService,
              let repository  else { return }
        interactor = TodoListInteractor(repository: repository,
                                        network: networkService,
                                        speechRecognizer: speechRecognizer)
        guard let interactor else { return }
        let router = TodoListRouter()
        presenter = TodoListPresenter(interactor: interactor, router: router)
        interactor.presenter = presenter
    }
    
    override func tearDownWithError() throws {
        interactor = nil
        networkService = nil
        presenter = nil
    }
    
    //MARK: tests load()
    
    func testLoadNetworkTodosShouldСompleted() {
        
        repository?.isValidFetch = false
        networkService?.isValidFetch = true
        
        interactor?.load()
        
        guard let todos = interactor?.presenter?.todos else {
            XCTFail("NOT Сompleted Load Network Todos")
            return
        }
   
        XCTAssertTrue(!todos.isEmpty)
    }
    
    func testLoadNetworkTodosShouldFailed() {
        
        repository?.isValidFetch = false
        networkService?.isValidFetch = false
        
        interactor?.load()
        
        guard let todos = interactor?.presenter?.todos else {
            XCTFail("NOT Failed Load Network Todos")
            return
        }

        XCTAssertTrue(todos.isEmpty)
    }
    
    func testLoadRepositoryTodosShouldСompleted() {
        
        repository?.isValidFetch = true
        networkService?.isValidFetch = false
        
        interactor?.load()
        
        guard let todos = interactor?.presenter?.todos else {
            XCTFail("NOT Сompleted Load Repository Todos")
            return
        }
   
        XCTAssertFalse(todos.isEmpty)
    }
    
    func testLoadRepositoryTodosShouldFailed() {
        
        repository?.isValidFetch = false
        networkService?.isValidFetch = false
        
        interactor?.load()
        
        guard let todos = interactor?.presenter?.todos else {
            XCTFail("NOT Failed Load Repository Todos")
            return
        }

        XCTAssertTrue(todos.isEmpty)
    }
    
    //MARK: tests search()
    
    func testSearchTodosShouldCompleted() {
        let offers = ["", "aaa", "1", "zzz"]

        repository?.isValidFetch = true
        networkService?.isValidFetch = false
        interactor?.load()
        
        let expectation = expectation(description: "collected \(offers.count) states")
        var snapshots = Set<[Int]>()
        var cancellable: AnyCancellable?
        
        cancellable = interactor?.presenter?.$todos
            .dropFirst()
            .map { $0.map(\.id) }
            .sink { ids in
                snapshots.insert(ids)
                if snapshots.count == offers.count {
                    expectation.fulfill()
                    cancellable = nil
                }
            }
                
        for offer in offers {
            interactor?.search(offer)
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertNil(cancellable?.cancel())
        XCTAssertEqual(snapshots, [[1, 2, 3],
                                   [1],
                                   [1, 3],
                                   []])
    }
    
    //MARK: tests speach()
    
    func testSpeechToTextShouldCompleted() {
        interactor?.startVoiceRecording(with: "")
    }
    
    func testSpeechToTextShouldFailed() {
        
    }
    
    //MARK: tests delete()
    
    func testDeleteTodoShouldCompleted() {
        repository?.isValidFetch = true
        networkService?.isValidFetch = false
        interactor?.load()
        
        guard interactor?.presenter?.todos != nil,
              let tempTodo = interactor?.presenter?.todos.first else {
            XCTFail("NOT Сompleted Load Repository Todos")
            return
        }
              
        interactor?.delete(tempTodo)
        
        guard let newTodos = interactor?.presenter?.todos else {
            XCTFail("Repository Todos is nil")
            return
        }
        
        XCTAssertFalse(newTodos.contains(tempTodo))
    }
    
    //MARK: tests toggle()
    
    func testToggleTodoShouldCompleted() {
        repository?.isValidFetch = true
        networkService?.isValidFetch = false
        interactor?.load()
        
        guard let oldTodos = interactor?.presenter?.todos,
              let tempTodo = interactor?.presenter?.todos.first else {
            XCTFail("NOT Сompleted Load Repository Todos")
            return
        }
        
        interactor?.toggle(tempTodo)
        
        guard let newTodos = interactor?.presenter?.todos else {
            XCTFail("Repository Todos is nil")
            return
        }
        
        XCTAssertNotEqual(oldTodos, newTodos)
    }
    
}
