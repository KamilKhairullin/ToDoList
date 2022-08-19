import Foundation

final class NetworkServiceImp {
    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    @discardableResult
    func getAllTodoItems(completion: @escaping (Result<[NetworkTodoItem], HTTPError>) -> Void) -> Cancellable? {
        networkClient.processRequest(
            request: createGetAllTodoItemsRequest(),
            completion: completion)
    }

//    func updateAllTodoItems(_ items: [TodoItem], completion: @escaping (Result<[TodoItem], Error>) -> Void) {
//        <#code#>
//    }
//
//    func getTodoItem(at id: String, completion: @escaping (Result<TodoItem, Error>) -> Void) {
//        <#code#>
//    }
//
//    func addTodoItem(_ item: TodoItem, completion: @escaping (Result<TodoItem, Error>) -> Void) {
//        <#code#>
//    }
//
//    func editTodoItem(_ item: TodoItem, completion: @escaping (Result<TodoItem, Error>) -> Void) {
//        <#code#>
//    }
//
//    func deleteTodoItem(at id: String, completion: @escaping (Result<TodoItem, Error>) -> Void) {
//        <#code#>
//    }

    private func createGetAllTodoItemsRequest() -> HTTPRequest {
        HTTPRequest(route: "https://beta.mrdekk.ru/todobackend/list", headers: ["Authorization": "Bearer VolatileFlowers"]
        )
    }
}
