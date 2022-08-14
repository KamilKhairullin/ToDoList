import Foundation

protocol FileCacheService: AnyObject {

    var todoItems: [TodoItem] { get }

    func save(to file: String) throws

    func load(from file: String) throws -> [TodoItem]

    func add(_ newItem: TodoItem) throws

    func delete(id: String) throws -> TodoItem
}
