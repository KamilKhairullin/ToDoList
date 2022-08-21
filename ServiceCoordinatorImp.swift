import Foundation

final class ServiceCoordinatorImp: ServiceCoordinator {

    let networkService: NetworkService
    let fileCacheService: FileCacheService
    private var revision: Int

    init(networkService: NetworkService, fileCacheService: FileCacheService) {
        self.networkService = networkService
        self.fileCacheService = fileCacheService
        self.revision = 5
    }

    func getAllItems(completion: @escaping (Result<[TodoItem], Error>) -> Void) {
        networkService.getAllTodoItems(revision: revision) { result in
            switch result {
            case .success(let data):
                self.revision = data.revision ?? -1
                let items = data.list.map { TodoItem(from: $0) }
                
                items.forEach { self.fileCacheService.add($0) }
                completion(.success(items))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func addItem(item: TodoItem, completion: @escaping (Result<Void, Error>) -> Void) {
        networkService.addTodoItem(revision: revision, item) { [fileCacheService] result in
            switch result {
            case .success(let data):
                fileCacheService.add(TodoItem(from: data.element))
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func updateItem(item: TodoItem, completion: @escaping (Result<Void, Error>) -> Void) {
        networkService.editTodoItem(revision: revision, item) { [fileCacheService] result in
            switch result {
            case .success(let data):
                fileCacheService.delete(id: item.id)
                fileCacheService.add(TodoItem(from: data.element))
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func removeItem(at id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        networkService.deleteTodoItem(revision: revision, at: id) { [fileCacheService] result in
            switch result {
            case .success(let data):
                fileCacheService.delete(id: data.element.id)
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func merge(_ items1: [TodoItem], _ items2: [TodoItem], completion: @escaping (Result<[TodoItem], Error>) -> Void) {}
}
