import UIKit

final class TaskListModuleHeaderView: UIView {
    // MARK: - Properties

    private let output: TaskListModuleViewOutput?

    private lazy var doneAmountLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.doneAmountLabelTitle
        label.textColor = ColorPalette.tertiary
        label.font = FontPalette.subhead
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var hideDoneButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(ColorPalette.blue, for: .normal)
        button.titleLabel?.font = FontPalette.subhead
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(hideDoneButtonPressed(sender:)), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle

    init(output: TaskListModuleViewOutput?) {
        self.output = output
        super.init(frame: .zero)
        setupDoneAmountLabel()
        setupHideDoneButton()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public

    func setHideDoneButtonText(isHidden: Bool) {
        let title = isHidden ? Constants.hiddenDoneTitle : Constants.shownDoneTitle
        hideDoneButton.setTitle(title, for: .normal)
    }

    func setDoneAmountLabelNumber(number: Int) {
        doneAmountLabel.text = "\(Constants.doneAmountLabelTitle)\(number)"
    }

    // MARK: - Selectors

    @objc private func hideDoneButtonPressed(sender: UIButton) {
        output?.hideDonePressed()
    }

    // MARK: - Private

    private func setupDoneAmountLabel() {
        addSubview(doneAmountLabel)
        NSLayoutConstraint.activate([
            doneAmountLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: Insets.doneAmountLabelInsets.left
            ),
            doneAmountLabel.topAnchor.constraint(equalTo: topAnchor),
            doneAmountLabel.heightAnchor.constraint(equalToConstant: Constants.doneAmountLabelHeight)
        ])
    }

    private func setupHideDoneButton() {
        addSubview(hideDoneButton)

        NSLayoutConstraint.activate([
            hideDoneButton.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: Insets.hideDoneButtonInsets.right
            ),
            hideDoneButton.topAnchor.constraint(equalTo: topAnchor),
            hideDoneButton.heightAnchor.constraint(equalToConstant: Constants.hideDoneButtonHeight)
        ])
    }
}

// MARK: - Nested types

extension TaskListModuleHeaderView {
    enum Insets {
        static let doneAmountLabelInsets: UIEdgeInsets = .init(top: 0, left: 16, bottom: 0, right: 0)
        static let hideDoneButtonInsets: UIEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: -16)
    }

    enum Constants {
        static let doneAmountLabelHeight: CGFloat = 20
        static let hideDoneButtonHeight: CGFloat = 20
        static let doneAmountLabelTitle: String = "Выполнено - "
        static let hiddenDoneTitle: String = "Показать"
        static let shownDoneTitle: String = "Скрыть"
    }
}
