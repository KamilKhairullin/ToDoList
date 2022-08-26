import Foundation
import UIKit

protocol TaskListModuleViewInput: AnyObject {
    func reloadData()
    func startAnimatingActivityIndicator()
    func stopAnimatingActivityIndicator()
}

protocol TaskListModuleViewOutput: AnyObject {
    func cellData(_ indexPath: IndexPath) -> TaskListTableViewCellData
    func plusButtonPressed()
    func rowsNumber() -> Int
    func rowHeight(forIndexPath indexPath: IndexPath, lineWidth: Int) -> Int
    func selectRowAt(indexPath: IndexPath, on viewController: UIViewController)
    func completeButtonPressed(indexPath: IndexPath?)
    func deleteSwipe(indexPath: IndexPath)
    func hideDonePressed()
    func hideDoneButtonState() -> Bool
    func numberOfDoneItems() -> Int
    func preview(indexPath: IndexPath) -> UIViewController
    func lastRowIndex() -> Int
}

final class TaskListModuleViewController: UIViewController {
    // MARK: - Properties

    private var output: TaskListModuleViewOutput

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(TaskListModuleTaskCell.self, forCellReuseIdentifier: TaskListModuleTaskCell.reuseIdentifier)
        tableView.register(
            TaskListCreateNewTaskCell.self,
            forCellReuseIdentifier: TaskListCreateNewTaskCell.reuseIdentifier
        )
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = ColorPalette.backgroundColor
        return tableView
    }()

    private lazy var headerView: TaskListModuleHeaderView = {
        let header = TaskListModuleHeaderView(output: output)
        return header
    }()

    private lazy var plusButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: Constants.plusButtonImageName)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.shadowColor = ColorPalette.buttonShadow.cgColor
        button.layer.shadowRadius = PlusButtonStyle.shadowRadius
        button.layer.shadowOpacity = PlusButtonStyle.opacity
        button.layer.shadowOffset = PlusButtonStyle.shadowOffset
        button.addTarget(self, action: #selector(plusButtonPressed), for: .touchUpInside)
        return button
    }()

    private lazy var activityIndicator = UIActivityIndicatorView(style: .medium)
    // MARK: - Lifecycle

    init(output: TaskListModuleViewOutput) {
        self.output = output
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupPlusButton()
        setupActivityIndicator()
    }

    // MARK: - Selectors

    @objc private func plusButtonPressed() {
        output.plusButtonPressed()
    }

    // MARK: - Private

    private func setupTableView() {
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(
                equalTo: view.layoutMarginsGuide.topAnchor,
                constant: Insets.tableViewInsets.top
            ),
            tableView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor,
                constant: Insets.tableViewInsets.bottom
            ),
            tableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Insets.tableViewInsets.left
            ),
            tableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: Insets.tableViewInsets.right
            )
        ])
    }

    private func setupPlusButton() {
        view.addSubview(plusButton)

        NSLayoutConstraint.activate([
            plusButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: Insets.plusButtonInsets.bottom),
            plusButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            plusButton.widthAnchor.constraint(equalToConstant: Constants.plusButtonSideSize.width),
            plusButton.heightAnchor.constraint(equalToConstant: Constants.plusButtonSideSize.height)
        ])
    }

    private func setupActivityIndicator() {
        let activityIndicatorButtonItem = UIBarButtonItem(customView: activityIndicator)
        navigationItem.setRightBarButton(activityIndicatorButtonItem, animated: false)
        activityIndicator.isHidden = true
    }

    private func makeDoneAction(indexPath: IndexPath) -> UIContextualAction {
        let doneAction = UIContextualAction(
            style: .normal,
            title: nil
        ) { [weak self] _, _, completion in
            self?.output.completeButtonPressed(indexPath: indexPath)
            completion(true)
        }
        doneAction.image = UIImage(named: Constants.doneSwipeImageName)
        doneAction.backgroundColor = ColorPalette.green
        return doneAction
    }

    private func makeInfoAction(indexPath: IndexPath) -> UIContextualAction {
        let doneAction = UIContextualAction(
            style: .normal,
            title: nil
        ) { _, _, completion in
            completion(true)
        }
        doneAction.image = UIImage(named: Constants.infoSwipeImageName)
        doneAction.backgroundColor = ColorPalette.grayLight
        return doneAction
    }

    private func makeDeleteAction(indexPath: IndexPath) -> UIContextualAction {
        let doneAction = UIContextualAction(
            style: .normal,
            title: nil
        ) { [weak self] _, _, completion in
            self?.output.deleteSwipe(indexPath: indexPath)
            completion(true)
        }
        doneAction.image = UIImage(named: Constants.deleteSwipeImageName)
        doneAction.backgroundColor = ColorPalette.red
        return doneAction
    }
}

