import Foundation

protocol NetworkService: AnyObject {
    func getAllTodoItems(
        completion: @escaping (Result<NetworkResponse, Error>) -> Void
    )

    func updateAllTodoItems(
        _ items: [TodoItem],
        completion: @escaping (Result<NetworkResponse, Error>) -> Void
    )

    func getTodoItem(
        at id: String,
        completion: @escaping (Result<NetworkItemResponse, Error>) -> Void
    )

    func addTodoItem(
        _ item: TodoItem,
        completion: @escaping (Result<NetworkItemResponse, Error>) -> Void
    )

    func editTodoItem(
        _ item: TodoItem,
        completion: @escaping (Result<NetworkItemResponse, Error>) -> Void
    )

    func deleteTodoItem(
        at id: String,
        completion: @escaping (Result<NetworkItemResponse, Error>) -> Void
    )
}
