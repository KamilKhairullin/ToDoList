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
        self.queue = DispatchQueue(label: Constatns.queueName)
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
            } catch let error {
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
            } catch let error {
                MockFileCacheService.executeCompletionOnMainThread {
                    completion(.failure(error))
                }
            }
        }
    }

    func add(
        _ newItem: TodoItem,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        fileCache.add(newItem)
        MockFileCacheService.executeCompletionOnMainThread {
            completion(.success(()))
        }
    }

    func delete(
        id: String,
        completion: @escaping (Result<TodoItem, Error>) -> Void
    ) {
        guard let deleted = fileCache.delete(id: id) else {
            MockFileCacheService.executeCompletionOnMainThread {
                completion(.failure(FileCacheError.deleteFailed))
            }
            return
        }
        MockFileCacheService.executeCompletionOnMainThread {
            completion(.success(deleted))
        }
    }

    // MARK: - Private

    private static func executeCompletionOnMainThread(_ closure: @escaping () -> Void) {
        DispatchQueue.main.async {
            closure()
        }
    }
}

extension MockFileCacheService {
    enum Constatns {
        static let queueName: String = "FileCacheServiceQueue"
    }
}
