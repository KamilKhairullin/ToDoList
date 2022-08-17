import Foundation

protocol NetworkService: AnyObject {
    func getAllTodoItems(
        completion: @escaping (Result<[TodoItem], Error>) -> Void
    )

    func updateAllTodoItems(
        _ items: [TodoItem],
        completion: @escaping (Result<[TodoItem], Error>) -> Void
    )

    func getTodoItem(
        at id: String,
        completion: @escaping (Result<TodoItem, Error>) -> Void
    )

    func addTodoItem(
        _ item: TodoItem,
        completion: @escaping (Result<TodoItem, Error>) -> Void
    )

    func editTodoItem(
        _ item: TodoItem,
        completion: @escaping (Result<TodoItem, Error>) -> Void
    )

    func deleteTodoItem(
        at id: String,
        completion: @escaping (Result<TodoItem, Error>) -> Void
    )
}
