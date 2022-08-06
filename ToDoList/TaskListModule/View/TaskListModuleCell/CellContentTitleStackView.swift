import UIKit

final class CellContentTitleStackView: UIStackView {
    // MARK: - Properties

    private lazy var priorityImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: Constatns.priorityImageName)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = FontPalette.body
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = Constatns.labelText
        return label
    }()

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private

    private func setupViews() {
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
        static let priorityImageName: String = "highPriority"
    }
}
