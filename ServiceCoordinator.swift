import Foundation

protocol ServiceCoordinator {

    var todoItems: [TodoItem] { get }

    func sync(
        completion: @escaping (Result<Void, Error>) -> Void
    )

    func getAllItems(
        completion: @escaping (Result<[TodoItem], Error>) -> Void
    )

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
