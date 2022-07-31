import Foundation
import UIKit

final class EditTaskModuleViewController: UIViewController {
    // MARK: - Properties

    private var output: EditTaskModuleViewOutput

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
        textView.textContainerInset = UIEdgeInsets(
            top: 17, left: 16, bottom: 16, right: 16
        )
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
        return datePicker
    }()

    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(ColorPalette.red, for: .normal)
        button.setTitleColor(ColorPalette.tertiary, for: .disabled)
        button.layer.cornerRadius = Constants.cornerRadius
        button.backgroundColor = ColorPalette.secondaryBackgroundColor
        button.titleLabel?.font = FontPalette.body
        button.setTitle(Constants.buttonText, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(deletePressed), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()

    private lazy var separator: UIView = {
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

    // MARK: - Lifecycle

    init(output: EditTaskModuleViewOutput) {
        self.output = output
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorPalette.backgroundColor
        setupNavigationItem()
        setupScrollView()
        setupTextView()
        setupStackView()
        setupDeleteButton()
        setupPriorityStackContainer()
        setupSeparator()
        setupDeadlineStackContainer()
        setupDatePicker()
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

    @objc func datePicked(sender: UIDatePicker) {
        output.newDatePicked(date: datePicker.date)
    }

    @objc func deletePressed(sender: UIButton) {
        output.deletePressed()
    }

    @objc func saveButtonPressed(sender: UIBarButtonItem) {
        output.save(
            text: textView.text,
            prioritySegment: priorityStackContainer.getSegmentControlValue(),
            switchIsOn: deadlineStackContainer.getDeadlineSwitchStatus(),
            deadlineDate: datePicker.date
        )
    }

    @objc func textFieldDidChange(sender: UITextView) {
        output.textEdited(to: sender.text)
    }

    // MARK: - Private

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

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: Insets.textViewInsets.top),
            textView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Insets.textViewInsets.left),
            textView.widthAnchor.constraint(
                equalTo: scrollView.widthAnchor,
                constant: -(Insets.textViewInsets.left - Insets.textViewInsets.right)
            ),
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.textViewMinHeight)
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
            datePicker.heightAnchor.constraint(equalToConstant: 332)
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

    private func setupSeparator() {
        stackView.addArrangedSubview(separator)
        NSLayoutConstraint.activate([
            separator.heightAnchor.constraint(equalToConstant: Constants.separatorHeight),
            separator.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: Insets.separatorInsets.left),
            separator.trailingAnchor.constraint(
                equalTo: stackView.trailingAnchor,
                constant: Insets.separatorInsets.right
            )
        ])
    }

    private func setupNavigationItem() {
        navigationItem.rightBarButtonItem = saveButton
        navigationItem.title = Constants.navigationItemTitle
    }
}

// MARK: - Nested types

extension EditTaskModuleViewController {
    enum Constants {
        static let cornerRadius: CGFloat = 16
        static let textViewMinHeight: CGFloat = 120
        static let stackItemHeight: CGFloat = 66
        static let buttonHeight: CGFloat = 56
        static let buttonText: String = "Удалить"
        static let saveButtonText: String = "Cохранить"
        static let navigationItemTitle: String = "Дело"
        static let separatorHeight: CGFloat = 0.5
    }

    enum Insets {
        static let textViewInsets: UIEdgeInsets = .init(top: 16, left: 16, bottom: 0, right: -16)
        static let stackViewInsets: UIEdgeInsets = .init(top: 16, left: 16, bottom: 0, right: -16)
        static let priorityStackContainerInsets: UIEdgeInsets = .init(top: 0, left: 16, bottom: 0, right: -16)
        static let deleteButtonInsets: UIEdgeInsets = .init(top: 16, left: 16, bottom: -30, right: -16)
        static let datePickerInsets: UIEdgeInsets = .init(top: 0, left: 12, bottom: 0, right: -12)
        static let separatorInsets: UIEdgeInsets = .init(top: 0, left: 16, bottom: 0, right: -16)
    }
}

// MARK: - EditTaskModuleViewInput extension

extension EditTaskModuleViewController: EditTaskModuleViewInput {
    func enableDelete() {
        deleteButton.isEnabled = true
    }

    func disableDelete() {
        deleteButton.isEnabled = false
    }

    func enableSave() {
        saveButton.isEnabled = true
    }

    func disableSave() {
        saveButton.isEnabled = false
    }

    func hideCalendar() {
        UIView.animate(
            withDuration: 0.5,
            animations: {
                self.datePicker.alpha = 0
            },
            completion: { [weak self] (_: Bool) in
                self?.datePicker.isHidden = true
                self?.deadlineStackContainer.hideDeadlineDateLabel(isHidden: true)
            }
        )
    }

    func showCalendar(dateString: String, date: Date) {
        datePicker.isHidden = false
        deadlineStackContainer.hideDeadlineDateLabel(isHidden: false)
        deadlineStackContainer.setDeadlineDateLabel(text: dateString)
        datePicker.date = date
        UIView.animate(
            withDuration: 0.5,
            animations: {
                self.datePicker.alpha = 1
            },
            completion: nil
        )
    }

    func update(dateString: String) {
        deadlineStackContainer.setDeadlineDateLabel(text: dateString)
    }

    func update(text: String, prioritySegment: Int, switchIsOn: Bool, deadlineDate: String?) {
        textView.text = text
        priorityStackContainer.setSegmentControlHighlighted(selectedSegmentIndex: prioritySegment)
        deadlineStackContainer.setDeadlineSwitch(to: switchIsOn)
        if switchIsOn, let deadlineDate = deadlineDate {
            deadlineStackContainer.setDeadlineDateLabel(text: deadlineDate)
        }
    }
}

// MARK: - UITextViewDelegate extension

extension EditTaskModuleViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        output.textEdited(to: textView.text)
    }
}