// MARK: - UITableViewDataSource extension

extension TaskListModuleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        output.rowsNumber()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = output.cellData(indexPath)
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: data.reuseIdentifier,
                for: indexPath
            ) as? UITableViewCell & TaskListModuleTaskCellConfigurable
        else {
            return UITableViewCell()
        }

        cell.separatorInset = Insets.cellSeparatorInsets
        cell.configure(with: data)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let lineWidth = Int(tableView.bounds.width - Insets.cellSeparatorInsets.left)
        return CGFloat(
            output.rowHeight(forIndexPath: indexPath, lineWidth: lineWidth)
        )
    }
}

// MARK: - UITableViewDelegate extension

extension TaskListModuleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.sectionHeaderHeight
    }

    func tableView(
        _ tableView: UITableView,
        leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        guard indexPath.row != output.lastRowIndex() else {
            return nil
        }
        let doneAction = makeDoneAction(indexPath: indexPath)
        return UISwipeActionsConfiguration(actions: [doneAction])
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        guard indexPath.row != output.lastRowIndex() else {
            return nil
        }
        let infoAction = makeInfoAction(indexPath: indexPath)
        let deleteAction = makeDeleteAction(indexPath: indexPath)

        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction, infoAction])
        swipeConfiguration.performsFirstActionWithFullSwipe = true
        return swipeConfiguration
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        output.selectRowAt(indexPath: indexPath, on: self)
    }

    func tableView(
        _ tableView: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard indexPath.row != output.lastRowIndex() else {
            return nil
        }
        let configuration = UIContextMenuConfiguration(
            identifier: indexPath as NSCopying,
            previewProvider: {
                return self.output.preview(indexPath: indexPath)
            }, actionProvider: { _ in
                return nil
            }
        )

        return configuration
    }

    func tableView(
        _ tableView: UITableView,
        willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration,
        animator: UIContextMenuInteractionCommitAnimating
    ) {
        guard let indexPath = configuration.identifier as? IndexPath
        else { return }
        animator.addCompletion {
            self.output.selectRowAt(indexPath: indexPath, on: self)
        }
    }
}

// MARK: - TaskListModuleViewInput extension

extension TaskListModuleViewController: TaskListModuleViewInput {
    func startAnimatingActivityIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }

    func stopAnimatingActivityIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }

    func reloadData() {
        tableView.reloadData()
        let buttonState = output.hideDoneButtonState()
        let numberOfDoneItems = output.numberOfDoneItems()

        headerView.setHideDoneButtonText(isHidden: buttonState)
        headerView.setDoneAmountLabelNumber(number: numberOfDoneItems)
    }
}

// MARK: - Nested types

extension TaskListModuleViewController {
    enum Constants {
        static let defaultRowHeight: Int = 56
        static let sectionHeaderHeight: CGFloat = 32
        static let doneSwipeImageName: String = "doneSwipeImage"
        static let infoSwipeImageName: String = "infoSwipeImage"
        static let deleteSwipeImageName: String = "deleteSwipeImage"
        static let plusButtonImageName: String = "plusButton"
        static let plusButtonSideSize: CGSize = .init(width: 44, height: 44)
    }

    enum Insets {
        static let tableViewInsets: UIEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 0)
        static let cellSeparatorInsets: UIEdgeInsets = .init(top: 0, left: 52, bottom: 0, right: 0)
        static let plusButtonInsets: UIEdgeInsets = .init(top: 0, left: 0, bottom: -54, right: 0)
    }

    enum PlusButtonStyle {
        static let shadowRadius: CGFloat = 10
        static let shadowOffset: CGSize = .init(width: 0, height: 8)
        static let opacity: Float = 1
    }
}
