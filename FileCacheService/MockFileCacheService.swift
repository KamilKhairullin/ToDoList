import Foundation

final class MockFileCacheService: FileCacheService {
    // MARK: - Properties

    let fileCache: FileCache

    var todoItems: [TodoItem] {
        return fileCache.todoItems
    }

    // MARK: - Lifecycle

    init(fileCache: FileCache) {
        self.fileCache = fileCache
    }

    // MARK: - Public

    func save(
        to file: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        Task {
            do {
                try await self.fileCache.save(to: file)
                MockFileCacheService.executeCompletionOnMainThread {
                    completion(.success(()))
                }
            } catch let error {
                completion(.failure(error))
            }
        }
    }

    func load(
        from file: String,
        completion: @escaping (Result<[TodoItem], Error>) -> Void
    ) {
        Task {
            do {
                try await self.fileCache.load(from: file)
                MockFileCacheService.executeCompletionOnMainThread {
                    completion(.success(self.fileCache.todoItems))
                }
            } catch let error {
                completion(.failure(error))
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
