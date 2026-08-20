import Foundation

protocol URLManagerProtocol {
    func createURL(endpoint: Endpoint) -> URL?
}

enum Endpoint: String {
    case todos = "/todos"
}

class URLManager: URLManagerProtocol {

    private let gateway = "https://"
    private let server = "dummyjson.com"

    func createURL(endpoint: Endpoint) -> URL? {
        let str = gateway + server + endpoint.rawValue
        let url = URL(string: str)
        
        return url
    }
}
