import Foundation
import SQLite

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

    private var fileManager: FileManager

    private var databaseURL: URL? {
        guard let documentDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else {
            return nil
        }
        let path = documentDirectory.appendingPathComponent(Constatns.filename)
        return path
    }

    private let todoItemsTable: Table

    // MARK: - Lifecycle

    init() {
        fileManager = .default
        todoItemsTable = Table(Constatns.tableName)
        try? initDatabase()
    }

    // MARK: - Public

    func load() throws {
        guard let databaseURL = databaseURL else {
            throw FileCacheError.invalidCachePath
        }
        let connection = try Connection(databaseURL.path)
        let objects = try connection.prepare(todoItemsTable)

        cachedTodoItems = objects.compactMap { TodoItem.parseSQL(row: $0) }
        isDirty = false
        if cachedTodoItems.isEmpty {
            throw FileCacheError.databaseEmpty
        }
    }

    func insert(_ item: TodoItem) throws {
        guard let databaseURL = databaseURL else {
            return
        }
        let connection = try Connection(databaseURL.path)
        let query = todoItemsTable.insert(item.sqlReplaceStatement)
        try connection.run(query)
        setNeedsSort()
    }

    func update(_ item: TodoItem) throws {
        guard let databaseURL = databaseURL else {
            return
        }
        let connection = try Connection(databaseURL.path)
        let filteredTable = todoItemsTable.filter(
            TodoItem.Constants.idExpression == item.id
        )
        let query = filteredTable.update(item.sqlReplaceStatement)
        try connection.run(query)
        setNeedsSort()
    }

    func delete(_ id: String) throws {
        guard let databaseURL = databaseURL else {
            throw FileCacheError.deleteFailed
        }
        let connection = try Connection(databaseURL.path)
        let filteredTable = todoItemsTable.filter(
            TodoItem.Constants.idExpression == id
        )
        let query = filteredTable.delete()
        try connection.run(query)
        setNeedsSort()
    }

    // MARK: - Private

    private func initDatabase() throws {
        guard let databaseURL = databaseURL else {
            return
        }

        if !fileManager.fileExists(atPath: databaseURL.path) {
            fileManager.createFile(atPath: databaseURL.path, contents: nil, attributes: nil)
        }

        let connection = try Connection(databaseURL.path)
        try connection.run(todoItemsTable.create(ifNotExists: true) { table in
            table.column(TodoItem.Constants.idExpression, primaryKey: true)
            table.column(TodoItem.Constants.textExpression)
            table.column(TodoItem.Constants.priorityExpression)
            table.column(TodoItem.Constants.deadlineExpression)
            table.column(TodoItem.Constants.isDoneExpression)
            table.column(TodoItem.Constants.createdAtExpression)
            table.column(TodoItem.Constants.editedAtExpression)
        })
    }

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
