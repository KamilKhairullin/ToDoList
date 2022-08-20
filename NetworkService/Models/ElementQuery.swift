import Foundation

struct ElementQuery: Codable {
    // MARK: - Properties

    let status: String
    let element: NetworkTodoItem
    let revision: Int32?

    // MARK: - Lifecycle

    init(
        status: String = Constants.statusDefaultValue,
        element: NetworkTodoItem,
        revision: Int32?
    ) {
        self.status = status
        self.element = element
        self.revision = revision
    }
}

extension ElementQuery {
    enum Constants {
        static let statusDefaultValue = "ok"
    }
}
