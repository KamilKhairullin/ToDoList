import Foundation

protocol ServiceCoordinator {

    var todoItems: [TodoItem] { get }

    func addItem(
        item: TodoItem,
        completion: @escaping (Result<Void, Error>) -> Void
    )

    func updateItem(
        item: TodoItem,
        completion: @escaping (Result<Void, Error>) -> Void
    )

    func removeItem(
        at id: String,
        completion: @escaping (Result<Void, Error>) -> Void
    )
}
