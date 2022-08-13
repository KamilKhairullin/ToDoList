import Foundation
import UIKit

final class TaskListModuleTaskCell: UITableViewCell {
    // MARK: - Properties

    static let reuseIdentifier = "TaskListModuleTaskCell"

    private var output: TaskListModuleViewOutput?

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = Constants.stackSpacing
        return stackView
    }()

    private lazy var completeButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(completeButtonPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var cellAccessoryImageView: UIImageView = {
        let image = UIImage(named: Constants.accessoryImageName)
        let imageView = UIImageView(image: image)
        return imageView
    }()

    private lazy var cellContentStackView: CellContentStackView = {
        let cellContentStackView = CellContentStackView()
        cellContentStackView.translatesAutoresizingMaskIntoConstraints = false
        return cellContentStackView
    }()
    // MARK: - Lifecycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupStackView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Selectors

    @objc private func completeButtonPressed() {
        // Мне кажется, так делать плохо. Но, я не придумал как сделать по-другому.
        let tableView = superview?.superview as? UITableView
        output?.completeButtonPressed(indexPath: tableView?.indexPath(for: self))
    }

    // MARK: - Private

    private func setupView() {
        self.accessoryView = cellAccessoryImageView
        contentView.clipsToBounds = true
        self.backgroundColor = ColorPalette.secondaryBackgroundColor
    }

    private func setupStackView() {
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(completeButton)
        stackView.addArrangedSubview(cellContentStackView)
        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: Insets.stackInsets.left),
            stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: Insets.stackInsets.right),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Insets.stackInsets.top),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: Insets.stackInsets.bottom)
        ])
    }
}

// MARK: - Nested types

extension TaskListModuleTaskCell {
    enum Constants {
        static let stackSpacing: CGFloat = 12
        static let accessoryImageName: String = "CellAccessory"
        static let taskButtonCompletedImageName = "taskButtonCompletedState"
        static let taskButtonNormalImageName = "taskButtonNormalState"
        static let taskButtonOverdueImageName = "taskButtonOverdueState"
    }

    enum Insets {
        static let stackInsets: UIEdgeInsets = .init(top: 0, left: 16, bottom: 0, right: 0)
    }
}

// MARK: - TaskListModuleTaskCellConfigurable extension

extension TaskListModuleTaskCell: TaskListModuleTaskCellConfigurable {
    func configure(with data: TaskListTableViewCellData) {
        switch data {
        case .taskCell(let data):
            output = data.output
            cellContentStackView.contentTitleStack.setLabelText(data.text, isStrikethrough: data.isDone)
            cellContentStackView.contentSubtitleStack.isHidden = data.hideSubtitle
            data.deadlineString.flatMap {
                cellContentStackView.contentSubtitleStack.setDateLabel(text: $0.description)
            }
            if let priorityImageName = data.priorityImageName {
                cellContentStackView.contentTitleStack.setPriorityImage(name: priorityImageName)
                cellContentStackView.contentTitleStack.setPriorityImageVisibility(isHidden: false)
            } else {
                cellContentStackView.contentTitleStack.setPriorityImageVisibility(isHidden: true)
            }
            let image: UIImage?
            if data.isDone {
                image = UIImage(named: Constants.taskButtonCompletedImageName)
            } else if data.isOverdue {
                image = UIImage(named: Constants.taskButtonOverdueImageName)
            } else {
                image = UIImage(named: Constants.taskButtonNormalImageName)
            }
            completeButton.setImage(image, for: .normal)
        case .createNewTaskCell:
            break
        }
    }
}
