import Foundation

final class MockFileCacheService: FileCacheService {

    // MARK: - Properties

    let queue: DispatchQueue
    let fileCache: FileCache

    var todoItems: [TodoItem] {
        return fileCache.todoItems
    }

    // MARK: - Lifecycle

    init(fileCache: FileCache) {
        self.queue = DispatchQueue(label: Constants.queueName)
        self.fileCache = fileCache
    }

    // MARK: - Public

    func save(
        to file: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        queue.async { [weak self] in
            guard let self = self else {
                MockFileCacheService.executeCompletionOnMainThread {
                    completion(.failure(FileCacheError.selfNotExist))
                }
                return
            }
            do {
                try self.fileCache.save(to: file)
                MockFileCacheService.executeCompletionOnMainThread {
                    completion(.success(()))
                }
            } catch {
                MockFileCacheService.executeCompletionOnMainThread {
                    completion(.failure(error))
                }
            }
        }
    }

    func load(
        from file: String,
        completion: @escaping (Result<[TodoItem], Error>) -> Void
    ) {
        queue.async { [weak self] in
            guard let self = self else {
                MockFileCacheService.executeCompletionOnMainThread {
                    completion(.failure(FileCacheError.selfNotExist))
                }
                return
            }
            do {
                try self.fileCache.load(from: file)
                MockFileCacheService.executeCompletionOnMainThread {
                    completion(.success(self.fileCache.todoItems))
                }
            } catch {
                MockFileCacheService.executeCompletionOnMainThread {
                    completion(.failure(error))
                }
            }
        }
    }

    func addTodoItem(_ newItem: TodoItem) {
        self.fileCache.add(newItem)
    }

    func deleteTodoItem(id: String) -> TodoItem? {
        guard let deleted = self.fileCache.delete(id: id) else {
            return nil
        }
        return deleted
    }

    func getTodoItem(id: String) -> TodoItem? {
        return fileCache.get(id: id)
    }

    // MARK: - Private

    private static func executeCompletionOnMainThread(_ closure: @escaping () -> Void) {
        DispatchQueue.main.async {
            closure()
        }
    }
}

extension MockFileCacheService {
    enum Constants {
        static let queueName: String = "FileCacheServiceQueue"
    }
}
