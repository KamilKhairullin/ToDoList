import Foundation
import CoreData

final class FileCache {
    // MARK: - Properties

    var todoItems: [TodoItem] {
        if isDirty {
            try? load()
        }
        return cachedTodoItems
    }

    private var cachedTodoItems: [TodoItem] = []
    private var isDirty: Bool = true

    private let container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TodoItemCoreData")
        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Loading failed. \(error)")
            }
        }
        return container
    }()
    // MARK: - Lifecycle

    init() {
    }

    // MARK: - Public

    func load() throws {
        let context = container.viewContext
        let fetchRequest = NSFetchRequest<TodoItemCD>(entityName: "TodoItemCD")
        let items = try context.fetch(fetchRequest)
        self.cachedTodoItems = items.compactMap { TodoItem.init(from: $0) }
        isDirty = false
        if cachedTodoItems.isEmpty {
            throw FileCacheError.databaseEmpty
        }
    }

    func insert(_ item: TodoItem) throws {
        let context = container.viewContext
        if (try? getItem(with: item.id)) != nil {
            throw FileCacheError.itemAlreadyExists
        }

        guard
            let dbItem = NSEntityDescription.insertNewObject(
                forEntityName: "TodoItemCD",
                into: context
            ) as? TodoItemCD
        else {
            throw FileCacheError.unparsableData
        }

        dbItem.id = item.id
        dbItem.text = item.text
        dbItem.priority = TodoItemCD.Priority(from: item.priority)
        dbItem.isDone = item.isDone
        dbItem.deadline = item.deadline
        dbItem.createdAt = item.createdAt
        dbItem.editedAt = item.editedAt

        try context.save()
        setNeedsSort()
    }

    func update(_ item: TodoItem) throws {
        let context = container.viewContext

        let dbItem = try getItem(with: item.id)

        dbItem.id = item.id
        dbItem.text = item.text
        dbItem.priority = TodoItemCD.Priority(from: item.priority)
        dbItem.isDone = item.isDone
        dbItem.deadline = item.deadline
        dbItem.createdAt = item.createdAt
        dbItem.editedAt = item.editedAt

        try context.save()
        setNeedsSort()
    }

    func delete(_ id: String) throws {
        let context = container.viewContext
        let dbItem = try getItem(with: id)
        context.delete(dbItem)
        try context.save()
        setNeedsSort()
    }

    func getItem(with id: String) throws -> TodoItemCD {
        let context = container.viewContext
        let fetchRequest = NSFetchRequest<TodoItemCD>(entityName: "TodoItemCD")
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        let items = try context.fetch(fetchRequest)

        guard let item = items.first else {
            throw FileCacheError.itemNotExist
        }
        return item
    }
    // MARK: - Private

    private func setNeedsSort() {
        isDirty = true
    }
}

extension FileCache {
    enum Constatns {
        static let filename: String = "ToDoListDatabase.sqlite3"
        static let tableName: String = "TodoItems"
    }
}
