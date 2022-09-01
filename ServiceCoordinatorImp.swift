import Foundation

protocol ServiceCoordinatorOutput: AnyObject {
    func reloadData()
    func loadingStarted()
    func loadingEnded()
}

final class ServiceCoordinatorImp: ServiceCoordinator {
    // MARK: - Properties

    private let networkService: NetworkService
    private let fileCacheService: FileCacheService
    private let output: ServiceCoordinatorOutput
    private var revision: Int = Constants.defaultRevision
    private var isDirty = Constants.defaultIsDirty {
        didSet {
            if isDirty == true {
                self.sync { _ in }
            }
        }
    }

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

    // MARK: - Lifecycle

    init(networkService: NetworkService, fileCacheService: FileCacheService, output: ServiceCoordinatorOutput) {
        self.networkService = networkService
        self.fileCacheService = fileCacheService
        self.output = output
        fileCacheService.load { [weak self] result in
            switch result {
            case .success:
                self?.sync { _ in }
            case .failure:
                self?.loadAndSync()
            }
        }
    }

    // MARK: - Public

    func getAllItems(
        completion: @escaping (Result<[TodoItem], Error>) -> Void
    ) {
        loadingWillStart()
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
            self?.loadingWillEnd()
        }
    }

    func addItem(item: TodoItem, completion: @escaping (Result<Void, Error>) -> Void) {
        loadingWillStart()
        fileCacheService.addTodoItem(item) { [weak self] _ in
            self?.output.reloadData()
        }

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
            self?.loadingWillEnd()
        }
    }

    func updateItem(item: TodoItem, completion: @escaping (Result<Void, Error>) -> Void) {
        loadingWillStart()
        fileCacheService.editTodoItem(item) { [weak self] _ in
            self?.output.reloadData()
        }

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
            self?.loadingWillEnd()
        }
    }

    func removeItem(at id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        loadingWillStart()
        fileCacheService.deleteTodoItem(id: id) { [weak self] _ in
            self?.output.reloadData()
        }

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
            self?.loadingWillEnd()
        }
    }

    // MARK: - Private

    private func loadAndSync() {
        getAllItems { [weak self] result in
            switch result {
            case .success(let data):
                for (index, item) in data.enumerated() {
                    self?.fileCacheService.addTodoItem(item) { _ in
                        if index == data.lastIndex(where: { _ in true }) {
                            self?.sync { _ in }
                        }
                    }
                }
            case .failure:
                return
            }
        }
    }

    private func sync(completion: @escaping (Result<Void, Error>) -> Void) {
        loadingWillStart()

        networkService.updateAllTodoItems(
            revision: revision,
            fileCacheService.todoItems
        ) { [weak self] result in
            switch result {
            case .success(let data):
                guard let revision = data.revision else {
                    completion(.failure(HTTPError.decodingFailed))
                    return
                }
                let list = data.list.map { TodoItem(from: $0) }
                self?.revision = revision
                for (index, item) in list.enumerated() {
                    self?.fileCacheService.editTodoItem(item) { _ in
                        if index == list.lastIndex(where: { _ in true }) {
                            self?.output.reloadData()
                            self?.isDirty = false
                        }
                    }
                }
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
            self?.loadingWillEnd()
        }
    }

    private func loadingWillStart() {
        self.numberOfLoadingItems += 1
    }

    private func loadingWillEnd() {
        self.numberOfLoadingItems -= 1
    }
}

// MARK: - Nested types

extension ServiceCoordinatorImp {
    enum Constants {
        static let defaultRevision: Int = -1
        static let defaultIsDirty: Bool = false
    }
}
