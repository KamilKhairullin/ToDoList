import UIKit

final class CustomNavigationController: UINavigationController {
    init(rootViewController: UIViewController?, title: String) {
        let viewController: UIViewController = rootViewController ?? UIViewController()
        super.init(rootViewController: viewController)
        viewController.title = title
        viewController.view?.backgroundColor = ColorPalette.backgroundColor
        setupNavigationBarAppearance()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupNavigationBarAppearance() {
        Constants.paragraphStyle.firstLineHeadIndent = Constants.titleLeftOffset

        let largeTitleTextAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.paragraphStyle: Constants.paragraphStyle,
            NSAttributedString.Key.baselineOffset: Constants.largeTitleBaselineOffset
        ]

        navigationBar.barTintColor = ColorPalette.navbarBlur
        navigationBar.largeTitleTextAttributes = largeTitleTextAttributes
        navigationBar.prefersLargeTitles = true
    }
}

// MARK: - Nested types

extension CustomNavigationController {
    enum Constants {
        static let paragraphStyle: NSMutableParagraphStyle = .init()
        static let titleLeftOffset: CGFloat = 16
        static let largeTitleBaselineOffset: CGFloat = 10
    }
}
