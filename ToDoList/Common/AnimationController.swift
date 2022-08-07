import UIKit

final class AnimationController: NSObject {
    private let animationDuration: Double
    private let animationType: AnimationType

    init(animationDuration: Double, animationType: AnimationType) {
        self.animationDuration = animationDuration
        self.animationType = animationType
    }

    private func presentAnimation(with transitionContext: UIViewControllerContextTransitioning, viewToAnimate: UIView) {
        viewToAnimate.clipsToBounds = true
        viewToAnimate.transform = CGAffineTransform(scaleX: Constants.fromScale, y: Constants.fromScale)

        let duration = transitionDuration(using: transitionContext)
        UIView.animate(
            withDuration: duration,
            delay: Constants.delay,
            usingSpringWithDamping: Constants.damping,
            initialSpringVelocity: Constants.velocity,
            options: .curveEaseInOut,
            animations: {
                viewToAnimate.transform = CGAffineTransform(scaleX: Constants.toScale, y: Constants.toScale)
            },
            completion: {_ in
                transitionContext.completeTransition(true)
            }
        )
    }
}

// MARK: - Nested types

extension AnimationController {
    enum AnimationType {
        case present
        case dismiss
    }

    enum Constants {
        static let fromScale: CGFloat = 0.0
        static let toScale: CGFloat = 1.0
        static let delay: Double = 0
        static let damping: CGFloat = 0.8
        static let velocity: CGFloat = 0.1
    }
}

// MARK: - UIViewControllerAnimatedTransitioning extension

extension AnimationController: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TimeInterval(exactly: animationDuration) ?? 0
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let toViewController = transitionContext.viewController(forKey: .to)
        else {
            transitionContext.completeTransition(false)
            return
        }

        switch animationType {
        case .present:
            transitionContext.containerView.addSubview(toViewController.view)
            presentAnimation(with: transitionContext, viewToAnimate: toViewController.view)
        case .dismiss:
            break
        }
    }
}
