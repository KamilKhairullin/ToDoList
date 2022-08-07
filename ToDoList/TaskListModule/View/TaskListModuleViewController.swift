import Foundation
import UIKit

protocol TaskListModuleViewInput: AnyObject {
    func reloadData()
}

protocol TaskListModuleViewOutput: AnyObject {
    func getCellData(forIndexPath indexPath: IndexPath) -> TaskListTableViewCellData
    func plusButtonPressed()
    func getRowsNumber() -> Int
    func getRowHeight(forIndexPath indexPath: IndexPath, lineWidth: Int) -> Int
    func selectRowAt(indexPath: IndexPath, on viewController: UIViewController)
}

final class TaskListModuleViewController: UIViewController {
    // MARK: - Properties

    private var output: TaskListModuleViewOutput?

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
        let header = TaskListModuleHeaderView()
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
    }

    // MARK: - Selectors

    @objc private func plusButtonPressed() {
        output?.plusButtonPressed()
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

    private func makeDoneAction(indexPath: IndexPath) -> UIContextualAction {
        let doneAction = UIContextualAction(
            style: .normal,
            title: nil
        ) { _, _, completion in
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
        ) { _, _, completion in
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
        output?.getRowsNumber() ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard
            let data = output?.getCellData(forIndexPath: indexPath),
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
            output?.getRowHeight(forIndexPath: indexPath, lineWidth: lineWidth)
            ?? Constants.defaultRowHeight
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
        let doneAction = makeDoneAction(indexPath: indexPath)
        return UISwipeActionsConfiguration(actions: [doneAction])
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let infoAction = makeInfoAction(indexPath: indexPath)
        let deleteAction = makeDeleteAction(indexPath: indexPath)

        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction, infoAction])
        swipeConfiguration.performsFirstActionWithFullSwipe = true
        return swipeConfiguration
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        output?.selectRowAt(indexPath: indexPath, on: self)
    }
}

// MARK: - TaskListModuleViewInput extension

extension TaskListModuleViewController: TaskListModuleViewInput {
    func reloadData() {
        tableView.reloadData()
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
