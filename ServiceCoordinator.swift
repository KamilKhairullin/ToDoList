import Foundation

protocol ServiceCoordinator {
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
//
//    func merge(
//        _ items1: [TodoItem],
//        _ items2: [TodoItem],
//        completion: @escaping (Result<[TodoItem], Error>) -> Void
//    )
}
