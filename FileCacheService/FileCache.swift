import Foundation

final class FileCache {
    // MARK: - Properties

    var todoItems: [TodoItem] {
        if isDirty {
            orderedTodoItems = todoItemsDict.values.sorted {
                ($0.createdAt, $0.id) < ($1.createdAt, $1.id)
            }
            isDirty = false
        }
        return orderedTodoItems
    }

    private var todoItemsDict: [String: TodoItem] = [:]
    private var orderedTodoItems: [TodoItem] = []
    private var isDirty: Bool = true

    // MARK: - Lifecycle

    init() {}

    // MARK: -

    func add(_ task: TodoItem) {
        todoItemsDict[task.id] = task
        setNeedsSort()
    }

    @discardableResult
    func delete(id: String) -> TodoItem? {
        setNeedsSort()
        return todoItemsDict.removeValue(forKey: id)
    }

    func get(id: String) -> TodoItem? {
        return todoItemsDict[id]
    }
    
    func save(to file: String) throws {
        guard let path = cachePath(for: file) else {
            throw FileCacheError.invalidCachePath
        }
        let items = todoItemsDict.map { $0.value.json }
        let json = try JSONSerialization.data(withJSONObject: items, options: [])
        try json.write(to: path, options: [])
    }

    func load(from file: String) throws {
        guard let path = cachePath(for: file) else {
            throw FileCacheError.invalidCachePath
        }

        let data = try Data(contentsOf: path)
        let json = try JSONSerialization.jsonObject(with: data, options: [])

        guard let objects = json as? [Any] else {
            throw FileCacheError.unparsableData
        }

        let deserializedItems = objects.compactMap { TodoItem.parse(json: $0) }
        todoItemsDict = deserializedItems.reduce(into: [:]) { result, current in
            result[current.id] = current
        }
        isDirty = true
    }

    // MARK: - Private

    private func cachePath(for file: String) -> URL? {
        guard let cachePath = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first
        else {
            print("Unable to find cache directory")
            return nil
        }
        return cachePath.appendingPathComponent(file)
    }

    private func setNeedsSort() {
        isDirty = true
    }
}
