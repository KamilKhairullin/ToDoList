import Foundation

final class FileCache {
    // MARK: - Properties

    private(set) var todoItems: [String: TodoItem] = [:]
    private var isDirty: Bool = false

    // MARK: - Public

    func addTask(_ task: TodoItem) {
        todoItems[task.id] = task
        setNeedsOrder()
    }

    func deleteTask(id: String) -> TodoItem? {
        guard let value = todoItems[id] else {
            return nil
        }
        todoItems[id] = nil
        setNeedsOrder()
        return value
    }

    func save(to file: String) {
        guard let path = getCachePath(for: file) else { return }
        do {
            let items = todoItems.map { $0.value.json }
            let json = try JSONSerialization.data(withJSONObject: items, options: [])
            try json.write(to: path, options: [])
        } catch let jsonError as NSError {
            print("Error while saving to json: \(jsonError)")
        }
    }

    func load(from file: String) {
        guard let path = getCachePath(for: file),
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
            todoItems = [:]
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

    private func getCachePath(for file: String) -> URL? {
        guard let cachePath = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first
        else { return nil }
        return cachePath.appendingPathComponent(file)
    }

    private func setNeedsOrder() {
        isDirty = true
    }

    private func orderIfNeeded() -> [TodoItem] {
        if !isDirty {
            return Array(todoItems.values)
        } else {
            isDirty = false
            return Array(todoItems.values.sorted {
                $0.createdAt < $1.createdAt
            })
        }
    }
}
