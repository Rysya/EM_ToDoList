import Foundation

protocol NetworkServiceProtocol {
    func fetchTodos(completion: @escaping (Result<[TodoDTO], Error>) -> Void)
}

enum NetworkError: LocalizedError {
    case invalidURL
    case badResponse
    case emptyResponse

    var errorDescription: String? {
        switch self {
        case .invalidURL: "Некорректный URL"
        case .badResponse: "Ошибка ответа сервера"
        case .emptyResponse: "Сервер не вернул данные"
        }
    }
}

final class NetworkService: NetworkServiceProtocol {
    private let session: URLSession
    init(session: URLSession = .shared) { self.session = session }

    func fetchTodos(completion: @escaping (Result<[TodoDTO], Error>) -> Void) {
        guard let url = URL(string: "https://dummyjson.com/todos") else {
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
