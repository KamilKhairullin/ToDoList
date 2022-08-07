import UIKit

final class CellContentTitleStackView: UIStackView {
    // MARK: - Properties

    private lazy var priorityImageView: UIImageView = {
        let imageView = UIImageView()
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
        setupView()
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public

    func setLabelText(_ text: String) {
        label.text = text
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
    }
}