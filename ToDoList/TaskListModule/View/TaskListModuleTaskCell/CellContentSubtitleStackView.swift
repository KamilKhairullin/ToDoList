import UIKit

final class CellContentSubtitleStackView: UIStackView {
    // MARK: - Properties

    private lazy var calendarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: Constatns.calendarImageName)
        return imageView
    }()

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = FontPalette.subhead
        label.textColor = ColorPalette.tertiary
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

    func setDateLabel(text: String) {
        dateLabel.text = text
    }
    // MARK: - Private

    private func setupView() {
        axis = .horizontal
        alignment = .center
        distribution = .fill
        spacing = Constatns.stackSpacing
        addArrangedSubview(calendarImageView)
        addArrangedSubview(dateLabel)
    }
}

// MARK: - Nested types

extension CellContentSubtitleStackView {
    enum Constatns {
        static let stackSpacing: CGFloat = 3.5
        static let calendarImageName: String = "calendarImage"
    }
}
