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
    private var isDirty: Bool = false

    // MARK: - Public

    func addTask(_ task: TodoItem) {
        todoItemsDict[task.id] = task
        setNeedsSort()
    }

    @discardableResult
    func deleteTask(id: String) -> TodoItem? {
        setNeedsSort()
        return todoItemsDict.removeValue(forKey: id)
    }

    func save(to file: String) {
        guard let path = cachePath(for: file) else { return }
        do {
            let items = todoItemsDict.map { $0.value.json }
            let json = try JSONSerialization.data(withJSONObject: items, options: [])
            try json.write(to: path, options: [])
        } catch let jsonError as NSError {
            print("Error while saving to json: \(jsonError)")
        }
    }

    func load(from file: String) {
        guard let path = cachePath(for: file),
              let data = try? Data(contentsOf: path)
        else {
            print("Unable to load data from \(file)")
            return
        }

        do {
            guard let objects = try JSONSerialization.jsonObject(with: data, options: []) as? [Any]
            else {
                print("Unable to cast from jsonObject to [Any]")
                return
            }
            todoItemsDict = [:]
            for object in objects {
                if let todoItem = TodoItem.parse(json: object) {
                    addTask(todoItem)
                }
            }
        } catch let jsonError as NSError {
            print("Error while converting from json: \(jsonError)")
        }
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
