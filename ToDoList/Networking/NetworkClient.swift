import Foundation

protocol NetworkClient {
    @discardableResult
    func processRequest<T: Decodable>(
        request: HTTPRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> Cancellable?
}

protocol Cancellable {
    func cancel()
}
