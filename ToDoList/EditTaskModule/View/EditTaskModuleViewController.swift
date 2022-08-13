import Foundation
import UIKit

protocol EditTaskModuleViewInput: AnyObject {
    // swiftlint:disable:next function_parameter_count
    func update(
        text: String,
        showPlaceholder: Bool,
        prioritySegment: Int,
        switchIsOn: Bool,
        isCalendarShown: Bool,
        deadline: Date?,
        deadlineString: String?,
        isDeleteEnabled: Bool,
        isSaveEnabled: Bool
    )
}

protocol EditTaskModuleViewOutput: AnyObject {
    func switchTapped(isOn: Bool)

    func newDatePicked(_ date: Date)

    func textEdited(to text: String)

    func prioritySet(to segment: Int)

    func deletePressed(on viewController: UIViewController)

    func savePressed(on viewController: UIViewController)

    func cancelPressed(on viewController: UIViewController)
}

// swiftlint:disable file_length
final class EditTaskModuleViewController: UIViewController {
    // MARK: - Properties

    private var output: EditTaskModuleViewOutput

    private var isDatePickerHidden: Bool

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.font = FontPalette.body
        textView.layer.cornerRadius = Constants.cornerRadius
        textView.backgroundColor = ColorPalette.secondaryBackgroundColor
        textView.textContainerInset = Insets.textInsets
        textView.textColor = ColorPalette.labelPrimary
        textView.isScrollEnabled = false
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.layer.cornerRadius = Constants.cornerRadius
        stackView.backgroundColor = ColorPalette.secondaryBackgroundColor
        return stackView
    }()

    private lazy var priorityStackContainer: PriorityStackViewContainer = {
        let container = PriorityStackViewContainer(frame: .zero, output: output)
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()

    private lazy var deadlineStackContainer: DeadlineStackViewContainer = {
        let container = DeadlineStackViewContainer(frame: .zero, output: output)
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }()

    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .inline
        datePicker.datePickerMode = .date
        datePicker.calendar = .autoupdatingCurrent
        datePicker.isHidden = true
        datePicker.addTarget(self, action: #selector(datePicked), for: .allEvents)
        datePicker.becomeFirstResponder()
        return datePicker
    }()

    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(ColorPalette.red, for: .normal)
        button.setTitleColor(ColorPalette.tertiary, for: .disabled)
        button.titleLabel?.font = FontPalette.body
        button.setTitle(Constants.buttonText, for: .normal)
        button.layer.cornerRadius = Constants.cornerRadius
        button.backgroundColor = ColorPalette.secondaryBackgroundColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(deletePressed), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()

    private lazy var firstSeparator: UIView = {
        let separator = UIView()
        separator.backgroundColor = ColorPalette.separator
        return separator
    }()

    private lazy var secondSeparator: UIView = {
        let separator = UIView()
        separator.backgroundColor = ColorPalette.separator
        return separator
    }()

    private lazy var saveButton: UIBarButtonItem = {
        let saveButton = UIBarButtonItem(
            title: Constants.saveButtonText,
            style: .plain,
            target: self,
            action: nil
        )
        saveButton.isEnabled = false
        saveButton.addTargetForAction(target: self, action: #selector(saveButtonPressed))
        return saveButton
    }()

    private lazy var cancelButton: UIBarButtonItem = {
        let cancelButton = UIBarButtonItem(
            title: Constants.cancelButtonText,
            style: .plain,
            target: self,
            action: nil
        )
        cancelButton.isEnabled = true
        cancelButton.addTargetForAction(target: self, action: #selector(cancelButtonPressed))
        return cancelButton
    }()

    private var textViewPortraitHeightConstraint: NSLayoutConstraint = .init()
    private var textViewLandscapeHeightConstraint: NSLayoutConstraint = .init()

    // MARK: - Lifecycle

    init(output: EditTaskModuleViewOutput) {
        self.output = output
        isDatePickerHidden = true
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        let isPortrait = size.width < size.height

        if isPortrait {
            setupPortraitMode()
        } else {
            setupLandscapeMode()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(adjustForKeyboard(notification:)),
            name: UIResponder.keyboardDidShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(adjustForKeyboard(notification:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    // MARK: - Selectors

    @objc func adjustForKeyboard(notification: NSNotification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
            as? NSValue
        else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardDidShowNotification {
            let bottomOffset = keyboardViewEndFrame.height - view.safeAreaInsets.bottom
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomOffset, right: 0)
        } else {
            scrollView.contentInset = .zero
        }

        scrollView.scrollIndicatorInsets = scrollView.contentInset
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc func datePicked() {
        output.newDatePicked(datePicker.date)
    }

    @objc func deletePressed(sender: UIButton) {
        output.deletePressed(on: self)
    }

    @objc func saveButtonPressed(sender: UIBarButtonItem) {
        output.savePressed(on: self)
    }

    @objc func cancelButtonPressed(sender: UIBarButtonItem) {
        output.cancelPressed(on: self)
    }

    @objc func textFieldDidChange(sender: UITextView) {
        output.textEdited(to: sender.text)
    }

    // MARK: - Private

    private func setupViews() {
        view.backgroundColor = ColorPalette.backgroundColor
        setupNavigationItem()
        setupScrollView()
        setupTextView()
        setupStackView()
        setupDeleteButton()
        setupPriorityStackContainer()
        setupFirstSeparator()
        setupDeadlineStackContainer()
        setupSecondSeparator()
        setupDatePicker()

        let isPortrait = !UIWindow.isLandscape

        if isPortrait {
            setupPortraitMode()
        } else {
            setupLandscapeMode()
        }
    }

    private func setupScrollView() {
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }

    private func setupTextView() {
        scrollView.addSubview(textView)

        textViewPortraitHeightConstraint = textView.heightAnchor.constraint(
            greaterThanOrEqualToConstant: Constants.textViewMinHeight
        )
        let landscapeScreenWidth = min(UIScreen.main.bounds.height, UIScreen.main.bounds.width)
        let landscapeHeight = landscapeScreenWidth  + Constants.landscapeHeightInset

        textViewLandscapeHeightConstraint = textView.heightAnchor.constraint(
            greaterThanOrEqualToConstant: landscapeHeight
        )

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: Insets.textViewInsets.top),
            textView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Insets.textViewInsets.left),
            textView.widthAnchor.constraint(
                equalTo: scrollView.widthAnchor,
                constant: -(Insets.textViewInsets.left - Insets.textViewInsets.right)
            )
        ])
    }

    private func setupStackView() {
        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: Insets.stackViewInsets.top),
            stackView.leadingAnchor.constraint(
                equalTo: scrollView.leadingAnchor,
                constant: Insets.stackViewInsets.left
            ),
            stackView.widthAnchor.constraint(
                equalTo: scrollView.widthAnchor,
                constant: -(Insets.stackViewInsets.left - Insets.stackViewInsets.right)
            )
        ])
    }

    private func setupPriorityStackContainer() {
        stackView.addArrangedSubview(priorityStackContainer)

        NSLayoutConstraint.activate([
            priorityStackContainer.leadingAnchor.constraint(
                equalTo: stackView.leadingAnchor,
                constant: Insets.priorityStackContainerInsets.left
            ),
            priorityStackContainer.trailingAnchor.constraint(
                equalTo: stackView.trailingAnchor,
                constant: Insets.priorityStackContainerInsets.right
            ),
            priorityStackContainer.heightAnchor.constraint(equalToConstant: Constants.stackItemHeight)
        ])
    }

    private func setupDeadlineStackContainer() {
        stackView.addArrangedSubview(deadlineStackContainer)

        NSLayoutConstraint.activate([
            deadlineStackContainer.leadingAnchor.constraint(
                equalTo: stackView.leadingAnchor,
                constant: Insets.priorityStackContainerInsets.left
            ),
            deadlineStackContainer.trailingAnchor.constraint(
                equalTo: stackView.trailingAnchor,
                constant: Insets.priorityStackContainerInsets.right
            ),
            deadlineStackContainer.heightAnchor.constraint(equalToConstant: Constants.stackItemHeight)
        ])
    }

    private func setupDatePicker() {
        stackView.addArrangedSubview(datePicker)

        NSLayoutConstraint.activate([
            datePicker.leadingAnchor.constraint(
                equalTo: stackView.leadingAnchor,
                constant: Insets.datePickerInsets.left
            ),
            datePicker.trailingAnchor.constraint(
                equalTo: stackView.trailingAnchor,
                constant: Insets.datePickerInsets.right
            ),
            datePicker.heightAnchor.constraint(equalToConstant: Constants.datePickerHeight)
        ])
    }

    private func setupDeleteButton() {
        scrollView.addSubview(deleteButton)
        NSLayoutConstraint.activate([
            deleteButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: Insets.deleteButtonInsets.top),
            deleteButton.leadingAnchor.constraint(
                equalTo: scrollView.leadingAnchor,
                constant: Insets.deleteButtonInsets.left
            ),
            deleteButton.bottomAnchor.constraint(
                equalTo: scrollView.bottomAnchor,
                constant: Insets.deleteButtonInsets.bottom
            ),
            deleteButton.widthAnchor.constraint(
                equalTo: scrollView.widthAnchor,
                constant: -(Insets.deleteButtonInsets.left - Insets.textViewInsets.right)
            ),
            deleteButton.heightAnchor.constraint(equalToConstant: Constants.buttonHeight)
        ])
    }

    private func setupFirstSeparator() {
        stackView.addArrangedSubview(firstSeparator)
        NSLayoutConstraint.activate([
            firstSeparator.heightAnchor.constraint(equalToConstant: Constants.separatorHeight),
            firstSeparator.leadingAnchor.constraint(
                equalTo: stackView.leadingAnchor,
                constant: Insets.separatorInsets.left
            ),
            firstSeparator.trailingAnchor.constraint(
                equalTo: stackView.trailingAnchor,
                constant: Insets.separatorInsets.right
            )
        ])
    }

    private func setupSecondSeparator() {
        stackView.addArrangedSubview(secondSeparator)
        NSLayoutConstraint.activate([
            secondSeparator.heightAnchor.constraint(equalToConstant: Constants.separatorHeight),
            secondSeparator.leadingAnchor.constraint(
                equalTo: stackView.leadingAnchor,
                constant: Insets.separatorInsets.left
            ),
            secondSeparator.trailingAnchor.constraint(
                equalTo: stackView.trailingAnchor,
                constant: Insets.separatorInsets.right
            )
        ])
    }

    private func setupNavigationItem() {
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = saveButton
        if presentingViewController != nil {
            navigationItem.leftBarButtonItem = cancelButton
        }
        navigationItem.title = Constants.navigationItemTitle
    }

    private func setupLandscapeMode() {
        stackView.isHidden = true
        deleteButton.isHidden = true
        priorityStackContainer.isHidden = true
        deadlineStackContainer.isHidden = true
        datePicker.isHidden = true
        textViewPortraitHeightConstraint.isActive = false
        textViewLandscapeHeightConstraint.isActive = true
    }

    private func setupPortraitMode() {
        stackView.isHidden = false
        deleteButton.isHidden = false
        priorityStackContainer.isHidden = false
        deadlineStackContainer.isHidden = false
        datePicker.isHidden = isDatePickerHidden

        textViewLandscapeHeightConstraint.isActive = false
        textViewPortraitHeightConstraint.isActive = true
    }
}

