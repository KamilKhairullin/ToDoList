import Foundation

protocol ServiceCoordinatorOutput: AnyObject {
    func reloadData()
    func loadingStarted()
    func loadingEnded()
}

final class ServiceCoordinatorImp: ServiceCoordinator {

    private let networkService: NetworkService
    private let fileCacheService: FileCacheService
    private let output: ServiceCoordinatorOutput
    private var revision: Int = Constants.defaultRevision
    private var isDirty = Constants.defaultIsDirty

    var numberOfLoadingItems: Int = 0 {
        didSet {
            if numberOfLoadingItems == 0 {
                output.loadingEnded()
            } else {
                output.loadingStarted()
            }
        }
    }
    var todoItems: [TodoItem] {
        return fileCacheService.todoItems
    }

    init(networkService: NetworkService, fileCacheService: FileCacheService, output: ServiceCoordinatorOutput) {
        self.networkService = networkService
        self.fileCacheService = fileCacheService
        self.output = output
        fileCacheService.load(from: Constants.filename) { [weak self] result in
            switch result {
            case .success:
                self?.sync { _ in }
            case .failure:
                self?.getAllItems { result in
                    switch result {
                    case .success(let data):
                        self?.updateLocalItems(with: data) { _ in
                            self?.sync { _ in }
                        }
                    case .failure:
                        return
                    }
                }
            }
        }
    }

    func sync(completion: @escaping (Result<Void, Error>) -> Void) {
        isDirty = false
        numberOfLoadingItems += 1
        networkService.updateAllTodoItems(revision: revision, fileCacheService.todoItems) { [weak self] result in
            switch result {
            case .success(let data):
                guard let revision = data.revision else {
                    completion(.failure(HTTPError.decodingFailed))
                    return
                }
                let list = data.list.map { TodoItem(from: $0) }
                self?.revision = revision
                self?.updateLocalItems(with: list) { _ in
                    self?.output.reloadData()
                    self?.isDirty = false
                }
                completion(.success(()))
            case .failure(let error):
                self?.isDirty = true
                completion(.failure(error))
            }
            self?.numberOfLoadingItems -= 1
        }
    }

    func getAllItems(
        completion: @escaping (Result<[TodoItem], Error>) -> Void
    ) {
        numberOfLoadingItems += 1
        networkService.getAllTodoItems(revision: revision) { [weak self] result in
            switch result {
            case .success(let data):
                guard let revision = data.revision else {
                    completion(.failure(HTTPError.decodingFailed))
                    return
                }
                let list = data.list.map { TodoItem(from: $0) }
                self?.revision = revision
                completion(.success(list))
            case .failure(let error):
                completion(.failure(error))
            }
            self?.numberOfLoadingItems -= 1
        }
    }

    func addItem(item: TodoItem, completion: @escaping (Result<Void, Error>) -> Void) {
        numberOfLoadingItems += 1
        fileCacheService.addTodoItem(item)
        output.reloadData()
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
                self?.sync { _ in }
                completion(.failure(error))
            }
            self?.numberOfLoadingItems -= 1
        }
    }

    func updateItem(item: TodoItem, completion: @escaping (Result<Void, Error>) -> Void) {
        numberOfLoadingItems += 1
        fileCacheService.addTodoItem(item)
        output.reloadData()

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
                self?.sync { _ in }
                completion(.failure(error))
            }
            self?.numberOfLoadingItems -= 1
        }
    }

    func removeItem(at id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        numberOfLoadingItems += 1
        _ = fileCacheService.deleteTodoItem(id: id)
        output.reloadData()

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
                self?.sync { _ in }
                completion(.failure(error))
            }
            self?.numberOfLoadingItems -= 1
        }
    }

    // MARK: - Private
    private func updateLocalItems(with remoteItems: [TodoItem], completion: @escaping (Result<Void, Error>) -> Void) {
        fileCacheService.todoItems.forEach {
            _ = fileCacheService.deleteTodoItem(id: $0.id)
        }
        remoteItems.forEach {
            fileCacheService.addTodoItem($0)
        }
        fileCacheService.save(to: Constants.filename) { _ in
            completion(.success(()))
        }
    }
}

extension ServiceCoordinatorImp {
    enum Constants {
        static let filename: String = "savedCache.json"
        static let defaultRevision: Int = -1
        static let defaultIsDirty: Bool = false
    }
}
