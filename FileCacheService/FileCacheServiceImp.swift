import Foundation

final class FileCacheServiceImp: FileCacheService {

    // MARK: - Properties

    private let queue: DispatchQueue
    private let fileCache: FileCache

    var todoItems: [TodoItem] {
        return fileCache.todoItems
    }

    // MARK: - Lifecycle

    init(fileCache: FileCache) {
        self.queue = DispatchQueue(label: Constants.queueName)
        self.fileCache = fileCache
    }

    // MARK: - Public

    func load(
        completion: @escaping (Result<[TodoItem], Error>) -> Void
    ) {
        queue.async { [weak self] in
            guard let self = self else {
                FileCacheServiceImp.executeCompletionOnMainThread {
                    completion(.failure(FileCacheError.selfNotExist))
                }
                return
            }
            do {
                try self.fileCache.load()
                FileCacheServiceImp.executeCompletionOnMainThread {
                    completion(.success(self.fileCache.todoItems))
                }
            } catch {
                FileCacheServiceImp.executeCompletionOnMainThread {
                    completion(.failure(error))
                }
            }
        }
    }

    func addTodoItem(_ newItem: TodoItem, completion: @escaping (Result<TodoItem, Error>) -> Void) {
        queue.async { [weak self] in
            do {
                try self?.fileCache.insert(newItem)
                FileCacheServiceImp.executeCompletionOnMainThread {
                    completion(.success(newItem))
                }
            } catch {
                FileCacheServiceImp.executeCompletionOnMainThread {
                    completion(.failure(error))
                }
            }
        }
    }

    func editTodoItem(_ item: TodoItem, completion: @escaping (Result<Void, Error>) -> Void) {
        queue.async { [weak self] in
            do {
                try self?.fileCache.update(item)
                FileCacheServiceImp.executeCompletionOnMainThread {
                    completion(.success(()))
                }
            } catch {
                FileCacheServiceImp.executeCompletionOnMainThread {
                    completion(.failure(error))
                }
            }
        }
    }

    func deleteTodoItem(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        queue.async { [weak self] in
            do {
                try self?.fileCache.delete(id)
                FileCacheServiceImp.executeCompletionOnMainThread {
                    completion(.success(()))
                }
            } catch {
                FileCacheServiceImp.executeCompletionOnMainThread {
                    completion(.failure(error))
                }
            }
        }
    }

    // MARK: - Private

    private static func executeCompletionOnMainThread(_ closure: @escaping () -> Void) {
        DispatchQueue.main.async {
            closure()
        }
    }
}

extension FileCacheServiceImp {
    enum Constants {
        static let queueName: String = "FileCacheServiceQueue"
    }
}
