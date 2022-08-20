import Foundation

protocol NetworkClient {
    func processRequest<T: Decodable>(
        request: HTTPRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> Cancellable?
}

protocol Cancellable {
    func cancel()
}
