import UIKit

final class CellContentTitleStackView: UIStackView {
    // MARK: - Properties

    private lazy var priorityImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        return imageView
    }()

    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = FontPalette.body
        label.translatesAutoresizingMaskIntoConstraints = false
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = Constatns.numberOfLines
        return label
    }()

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public

    func setLabelText(_ text: String, isStrikethrough: Bool) {
        let attributedText = NSAttributedString(
            string: text,
            attributes: isStrikethrough ? [.strikethroughStyle: NSUnderlineStyle.single.rawValue] : [:]
        )
        label.attributedText = attributedText
    }

    func setPriorityImage(name: String) {
        priorityImageView.image = UIImage(named: name)
    }

    func setPriorityImageVisibility(isHidden: Bool) {
        priorityImageView.isHidden = isHidden
    }
    // MARK: - Private

    private func setupView() {
        axis = .horizontal
        alignment = .center
        distribution = .fill
        spacing = Constatns.stackSpacing
        addArrangedSubview(priorityImageView)
        addArrangedSubview(label)
    }
}

// MARK: - Nested types

extension CellContentTitleStackView {
    enum Constatns {
        static let stackSpacing: CGFloat = 5
        static let labelText: String = "Купить что-то"
        static let numberOfLines = 3
    }
}
