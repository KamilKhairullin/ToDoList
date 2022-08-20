import Foundation

protocol NetworkService: AnyObject {
    func getAllTodoItems(
        revision: Int,
        completion: @escaping (Result<ListQuery, Error>) -> Void
    )

    func updateAllTodoItems(
        revision: Int,
        _ items: [TodoItem],
        completion: @escaping (Result<ListQuery, Error>) -> Void
    )

    func getTodoItem(
        revision: Int,
        at id: String,
        completion: @escaping (Result<ElementQuery, Error>) -> Void
    )

    func addTodoItem(
        revision: Int,
        _ item: TodoItem,
        completion: @escaping (Result<ElementQuery, Error>) -> Void
    )

    func editTodoItem(
        revision: Int,
        _ item: TodoItem,
        completion: @escaping (Result<ElementQuery, Error>) -> Void
    )

    func deleteTodoItem(
        revision: Int,
        at id: String,
        completion: @escaping (Result<ElementQuery, Error>) -> Void
    )
}
