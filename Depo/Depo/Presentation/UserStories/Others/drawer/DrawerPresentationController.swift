//
//  DrawerPresentationController.swift
//  drawer
//
//  Created by Hady on 6/11/22.
//

import Foundation
import UIKit

class DrawerPresentationController: UIPresentationController, UIGestureRecognizerDelegate {

    var allowsDismissalWithPanGesture = true
    var allowsDismissalWithTapGesture = true
    var passesTouchesToPresentingView = false
    var dimmedViewStyle = DimStyle.default
    var drawerHorizontalInset: CGFloat = 12

    private var passthroughView: DrawerPassthroughView?
    private var dimView: UIView?
    private var cachedPresentedViewFrame = CGRect.zero
    private var panGesture: UIPanGestureRecognizer!

    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()

        setupDimView()
        setupPanGesture()

        if allowsDismissalWithTapGesture {
            setupTapGesture()
        }

        if passesTouchesToPresentingView {
            setupPassthroughView()
        }

        animateDimViewPresentation()
    }

    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        animateDimViewDismissal()
    }

    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()

        dimView?.frame = containerView?.bounds ?? .zero

        if panGesture?.state != .changed {
            presentedView?.frame = frameOfPresentedViewInContainerView
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { context in
            self.presentedView?.frame = self.frameOfPresentedViewInContainerView
        }
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let presentedView = self.presentedView,
              let containerView = self.containerView else {
            return .zero
        }

        let width = containerView.bounds
            .inset(by: containerView.safeAreaInsets)
            .insetBy(dx: drawerHorizontalInset, dy: 0)
            .width

        let preferredSize = presentedView.systemLayoutSizeFitting(
            CGSize(width: width, height: .zero),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .defaultLow
        )

        let preferredHeight = preferredSize.height + containerView.safeAreaInsets.bottom
        let maxHeight = containerView.bounds.height - containerView.safeAreaInsets.top

        let drawerHeight:CGFloat = min(preferredHeight, maxHeight)
        cachedPresentedViewFrame = CGRect(
            x: (containerView.bounds.width - width) / 2,
            y: containerView.bounds.height - drawerHeight,
            width: width,
            height: drawerHeight
        )

        return cachedPresentedViewFrame
    }

    private func setupDimView() {
        switch dimmedViewStyle {
        case .default:
            dimView = UIView()
            dimView?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        case .blurEffect(let style):
            dimView = UIVisualEffectView(effect: UIBlurEffect(style: style))
        case .none:
            dimView?.removeFromSuperview()
            dimView = nil
        }

        if let dimView = dimView {
            dimView.frame = containerView?.bounds ?? .zero
            containerView?.insertSubview(dimView, at: 0)
        }
    }

    private func animateDimViewPresentation() {
        dimView?.alpha = 0
        presentedViewController.transitionCoordinator?.animate { _ in
            self.dimView?.alpha = 0.90
        }
    }

    private func animateDimViewDismissal() {
        presentedViewController.transitionCoordinator?.animate { _ in
            self.dimView?.alpha = 0
        }
    }

    private func setupPassthroughView() {
        guard passesTouchesToPresentingView else {
            return
        }

        guard let containerView = containerView else { return }
        let passthroughView = self.passthroughView ?? DrawerPassthroughView()
        passthroughView.frame = containerView.bounds
        containerView.insertSubview(passthroughView, at: 0)
        passthroughView.passthroughView = presentingViewController.view
        self.passthroughView = passthroughView
    }

    // MARK: Tap Gesture

    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        containerView?.addGestureRecognizer(tapGesture)
    }

    @objc private func handleTap() {
        presentedViewController.dismiss(animated: true)
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer is UITapGestureRecognizer else {
            return true
        }

        let location = gestureRecognizer.location(in: containerView)
        let tappedAtPresentedView = presentedView?.frame.contains(location) ?? false
        return !tappedAtPresentedView
    }

    // MARK: Pan Gesture

    private func setupPanGesture() {
        guard let presentedView = self.presentedView else {
            return
        }

        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        presentedView.isUserInteractionEnabled = true
        presentedView.addGestureRecognizer(panGesture)
    }

    @objc private func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let presentedView = presentedView else {
            return
        }

        var translationY = gestureRecognizer.translation(in: presentedView.superview).y
        let velocity = gestureRecognizer.velocity(in: presentedView.superview).y

        switch gestureRecognizer.state {
        case .changed:
            if !allowsDismissalWithPanGesture || translationY < 0 {
                translationY = translationY / 10
            }
            drivePresentedView(with: translationY)

        case .ended:
            if shouldDismissOnGestureEnd(translation: translationY, velocity: velocity) && allowsDismissalWithPanGesture {
                presentedViewController.dismiss(animated: true)
            } else {
                resetPresentedViewToInitialFrame()
            }

        default:
            resetPresentedViewToInitialFrame()
        }
    }

    private func drivePresentedView(with translationY: CGFloat) {
        guard let containerView = containerView else {
            return
        }

        let minY = containerView.bounds.inset(by: containerView.safeAreaInsets).minY
        let maxHeight = containerView.bounds.height - containerView.safeAreaInsets.top

        let initialFrame = frameOfPresentedViewInContainerView
        let newY = initialFrame.origin.y + translationY
        let newHeight = translationY < 0 ? initialFrame.size.height + abs(translationY) : initialFrame.size.height

        presentedView?.frame = CGRect(
            x: initialFrame.origin.x,
            y: max(minY, newY),
            width: initialFrame.width,
            height: min(maxHeight, newHeight)
        )
    }

    private func shouldDismissOnGestureEnd(translation: CGFloat, velocity: CGFloat) -> Bool {
        guard let presentedView = presentedView,
              let containerView = containerView else {
            return false
        }

        let initialFrame = frameOfPresentedViewInContainerView
        let finalY = initialFrame.origin.y + translation + velocity

        let topEmptySpace = containerView.bounds.height - presentedView.frame.height
        return finalY > (topEmptySpace + presentedView.frame.height / 2)
    }

    private func resetPresentedViewToInitialFrame() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .allowUserInteraction) {
            self.presentedView?.frame = self.frameOfPresentedViewInContainerView
        }
    }
}

extension DrawerPresentationController {
    enum DimStyle {
        case `default`
        case blurEffect(style: UIBlurEffect.Style)
        case none
    }
}
