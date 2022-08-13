import Foundation
import UIKit

final class PriorityStackViewContainer: UIView {
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

    private lazy var label: UILabel = {
        let label = UILabel()
        label.text = Constants.labelText
        label.font = FontPalette.body
        label.textColor = ColorPalette.labelPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var segmentControl: UISegmentedControl = {
        let leftItemImage = UIImage(named: Constants.lowPriorityLabelName)
        let rightItemImage = UIImage(named: Constants.highPriorityLabelName)
        let segmentControl = UISegmentedControl(items: [
            Constants.segmentControlLeft,
            Constants.segmentControlMiddle,
            Constants.segmentControlRight
        ])
        segmentControl.setImage(leftItemImage, forSegmentAt: Constants.leftSegmentId)
        segmentControl.setImage(rightItemImage, forSegmentAt: Constants.rightSegmentId)
        segmentControl.addTarget(self, action: #selector(segmentControlValueChanged(_:)), for: .valueChanged)
        return segmentControl
    }()

    // MARK: - Lifecycle

    init(frame: CGRect, output: EditTaskModuleViewOutput) {
        self.output = output
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public

    func setSegmentControlHighlighted(selectedSegmentIndex: Int) {
        switch selectedSegmentIndex {
        case 0 ... 2:
            segmentControl.selectedSegmentIndex = selectedSegmentIndex
        default:
            segmentControl.selectedSegmentIndex = UISegmentedControl.noSegment
        }
    }

    func segmentControlValue() -> Int {
        return segmentControl.selectedSegmentIndex
    }

    // MARK: - Private

    private func setupViews() {
        addSubview(stackView)
        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(segmentControl)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),

            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            segmentControl.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    // MARK: - Selectors

    @objc func segmentControlValueChanged(_ sender: UISegmentedControl) {
        output.prioritySet(to: sender.selectedSegmentIndex)
    }
}

// MARK: - Nested types

extension PriorityStackViewContainer {
    enum Constants {
        static let labelText: String = "Важность"
        static let cornerRadius: CGFloat = 16
        static let segmentControlMiddle = "нет"
        static let segmentControlLeft = ""
        static let segmentControlRight = ""
        static let lowPriorityLabelName: String = "lowPriority"
        static let highPriorityLabelName: String = "highPriority"
        static let leftSegmentId: Int = 0
        static let rightSegmentId: Int = 2
    }
}
