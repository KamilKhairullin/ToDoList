import Foundation
import UIKit

final class PriorityStackViewContainer: UIView {
    // MARK: - Properties

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
        let leftItem = UIImage(named: "lowPriority")
        let middleItem = Constants.segmentControlMiddle
        let rightItem = UIImage(named: "highPriority")
        let segmentControl = UISegmentedControl(items: [
            "",
            middleItem,
            ""
        ])
        segmentControl.setImage(leftItem, forSegmentAt: 0)
        segmentControl.setImage(rightItem, forSegmentAt: 2)
        return segmentControl
    }()

    // MARK: - Lifecycle

    override init(frame: CGRect) {
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
        segmentControl.selectedSegmentIndex = selectedSegmentIndex
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
            stackView.leftAnchor.constraint(equalTo: leftAnchor),
            stackView.rightAnchor.constraint(equalTo: rightAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),

            label.leftAnchor.constraint(equalTo: leftAnchor),
            segmentControl.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }
}

// MARK: - Nested types

extension PriorityStackViewContainer {
    enum Constants {
        static let labelText: String = "Важность"
        static let cornerRadius: CGFloat = 16
        static let segmentControlMiddle = "нет"
    }
}
