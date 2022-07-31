import Foundation
import UIKit

final class DeadlineStackViewContainer: UIView {
    // MARK: - Properties

    private var output: EditTaskModuleViewOutput

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.distribution = .equalCentering
        stackView.layer.cornerRadius = Constants.cornerRadius
        return stackView
    }()

    private lazy var labelsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .leading
        stackView.distribution = .fillProportionally
        stackView.layer.cornerRadius = Constants.cornerRadius
        return stackView
    }()

    private lazy var deadlineLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.deadlineLabelText
        label.font = FontPalette.body
        label.textColor = ColorPalette.labelPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var deadlineDateLabel: UILabel = {
        let label = UILabel()
        label.text = "2 июня 2021"
        label.font = FontPalette.footnote
        label.textColor = ColorPalette.blue
        label.textAlignment = .left
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var deadlineSwitch: UISwitch = {
        let deadlineSwitch = UISwitch()
        deadlineSwitch.isOn = false
        deadlineSwitch.addTarget(self, action: #selector(deadlineSwitchTapped), for: .allTouchEvents)
        return deadlineSwitch
    }()

    // MARK: - Lifecycle

    init(frame: CGRect, output: EditTaskModuleViewOutput) {
        self.output = output
        super.init(frame: frame)
        setupLabelsStackView()
        setupDeadlineSwitch()
        setupStackView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public

    func setDeadlineSwitch(to isOn: Bool) {
        deadlineSwitch.isOn = isOn
    }

    func hideDeadlineDateLabel(isHidden: Bool) {
        deadlineDateLabel.isHidden = isHidden
    }

    func setDeadlineDateLabel(text: String) {
        deadlineDateLabel.text = text
    }

    // MARK: - Private

    private func setupStackView() {
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leftAnchor.constraint(equalTo: leftAnchor),
            stackView.rightAnchor.constraint(equalTo: rightAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),

            labelsStackView.leftAnchor.constraint(equalTo: leftAnchor),
            deadlineSwitch.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }

    private func setupLabelsStackView() {
        labelsStackView.addArrangedSubview(deadlineLabel)
        labelsStackView.addArrangedSubview(deadlineDateLabel)
        stackView.addArrangedSubview(labelsStackView)
    }

    private func setupDeadlineSwitch() {
        stackView.addArrangedSubview(deadlineSwitch)
    }

    // MARK: - Selectors

    @objc func deadlineSwitchTapped(sender: UISwitch) {
        output.switchTapped(isOn: sender.isOn)
    }
}

// MARK: - Nested types

extension DeadlineStackViewContainer {
    enum Constants {
        static let deadlineLabelText: String = "Cделать до"
        static let cornerRadius: CGFloat = 16
    }
}