// MARK: - Nested types

extension EditTaskModuleViewController {
    enum Constants {
        static let cornerRadius: CGFloat = 16
        static let textViewMinHeight: CGFloat = 120
        static let stackItemHeight: CGFloat = 66
        static let datePickerHeight: CGFloat = 338
        static let buttonHeight: CGFloat = 56
        static let buttonText: String = "Удалить"
        static let cancelButtonText: String = "Отменить"
        static let saveButtonText: String = "Cохранить"
        static let navigationItemTitle: String = "Дело"
        static let separatorHeight: CGFloat = 0.5
        static let landscapeHeightInset: CGFloat = -70
    }

    enum Insets {
        static let textViewInsets: UIEdgeInsets = .init(top: 16, left: 16, bottom: 0, right: -16)
        static let stackViewInsets: UIEdgeInsets = .init(top: 16, left: 16, bottom: 0, right: -16)
        static let priorityStackContainerInsets: UIEdgeInsets = .init(top: 0, left: 16, bottom: 0, right: -16)
        static let deleteButtonInsets: UIEdgeInsets = .init(top: 16, left: 16, bottom: -15, right: -16)
        static let datePickerInsets: UIEdgeInsets = .init(top: 0, left: 12, bottom: 0, right: -12)
        static let separatorInsets: UIEdgeInsets = .init(top: 0, left: 16, bottom: 0, right: -16)
        static let textInsets: UIEdgeInsets = .init(top: 17, left: 16, bottom: 16, right: 16)
    }
}

