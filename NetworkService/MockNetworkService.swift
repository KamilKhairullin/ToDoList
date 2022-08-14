import Foundation

final class MockNetworkService: NetworkService {
    // MARK: - Properties

    let queue: DispatchQueue

    // MARK: - Lifecycle

    init() {
        self.queue = DispatchQueue(label: Constants.queueName)
    }

    // MARK: - Public

    func getAllTodoItems(
        completion: @escaping (Result<[TodoItem], Error>) -> Void
    ) {
        let timeout = TimeInterval.random(in: 1..<4)
        queue.asyncAfter(deadline: .now() + timeout) {
            MockNetworkService.executeCompletionOnMainThread {
                completion(.success(Constants.mockTodoItems))
            }
        }
    }

    func updateAllTodoItems(_ items: [TodoItem], completion: @escaping (Result<[TodoItem], Error>) -> Void
    ) {
        let timeout = TimeInterval.random(in: 1..<4)
        queue.asyncAfter(deadline: .now() + timeout) {
            MockNetworkService.executeCompletionOnMainThread {
                completion(.success(Constants.mockTodoItems))
            }
        }
    }

    func getTodoItem(at id: String, completion: @escaping (Result<TodoItem, Error>) -> Void
    ) {
        let timeout = TimeInterval.random(in: 1..<4)
        queue.asyncAfter(deadline: .now() + timeout) {
            MockNetworkService.executeCompletionOnMainThread {
                completion(.success(Constants.mockTodoItem))
            }
        }
    }

    func addTodoItem(_ item: TodoItem, completion: @escaping (Result<TodoItem, Error>) -> Void) {
        let timeout = TimeInterval.random(in: 1..<4)
        queue.asyncAfter(deadline: .now() + timeout) {
            MockNetworkService.executeCompletionOnMainThread {
                completion(.success(Constants.mockTodoItem))
            }
        }
    }

    func editTodoItem(_ item: TodoItem, completion: @escaping (Result<TodoItem, Error>) -> Void) {
        let timeout = TimeInterval.random(in: 1..<4)
        queue.asyncAfter(deadline: .now() + timeout) {
            MockNetworkService.executeCompletionOnMainThread {
                completion(.success(Constants.mockTodoItem))
            }
        }
    }

    func deleteTodoItem(at id: String, completion: @escaping (Result<TodoItem, Error>) -> Void) {
        let timeout = TimeInterval.random(in: 1..<4)
        queue.asyncAfter(deadline: .now() + timeout) {
            MockNetworkService.executeCompletionOnMainThread {
                completion(.success(Constants.mockTodoItem))
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

// MARK: - Nested types

extension MockNetworkService {
    enum Constants {
        static let queueName: String = "NetworkServiceQueue"
        static let mockTodoItem: TodoItem = .init(text: "Hello World", priority: .important)
        static let mockTodoItems: [TodoItem] = [
            .init(text: "I am 1", priority: .important),
            .init(text: "I am 2", priority: .ordinary),
            .init(text: "I am 3", priority: .unimportant),
            .init(text: "I am 4", priority: .important),
            .init(text: "I am 5", priority: .ordinary)
        ]
    }
}
