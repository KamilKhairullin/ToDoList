import Foundation

final class ServiceCoordinatorImp: ServiceCoordinator {
    private let networkService: NetworkService
    private let fileCacheService: FileCacheService
    private let output: ServiceCoordinatorOutput
    private var revision: Int = -1
    private var isDirty = true

    var todoItems: [TodoItem] {
        if isDirty {
            sync { result in
                switch result {
                case .success:
                    self.isDirty = false
                case .failure:
                    self.isDirty = true
                }
            }
        }
        return fileCacheService.todoItems
    }

    init(networkService: NetworkService, fileCacheService: FileCacheService, output: ServiceCoordinatorOutput) {
        self.networkService = networkService
        self.fileCacheService = fileCacheService
        self.output = output
        fileCacheService.load(from: Constants.filename) { _ in }
    }

    func sync(completion: @escaping (Result<Void, Error>) -> Void) {
        isDirty = false
        networkService.updateAllTodoItems(revision: revision, fileCacheService.todoItems) { result in
            switch result {
            case .success(let data):
                guard let revision = data.revision else {
                    completion(.failure(HTTPError.decodingFailed))
                    return
                }
                let list = data.list.map { TodoItem(from: $0) }
                self.revision = revision
                self.updateLocalItems(with: list)
                self.output.reloadData()
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func getAllItems(
        completion: @escaping (Result<[TodoItem], Error>) -> Void
    ) {
        networkService.getAllTodoItems(revision: revision) { result in
            switch result {
            case .success(let data):
                guard let revision = data.revision else {
                    completion(.failure(HTTPError.decodingFailed))
                    return
                }
                let list = data.list.map { TodoItem(from: $0) }
                self.revision = revision
                completion(.success(list))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func addItem(item: TodoItem, completion: @escaping (Result<Void, Error>) -> Void) {
        fileCacheService.addTodoItem(item) { [weak self] _ in
            self?.output.reloadData()
        }
        fileCacheService.save(to: Constants.filename) { _ in }

        networkService.addTodoItem(revision: revision, item) { [weak self] result in
            switch result {
            case .success(let data):
                guard let revision = data.revision else {
                    completion(.failure(HTTPError.decodingFailed))
                    return
                }
                self?.revision = revision
                completion(.success(()))
            case .failure(let error):
                self?.isDirty = true
                completion(.failure(error))
            }
        }
    }

    func updateItem(item: TodoItem, completion: @escaping (Result<Void, Error>) -> Void) {
        fileCacheService.addTodoItem(item) { [weak self] _ in
            self?.output.reloadData()
        }

        fileCacheService.save(to: Constants.filename) { _ in }

        networkService.editTodoItem(revision: revision, item) { [weak self] result in
            switch result {
            case .success(let data):
                guard let revision = data.revision else {
                    completion(.failure(HTTPError.decodingFailed))
                    return
                }
                self?.revision = revision
                completion(.success(()))
            case .failure(let error):
                self?.isDirty = true
                completion(.failure(error))
            }
        }
    }

    func removeItem(at id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        fileCacheService.deleteTodoItem(id: id) { [weak self] _ in
            self?.output.reloadData()
        }

        fileCacheService.save(to: Constants.filename) { _ in }

        networkService.deleteTodoItem(revision: revision, at: id) { [weak self] result in
            switch result {
            case .success(let data):
                guard let revision = data.revision else {
                    completion(.failure(HTTPError.decodingFailed))
                    return
                }
                self?.revision = revision
                completion(.success(()))
            case .failure(let error):
                self?.isDirty = true
                completion(.failure(error))
            }
        }
    }

    func merge(_ items1: [TodoItem], _ items2: [TodoItem], completion: @escaping (Result<[TodoItem], Error>) -> Void) {}

    // MARK: - Private

    private func updateLocalItems(with remoteItems: [TodoItem]) {
        fileCacheService.todoItems.forEach {
            fileCacheService.deleteTodoItem(id: $0.id) { _ in }
        }
        remoteItems.forEach {
            fileCacheService.addTodoItem($0) { _ in }
        }
        fileCacheService.save(to: Constants.filename) { _ in }
    }
}

protocol ServiceCoordinatorOutput: AnyObject {
    func reloadData()
}

extension ServiceCoordinatorImp {
    enum Constants {
        static let filename: String = "savedCache.json"
    }
}
