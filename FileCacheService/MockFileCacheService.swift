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

    func save(to file: String) throws {
        Task {
            try await self.fileCache.save(to: file)
        }
    }

    @discardableResult
    func load(from file: String) throws -> [TodoItem] {
        Task {
            try await self.fileCache.load(from: file)
        }
        return fileCache.todoItems
    }

    func add(_ newItem: TodoItem) throws {
        fileCache.add(newItem)
    }

    func delete(id: String) throws -> TodoItem {
        guard let deleted = fileCache.delete(id: id) else {
            throw FileCacheError.deleteFailed
        }
        return deleted
    }

    // MARK: - Private

    private static func executeCompletionOnMainThread(_ closure: @escaping () -> Void) {
        DispatchQueue.main.async {
            closure()
        }
    }
}
