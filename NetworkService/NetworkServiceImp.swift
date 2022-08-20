import Foundation

final class NetworkServiceImp: NetworkService {

    // MARK: - Properties
    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    // MARK: - Public
    func getAllTodoItems(completion: @escaping (Result<ListQuery, Error>) -> Void) {
        networkClient.processRequest(
            request: createGetAllTodoItemsRequest(),
            completion: completion)
    }

    func updateAllTodoItems(
        _ items: [TodoItem],
        completion: @escaping (Result<ListQuery, Error>) -> Void
    ) {
        guard let request = try? createUpdateAllTodoItemsRequest(items) else {
            completion(.failure(HTTPError.decodingFailed))
            return
        }
        networkClient.processRequest(
            request: request,
            completion: completion)
    }

    func getTodoItem(
        at id: String,
        completion: @escaping (Result<ElementQuery, Error>) -> Void
    ) {
        networkClient.processRequest(
            request: createGetTodoItemRequest(id),
            completion: completion)
    }

    func addTodoItem(
        _ item: TodoItem,
        completion: @escaping (Result<ElementQuery, Error>) -> Void
    ) {
        guard let request = try? createAddTodoItemRequest(item) else {
            completion(.failure(HTTPError.decodingFailed))
            return
        }
        networkClient.processRequest(
            request: request,
            completion: completion)
    }

    func editTodoItem(_ item: TodoItem, completion: @escaping (Result<ElementQuery, Error>) -> Void) {
        completion(.failure(HTTPError.wrongRequest))
    }

    func deleteTodoItem(at id: String, completion: @escaping (Result<ElementQuery, Error>) -> Void) {
        completion(.failure(HTTPError.wrongRequest))
    }

    // MARK: - Private

    private func createGetAllTodoItemsRequest() -> HTTPRequest {
        HTTPRequest(
            route: "\(Constants.baseurl)/list",
            headers: [Constants.authorizationKey: Constants.authorizationValue])
    }

    private func createUpdateAllTodoItemsRequest(_ items: [TodoItem]) throws -> HTTPRequest {
        let encoder = JSONEncoder()

        let networkItems = items.map { NetworkTodoItem(from: $0) }
        let body = ListQuery(list: networkItems, revision: nil)
        let data = try encoder.encode(body)

        return HTTPRequest(
            route: "\(Constants.baseurl)/list",
            headers: [
                Constants.authorizationKey: Constants.authorizationValue,
                Constants.lastRevisionKey: "0"
            ],
            body: data,
            httpMethod: .patch
        )
    }

    private func createAddTodoItemRequest(_ item: TodoItem) throws -> HTTPRequest {
        let requestBody = ElementQuery(
            element: NetworkTodoItem(from: item),
            revision: 0
        )
        let encoder = JSONEncoder()
        let data = try encoder.encode(requestBody)

        return HTTPRequest(
            route: "\(Constants.baseurl)/list",
            headers: [
                Constants.authorizationKey: Constants.authorizationValue,
                Constants.lastRevisionKey: "0",
                Constants.contentTypeKey: Constants.contentTypeValue
            ],
            body: data,
            httpMethod: .post
        )
    }

    private func createGetTodoItemRequest(_ id: String) -> HTTPRequest {
        HTTPRequest(
            route: "\(Constants.baseurl)/list/\(id)",
            headers: [Constants.authorizationKey: Constants.authorizationValue]
        )
    }
}

// MARK: - Nested types

extension NetworkServiceImp {
    enum Constants {
        static let baseurl: String = "https://beta.mrdekk.ru/todobackend"
        static let authorizationKey: String = "Authorization"
        static let authorizationValue: String = "Bearer VolatileFlowers"
        static let lastRevisionKey: String = "X-Last-Known-Revision"
        static let contentTypeKey: String = "Content-type"
        static let contentTypeValue: String = "application/json"
    }
}
