import Foundation

final class NetworkServiceImp: NetworkService {
    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func getAllTodoItems(completion: @escaping (Result<NetworkResponse, Error>) -> Void) {
        networkClient.processRequest(
            request: createGetAllTodoItemsRequest(),
            completion: completion)
    }

    func updateAllTodoItems(_ items: [TodoItem], completion: @escaping (Result<NetworkResponse, Error>) -> Void) {
        networkClient.processRequest(
            request: createUpdateAllTodoItemsRequest(items),
            completion: completion)
    }

    func getTodoItem(at id: String, completion: @escaping (Result<NetworkItemResponse, Error>) -> Void) {
        networkClient.processRequest(
            request: createGetTodoItemRequest(id),
            completion: completion)
    }

    func addTodoItem(_ item: TodoItem, completion: @escaping (Result<NetworkItemResponse, Error>) -> Void) {
        networkClient.processRequest(
            request: createAddTodoItemRequest(item),
            completion: completion)
    }

    func editTodoItem(_ item: TodoItem, completion: @escaping (Result<NetworkItemResponse, Error>) -> Void) {
        completion(.failure(HTTPError.wrongRequest))
    }

    func deleteTodoItem(at id: String, completion: @escaping (Result<NetworkItemResponse, Error>) -> Void) {
        completion(.failure(HTTPError.wrongRequest))
    }

    private func createGetAllTodoItemsRequest() -> HTTPRequest {
        HTTPRequest(route: "https://beta.mrdekk.ru/todobackend/list", headers: ["Authorization": "Bearer VolatileFlowers"])
    }

    private func createUpdateAllTodoItemsRequest(_ items: [TodoItem]) -> HTTPRequest {
        let networkItems = items.map { NetworkTodoItem(from: $0) }
        let encoder = JSONEncoder()
        let requestBody = NetworkResponse(status: "ok", list: networkItems, revision: nil)

        guard let data = try? encoder.encode(requestBody) else {
            fatalError()
        }
        return HTTPRequest(
            route: "https://beta.mrdekk.ru/todobackend/list",
            headers: [
                "Authorization": "Bearer VolatileFlowers",
                "X-Last-Known-Revision": "0",
            ],
            body: data,
            httpMethod: .patch)
    }

    private func createAddTodoItemRequest(_ item: TodoItem) -> HTTPRequest {
        let networkItem = NetworkTodoItem(from: item)
        let encoder = JSONEncoder()
        let requestBody = NetworkItemResponse(status: "ok", element: networkItem, revision: 0)

        guard let data = try? encoder.encode(requestBody) else {
            fatalError()
        }

        return HTTPRequest(
            route: "https://beta.mrdekk.ru/todobackend/list",
            headers: [
                "Authorization": "Bearer VolatileFlowers",
                "X-Last-Known-Revision": "0",
                "Content-type": "application/json",
            ],
            body: data,
            httpMethod: .post)
    }

    private func createGetTodoItemRequest(_ id: String) -> HTTPRequest {
        HTTPRequest(route: "https://beta.mrdekk.ru/todobackend/list/\(id)", headers: ["Authorization": "Bearer VolatileFlowers"])
    }
}
