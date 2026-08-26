import Foundation

protocol NetworkServiceProtocol {
    func fetchTodos(completion: @escaping (Result<[TodoDTO], Error>) -> Void)
}

final class NetworkService: NetworkServiceProtocol {
    private let session: URLSession
    private let urlManager: URLManagerProtocol
    
    init(session: URLSession = .shared, urlManager: URLManagerProtocol) {
        self.session = session
        self.urlManager = urlManager
    }

    func fetchTodos(completion: @escaping (Result<[TodoDTO], Error>) -> Void) {
        guard let url = urlManager.createURL(endpoint: .todos) else {
            DispatchQueue.main.async { completion(.failure(NetworkError.invalidURL)) }
            return
        }

        session.dataTask(with: url) { data, response, error in
            if let error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
                DispatchQueue.main.async { completion(.failure(NetworkError.badResponse)) }
                return
            }
            guard let data else {
                DispatchQueue.main.async { completion(.failure(NetworkError.emptyResponse)) }
                return
            }
            do {
                let response = try JSONDecoder().decode(TodosResponse.self, from: data)
                DispatchQueue.main.async { completion(.success(response.todos)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }
}
