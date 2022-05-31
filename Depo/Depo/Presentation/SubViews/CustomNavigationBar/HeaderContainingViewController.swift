//
//  HeaderContainingViewController.swift
//  Depo
//
//  Created by Hady on 4/12/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import UIKit

final class HeaderContainingViewController: BaseViewController {
    typealias Child = HeaderContainingViewControllerChild
    typealias ChildView = HeaderContainingViewControllerChild & UIView
    typealias ChildViewController = HeaderContainingViewControllerChild & UIViewController

    convenience init(child: ChildViewController) {
        self.init(nibName: nil, bundle: nil)
        self.child = child
    }

    convenience init(child: ChildView) {
        self.init(nibName: nil, bundle: nil)
        self.child = child
    }

    func setHeaderRightItems(_ items: [UIView]) {
        headerView.setRightItems(items)
    }

    func setHeaderLeftItems(_ items: [UIView]) {
        headerView.setLeftItems(items)
    }

    var isHeaderBehindContent: Bool = true {
        didSet {
            updateHeaderMask()
        }
    }

    var headerContentIntersectionMode = HeaderContentIntersectionMode.default {
        didSet {
            updateHeaderMask()
            updateAdditionalSafeAreaInsetsIfNeeded()
        }
    }

    var statusBarBackgroundViewStyle = StatusBarBackgroundViewStyle.blurEffect(style: .prominent) {
        didSet {
            updateStatusBarBackgroundViewStyle()
        }
    }

    private let headerView = NavigationHeaderView.initFromNib()
    private let statusBarBackgroundView = UIView()
    private var statusBarBackgroundViewHeightConstraint: NSLayoutConstraint!
    private var scrollViewObservationToken: NSKeyValueObservation?
    private(set) var child: HeaderContainingViewControllerChild!
    let originalSafeAreaLayoutGuide = UILayoutGuide()
    private var originalSafeAreaLayoutGuideTopConstraint: NSLayoutConstraint!

    private var childView: ChildView? { child as? ChildView }
    private var childViewController: ChildViewController? { child as? ChildViewController }

    override func viewDidLoad() {
        super.viewDidLoad()
        needToShowTabBar = true
        navigationBarHidden = true

        if let childViewController = childViewController {
            setupChildViewController(childViewController)
        } else if let childView = childView {
            setupChildView(childView)
        }

        setupHeaderView()
        updateHeaderMask()
        setupStatusBarBackgroundView()
        updateStatusBarBackgroundViewStyle()
        setupOriginalSafeAreaLayoutGuide()

        if let scrollView = child.scrollViewForHeaderTracking {
            bindHeaderView(with: scrollView)
        }
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        updateAdditionalSafeAreaInsetsIfNeeded()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerView.mask?.frame.size.width = headerView.bounds.width
    }

    private func setupHeaderView() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        NSLayoutConstraint.activate([
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.topAnchor.constraint(equalTo: view.topAnchor)
        ])
    }

    private func updateHeaderMask() {
        if isHeaderBehindContent {
            var maskFrame = headerView.frame
            maskFrame.size.height -= headerContentIntersectionMode.rawValue
            let maskView = UIView(frame: maskFrame)
            maskView.backgroundColor = .black
            headerView.mask = maskView
        } else {
            headerView.mask = nil
        }
    }

    private func updateAdditionalSafeAreaInsetsIfNeeded() {
        let statusBarHeight = view.safeAreaInsets.top - additionalSafeAreaInsets.top
        originalSafeAreaLayoutGuideTopConstraint.constant = statusBarHeight
        statusBarBackgroundViewHeightConstraint.constant = statusBarHeight

        let headerHeight = headerView.frame.height - headerContentIntersectionMode.rawValue
        let headerInset = headerHeight - statusBarHeight
        if additionalSafeAreaInsets.top != headerInset {
            additionalSafeAreaInsets.top = headerInset
        }
    }

    private func setupStatusBarBackgroundView() {
        statusBarBackgroundView.alpha = 0
        statusBarBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusBarBackgroundView)

        statusBarBackgroundViewHeightConstraint = statusBarBackgroundView.heightAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            statusBarBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            statusBarBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            statusBarBackgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            statusBarBackgroundViewHeightConstraint
        ])
    }

    private func updateStatusBarBackgroundViewStyle() {
        statusBarBackgroundView.subviews.forEach { subview in
            subview.removeFromSuperview()
        }

        let contentView: UIView
        switch statusBarBackgroundViewStyle {
        case .blurEffect(let style):
            contentView = UIVisualEffectView(effect: UIBlurEffect(style: style))
        case .plain(let color):
            contentView = UIView()
            contentView.backgroundColor = color.color
        }

        contentView.translatesAutoresizingMaskIntoConstraints = false
        statusBarBackgroundView.addSubview(contentView)
        contentView.pinToSuperviewEdges()
    }

    private func setupOriginalSafeAreaLayoutGuide() {
        view.addLayoutGuide(originalSafeAreaLayoutGuide)

        originalSafeAreaLayoutGuideTopConstraint = originalSafeAreaLayoutGuide.topAnchor.constraint(equalTo: view.topAnchor)
        NSLayoutConstraint.activate([
            originalSafeAreaLayoutGuide.leadingAnchor.constraint(equalTo: view.safeLeadingAnchor),
            originalSafeAreaLayoutGuide.trailingAnchor.constraint(equalTo: view.safeTrailingAnchor),
            originalSafeAreaLayoutGuide.bottomAnchor.constraint(equalTo: view.safeBottomAnchor),
            originalSafeAreaLayoutGuideTopConstraint,
        ])
    }

    private func setupChildViewController(_ childViewController: ChildViewController) {
        addChild(childViewController)
        pinChildView(childViewController.view)
        childViewController.didMove(toParent: self)
    }

    private func setupChildView(_ childView: ChildView) {
        pinChildView(childView)
    }

    private func pinChildView(_ childView: UIView) {
        view.addSubview(childView)
        childView.translatesAutoresizingMaskIntoConstraints = false
        childView.pinToSuperviewEdges()
    }

    private func bindHeaderView(with scrollView: UIScrollView) {
        scrollViewObservationToken = scrollView.observe(\.contentOffset) { [weak self] scrollView, _ in
            self?.contentOffsetChanged(for: scrollView)
        }
    }

    private func contentOffsetChanged(for scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y + scrollView.adjustedContentInset.top
        let contentStartsAt = headerView.frame.height - headerContentIntersectionMode.rawValue
        let headerTranslation = -max(0, min(contentStartsAt, yOffset))
        let progress = abs(headerTranslation / contentStartsAt)
        headerView.transform = CGAffineTransform(translationX: 0, y: headerTranslation)
        statusBarBackgroundView.alpha = progress
        headerView.alpha = 1 - progress
    }
}
