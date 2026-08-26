enum NetworkError: Error {
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
