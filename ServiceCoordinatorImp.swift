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
                    return
                case .failure(let error):
                    print(error)
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
        if isDirty {
            isDirty = false
            networkService.getAllTodoItems(revision: revision) { result in
                switch result {
                case .success(let data):
                    guard let revision = data.revision else {
                        completion(.failure(HTTPError.decodingFailed))
                        return
                    }
                    let list = data.list.map { TodoItem(from: $0) }
                    self.revision = revision
                    self.updateLocalItems(with: list)
                    self.isDirty = false
                    self.output.reloadData()
                case .failure(let error):
                    self.isDirty = true
                    completion(.failure(error))
                }
            }
        }
    }

    func addItem(item: TodoItem, completion: @escaping (Result<Void, Error>) -> Void) {
        self.fileCacheService.addTodoItem(item) { _ in }
        self.fileCacheService.save(to: Constants.filename) { _ in }
        self.output.reloadData()

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
        self.fileCacheService.deleteTodoItem(id: item.id) { _ in }
        self.fileCacheService.addTodoItem(item) { _ in }
        self.fileCacheService.save(to: Constants.filename) { _ in }
        output.reloadData()

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
        self.fileCacheService.deleteTodoItem(id: id) { _ in }
        self.fileCacheService.save(to: Constants.filename) { _ in }
        self.output.reloadData()

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
        for remoteItem in remoteItems {
            guard
                let localItem = fileCacheService.getTodoItem(id: remoteItem.id),
                let editedLocal = localItem.editedAt,
                let editedRemote = remoteItem.editedAt
            else {
                fileCacheService.addTodoItem(remoteItem) { _ in }
                continue
            }
            if editedLocal < editedRemote {
                fileCacheService.addTodoItem(remoteItem) { _ in }
            }
        }

        let toDelete = fileCacheService.todoItems.filter { item in
            !remoteItems.contains(where: { item.id == $0.id })
        }
        toDelete.forEach {
            fileCacheService.deleteTodoItem(id: $0.id) { _ in }
        }
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
