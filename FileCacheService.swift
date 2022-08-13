import Foundation

protocol FileCacheService: AnyObject {

    var todoItems: [TodoItem] { get }

    func save(
        to file: String,
        completion: @escaping (Result<Void, FileCacheError>) -> Void
    )

    func load(
        from file: String,
        completion: @escaping (Result<[TodoItem], FileCacheError>) -> Void
    )

    func add(
        _ newItem: TodoItem,
        completion: @escaping (Result<Void, FileCacheError>) -> Void
    )

    func delete(
        id: String,
        completion: @escaping (Result<TodoItem, FileCacheError>) -> Void
    )
}
