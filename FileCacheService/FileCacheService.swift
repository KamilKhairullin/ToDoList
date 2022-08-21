import Foundation

protocol FileCacheService: AnyObject {

    var todoItems: [TodoItem] { get }

    func save(
        to file: String,
        completion: @escaping (Result<Void, Error>) -> Void
    )

    func load(
        from file: String,
        completion: @escaping (Result<[TodoItem], Error>) -> Void
    )

    func addTodoItem(
        _ newItem: TodoItem,
        completion: @escaping (Result<Void, Error>) -> Void
    )

    func deleteTodoItem(
        id: String,
        completion: @escaping (Result<TodoItem, Error>) -> Void
    )

    func getTodoItem(id: String) -> TodoItem?
}
