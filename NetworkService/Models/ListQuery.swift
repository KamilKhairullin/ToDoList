import Foundation

struct ListQuery: Codable {
    // MARK: - Properties

    let status: String
    let list: [NetworkTodoItem]
    let revision: Int?

    // MARK: - Lifecycle

    init(
        status: String = Constants.statusDefaultValue,
        list: [NetworkTodoItem],
        revision: Int? = nil
    ) {
        self.status = status
        self.list = list
        self.revision = revision
    }
}

extension ListQuery {
    enum Constants {
        static let statusDefaultValue = "ok"
    }
}
