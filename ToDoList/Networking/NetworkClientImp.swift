import Foundation

struct NetworkClientImp: NetworkClient {
    // MARK: - Properties

    private let urlSession: URLSession

    // MARK: - Lifecycle

    init(urlSession: URLSession) {
        self.urlSession = urlSession
    }

    // MARK: - Public

    @discardableResult
    func processRequest<T: Decodable>(
        request: HTTPRequest,
        completion: @escaping (Result<T, HTTPError>) -> Void
    ) -> Cancellable? {
        do {
            let urlRequest = try createUrlRequest(from: request)

            let task = self.urlSession.dataTask(with: urlRequest) { data, response, error in
                guard let response = response as? HTTPURLResponse,
                      let unwrappedData = data
                else {
                    NetworkClientImp.executeCompletionOnMainThread {
                        completion(.failure(HTTPError.failedResponseUnwrapping))
                    }
                    return
                }
                let handledResponse = HTTPNetworkResponse.handleNetworkResponse(for: response)

                switch handledResponse {
                case .success:
                    let jsonDecoder = JSONDecoder()
                    jsonDecoder.keyDecodingStrategy = request.keyDecodingStrategy
                    jsonDecoder.dateDecodingStrategy = request.dateDecodingStrategy
                    guard let result = try? jsonDecoder.decode(T.self, from: unwrappedData) else {
                        NetworkClientImp.executeCompletionOnMainThread {
                            completion(.failure(HTTPError.decodingFailed))
                        }
                        return
                    }
                    NetworkClientImp.executeCompletionOnMainThread {
                        completion(.success(result))
                    }
                case .failure(let error):
                    NetworkClientImp.executeCompletionOnMainThread {
                        completion(.failure(error))
                    }
                }
            }

            task.resume()
            return task
        } catch {
            NetworkClientImp.executeCompletionOnMainThread {
                completion(.failure(HTTPError.failed))
            }
        }
        return nil
    }

    // MARK: - Private

    private func createUrlRequest(from request: HTTPRequest) throws -> URLRequest {
        guard var urlComponents = URLComponents(string: request.route) else {
            throw HTTPError.missingURL
        }

        let queryItems = request.queryItems.map { query in
            URLQueryItem(name: query.key, value: query.value)
        }

        urlComponents.queryItems = queryItems
        urlComponents.percentEncodedQuery = urlComponents.percentEncodedQuery?.replacingOccurrences(
            of: "+", with: "%2B"
        )

        guard let url = urlComponents.url else {
            throw HTTPError.missingURLComponents
        }

        var generatedRequest: URLRequest = .init(url: url)
        generatedRequest.httpMethod = request.httpMethod.rawValue
        generatedRequest.httpBody = request.body

        request.headers.forEach {
            generatedRequest.addValue($0.value, forHTTPHeaderField: $0.key)
        }
        return generatedRequest
    }

    private static func executeCompletionOnMainThread(_ closure: @escaping () -> Void) {
        DispatchQueue.main.async {
            closure()
        }
    }
}

extension URLSessionDataTask: Cancellable {}
