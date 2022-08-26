import Foundation

protocol FileCacheService: AnyObject {

    var todoItems: [TodoItem] { get }

    func load(
        completion: @escaping (Result<[TodoItem], Error>) -> Void
    )

    func addTodoItem(
        _ newItem: TodoItem,
        completion: @escaping (Result<TodoItem, Error>) -> Void
    )

    func editTodoItem(
        _ item: TodoItem,
        completion: @escaping (Result<Void, Error>) -> Void
    )

    func deleteTodoItem(
        id: String,
        completion: @escaping (Result<Void, Error>) -> Void
    )
}
