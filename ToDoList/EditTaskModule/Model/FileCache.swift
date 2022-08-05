import Foundation

final class FileCache {
    // MARK: - Properties

    var todoItems: [TodoItem] {
        if !isDirty {
            return Array(todoItemsDict.values)
        } else {
            isDirty = false
            return Array(todoItemsDict.values.sorted {
                ($0.createdAt, $0.id) < ($1.createdAt, $1.id)
            })
        }
    }

    private var todoItemsDict: [String: TodoItem] = [:]
    private var isDirty: Bool = false

    // MARK: - Public

    func addTask(_ task: TodoItem) {
        todoItemsDict[task.id] = task
        setNeedsSort()
    }

    @discardableResult
    func deleteTask(id: String) -> TodoItem? {
        guard let value = todoItemsDict[id] else {
            return nil
        }
        todoItemsDict[id] = nil
        setNeedsSort()
        return value
    }

    func save(to file: String) {
        guard let path = getCachePath(for: file) else { return }
        do {
            let items = todoItemsDict.map { $0.value.json }
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

    func deleteCacheFile(file: String) {
        guard let path = getCachePath(for: file)
        else { return }
        do {
            print(path.absoluteString)
            try FileManager.default.removeItem(atPath: path.path)
        } catch {
            print("Unable to delete file. \(error)")
        }
    }

    // MARK: - Private

    private func getCachePath(for file: String) -> URL? {
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
