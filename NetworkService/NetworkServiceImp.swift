import Foundation

final class NetworkServiceImp: NetworkService {
    // MARK: - Properties
    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    // MARK: - Public
    func getAllTodoItems(
        revision: Int,
        completion: @escaping (Result<ListQuery, Error>) -> Void
    ) {
        networkClient.processRequest(
            request: createGetAllTodoItemsRequest(),
            completion: completion
        )
    }

    func updateAllTodoItems(
        revision: Int,
        _ items: [TodoItem],
        completion: @escaping (Result<ListQuery, Error>) -> Void
    ) {
        guard let request = try? createUpdateAllTodoItemsRequest(revision: revision, items) else {
            completion(.failure(HTTPError.decodingFailed))
            return
        }
        networkClient.processRequest(
            request: request,
            completion: completion
        )
    }

    func getTodoItem(
        revision: Int,
        at id: String,
        completion: @escaping (Result<ElementQuery, Error>) -> Void
    ) {
        networkClient.processRequest(
            request: createGetTodoItemRequest(id),
            completion: completion
        )
    }

    func addTodoItem(
        revision: Int,
        _ item: TodoItem,
        completion: @escaping (Result<ElementQuery, Error>) -> Void
    ) {
        guard let request = try? createAddTodoItemRequest(revision: revision, item) else {
            completion(.failure(HTTPError.decodingFailed))
            return
        }
        networkClient.processRequest(
            request: request,
            completion: completion
        )
    }

    func editTodoItem(
        revision: Int,
        _ item: TodoItem,
        completion: @escaping (Result<ElementQuery, Error>) -> Void
    ) {
        guard let request = try? createEditTodoItemRequest(item) else {
            completion(.failure(HTTPError.decodingFailed))
            return
        }
        networkClient.processRequest(
            request: request,
            completion: completion
        )
    }

    func deleteTodoItem(
        revision: Int,
        at id: String,
        completion: @escaping (Result<ElementQuery, Error>) -> Void
    ) {
        networkClient.processRequest(
            request: createDeleteTodoItemRequest(revision: revision, id),
            completion: completion
        )
    }

    // MARK: - Private

    private func createGetAllTodoItemsRequest() -> HTTPRequest {
        HTTPRequest(
            route: "\(Constants.baseurl)/list",
            headers: [Constants.authorizationKey: Constants.authorizationValue])
    }

    private func createUpdateAllTodoItemsRequest(revision: Int, _ items: [TodoItem]) throws -> HTTPRequest {
        let encoder = JSONEncoder()

        let networkItems = items.map { NetworkTodoItem(from: $0) }
        let body = ListQuery(list: networkItems, revision: nil)
        let data = try encoder.encode(body)

        return HTTPRequest(
            route: "\(Constants.baseurl)/list",
            headers: [
                Constants.authorizationKey: Constants.authorizationValue,
                Constants.lastRevisionKey: "\(revision)",
                Constants.contentTypeKey: Constants.contentTypeValue
            ],
            body: data,
            httpMethod: .patch
        )
    }

    private func createAddTodoItemRequest(revision: Int, _ item: TodoItem) throws -> HTTPRequest {
        let requestBody = ElementQuery(element: NetworkTodoItem(from: item))
        let encoder = JSONEncoder()
        let data = try encoder.encode(requestBody)

        return HTTPRequest(
            route: "\(Constants.baseurl)/list",
            headers: [
                Constants.authorizationKey: Constants.authorizationValue,
                Constants.lastRevisionKey: "\(revision)",
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

    private func createEditTodoItemRequest(_ item: TodoItem) throws -> HTTPRequest {
        let requestBody = ElementQuery(
            element: NetworkTodoItem(from: item),
            revision: nil
        )
        let encoder = JSONEncoder()
        let data = try encoder.encode(requestBody)

        return HTTPRequest(
            route: "\(Constants.baseurl)/list/\(item.id)",
            headers: [
                Constants.authorizationKey: Constants.authorizationValue,
                Constants.lastRevisionKey: "0",
                Constants.contentTypeKey: Constants.contentTypeValue
            ],
            body: data,
            httpMethod: .put
        )
    }

    private func createDeleteTodoItemRequest(revision: Int, _ id: String) -> HTTPRequest {
        HTTPRequest(
            route: "\(Constants.baseurl)/list/\(id)",
            headers: [
                Constants.authorizationKey: Constants.authorizationValue,
                Constants.lastRevisionKey: "\(revision)",
                Constants.contentTypeKey: Constants.contentTypeValue
                     ],
            httpMethod: .delete
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
