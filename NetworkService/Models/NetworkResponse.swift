import Foundation

struct NetworkResponse: Codable {
    // MARK: - Properties

//    let status: String
    let list: [NetworkTodoItem]
    let revision: Int32?

    // MARK: - Lifecycle

    init(
        status: String,
        list: [NetworkTodoItem],
        revision: Int32? = nil
    ) {
//        self.status = status
        self.list = list
        self.revision = revision
    }
}
