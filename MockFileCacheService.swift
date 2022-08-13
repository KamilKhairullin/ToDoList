import Foundation

final class MockFileCacheService: FileCacheService {
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

    // MARK: - Lifecycle

    init() {}

    // MARK: - Public

    func save(
        to file: String,
        completion: @escaping (Result<Void, FileCacheError>) -> Void
    ) {
        guard let path = cachePath(for: file) else {
            completion(.failure(FileCacheError.invalidCachePath))
            return
        }

        DispatchQueue.main.async { [weak self] in
            do {
                guard let self = self else {
                    completion(.failure(FileCacheError.selfNotExist))
                    return
                }
                let items = self.todoItemsDict.map { $0.value.json }
                let json = try JSONSerialization.data(withJSONObject: items, options: [])
                try json.write(to: path, options: [])
                completion(.success(()))
            } catch {
                completion(.failure(FileCacheError.saveFailed))
            }
        }
    }

    func load(
        from file: String,
        completion: @escaping (Result<[TodoItem], FileCacheError>) -> Void
    ) {
        guard let path = cachePath(for: file),
              let data = try? Data(contentsOf: path)
        else {
            completion(.failure(FileCacheError.invalidCachePath))
            return
        }

        DispatchQueue.main.async { [weak self] in
            do {
                guard let self = self,
                      let objects = try JSONSerialization.jsonObject(with: data, options: []) as? [Any]
                else {
                    completion(.failure(FileCacheError.selfNotExist))
                    return
                }
                self.todoItemsDict = [:]
                for object in objects {
                    if let todoItem = TodoItem.parse(json: object) {
                        self.add(todoItem) { result in
                            switch result {
                            case .success:
                                completion(.success(self.todoItems))
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                    }
                }
            } catch {
                print("Error while converting from json")
            }
        }
    }

    func add(
        _ newItem: TodoItem,
        completion: @escaping (Result<Void, FileCacheError>) -> Void
    ) {
        todoItemsDict[newItem.id] = newItem
        setNeedsSort()
        completion(.success(()))
    }

    func delete(
        id: String,
        completion: @escaping (Result<TodoItem, FileCacheError>) -> Void
    ) {
        setNeedsSort()
        if let removed = todoItemsDict.removeValue(forKey: id) {
            completion(.success(removed))
        } else {
            completion(.failure(FileCacheError.deleteFailed))
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
