import Foundation
import UIKit

final class TaskListCreateNewTaskCell: UITableViewCell {
    // MARK: - Properties

    static let reuseIdentifier = "TaskListCreateNewTaskCell"

    private lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = ColorPalette.tertiary
        label.font = FontPalette.body
        label.text = Constants.labelText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Lifecycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private

    private func setupView() {
        contentView.clipsToBounds = true
        self.backgroundColor = ColorPalette.secondaryBackgroundColor
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: Insets.labelInsets.left),
            label.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: Insets.labelInsets.right),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Insets.labelInsets.top),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: Insets.labelInsets.bottom)
        ])
    }
}

// MARK: - Nested types

extension TaskListCreateNewTaskCell {
    enum Constants {
        static let labelText: String = "Новое"
    }

    enum Insets {
        static let labelInsets: UIEdgeInsets = .init(top: 17, left: 53, bottom: -17, right: 0)
    }
}

// MARK: - TaskListModuleTaskCellConfigurable extension

extension TaskListCreateNewTaskCell: TaskListModuleTaskCellConfigurable {
    func configure(with data: TaskListTableViewCellData) {
        return
    }
}
