import Foundation

struct NetworkItemResponse: Codable {
    // MARK: - Properties

    let status: String
    let element: NetworkTodoItem
    let revision: Int32?

    // MARK: - Lifecycle

    init(
        status: String,
        element: NetworkTodoItem,
        revision: Int32?
    ) {
        self.status = status
        self.element = element
        self.revision = revision
    }
}
