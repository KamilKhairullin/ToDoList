import UIKit

final class CellContentStackView: UIStackView {
    // MARK: - Properties

    lazy var contentTitleStack: CellContentTitleStackView = {
        let contentTitleStackView = CellContentTitleStackView()
        contentTitleStackView.translatesAutoresizingMaskIntoConstraints = false
        return contentTitleStackView
    }()

    lazy var contentSubtitleStack: CellContentSubtitleStackView = {
        let contentSubtitleStackView = CellContentSubtitleStackView()
        contentSubtitleStackView.translatesAutoresizingMaskIntoConstraints = false
        return contentSubtitleStackView
    }()

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    // MARK: - Private

    private func setupView() {
        axis = .vertical
        alignment = .leading
        distribution = .fill
        translatesAutoresizingMaskIntoConstraints = false
        addArrangedSubview(contentTitleStack)
        addArrangedSubview(contentSubtitleStack)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