// MARK: - EditTaskModuleViewInput extension

extension EditTaskModuleViewController: EditTaskModuleViewInput {
    // swiftlint:disable:next function_parameter_count
    func update(
        text: String,
        showPlaceholder: Bool,
        prioritySegment: Int,
        switchIsOn: Bool,
        isCalendarShown: Bool,
        deadline: Date?,
        deadlineString: String?,
        isDeleteEnabled: Bool,
        isSaveEnabled: Bool
    ) {
        textView.text = text
        textView.textColor = showPlaceholder ? ColorPalette.tertiary : ColorPalette.labelPrimary
        priorityStackContainer.setSegmentControlHighlighted(
            selectedSegmentIndex: prioritySegment)
        deadlineStackContainer.setDeadlineSwitch(to: switchIsOn)
        isDatePickerHidden = !isCalendarShown
        UIView.animate(
            withDuration: 0.3,
            animations: {
                self.datePicker.alpha = isCalendarShown ? 1 : 0
            },
            completion: { [weak self] (_: Bool) in
                self?.secondSeparator.isHidden = !isCalendarShown
                self?.datePicker.isHidden = !isCalendarShown
                self?.deadlineStackContainer.hideDeadlineDateLabel(isHidden: deadline == nil)
                if let deadlineString = deadlineString, let deadline = deadline {
                    self?.deadlineStackContainer.setDeadlineDateLabel(text: deadlineString)
                    self?.datePicker.date = deadline
                }
            }
        )
        deleteButton.isEnabled = isDeleteEnabled
        saveButton.isEnabled = isSaveEnabled
    }
}

// MARK: - UITextViewDelegate extension

extension EditTaskModuleViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        output.textEdited(to: textView.text)
    }
}
