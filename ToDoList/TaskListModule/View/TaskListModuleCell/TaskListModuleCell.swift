import Foundation
import UIKit

final class TaskListModuleCell: UITableViewCell {
    // MARK: - Properties

    static let reuseIdentifier = "TaskListModuleCell"

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 12
        return stackView
    }()

    private lazy var completeButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: Constants.buttonImageName)
        button.setImage(image, for: .normal)
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

extension TaskListModuleCell {
    enum Constants {
        static let accessoryImageName: String = "CellAccessory"
        static let buttonImageName: String = "taskButtonNormalState"
    }

    enum Insets {
        static let stackInsets: UIEdgeInsets = .init(top: 0, left: 16, bottom: 0, right: 0)
    }
}
