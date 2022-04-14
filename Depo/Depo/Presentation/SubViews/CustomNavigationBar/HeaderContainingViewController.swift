//
//  HeaderContainingViewController.swift
//  Depo
//
//  Created by Hady on 4/12/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import UIKit

// TODO: Facelift
// - [ ] Circles behind content
// - [ ] Parameteric offset
// - [ ] Replace usage of additionalSafeAreaInsets
// - [ ] Different header modes (fixed, scroll)
// - [ ] Status bar mode for scroll (blur vs plain)
// - [ ] Allow touch through header, scroll for ex

class HeaderContainingViewController: BaseViewController {
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

    private let headerView = NavigationHeaderView.initFromNib()
    private let statusBarBackgroundView = UIVisualEffectView()
    private var statusBarBackgroundViewHeightConstraint: NSLayoutConstraint!
    private var child: HeaderContainingViewControllerChild!
    private var scrollViewObservationToken: NSKeyValueObservation?

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
        updateHeaderViewItems()
        setupStatusBarBackgroundView()

        if let scrollView = child.scrollViewForHeaderTracking {
            bindHeaderView(with: scrollView)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setStatusBarBackgroundViewHeight()
    }



    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        let statusBarHeight = view.safeAreaInsets.top - additionalSafeAreaInsets.top
        let headerHeight = headerView.frame.height
        let headerInset = headerHeight - statusBarHeight
        if additionalSafeAreaInsets.top != headerInset {
            additionalSafeAreaInsets.top = headerInset
        }
    }

    private func setupHeaderView() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        NSLayoutConstraint.activate([
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 166)
        ])
    }

    private func updateHeaderViewItems() {
        headerView.setRightItems(child.navigationHeaderRightItems)
        headerView.setLeftItems(child.navigationHeaderLeftItems)
    }

    private func setupStatusBarBackgroundView() {
        statusBarBackgroundView.alpha = 0
        if #available(iOS 13.0, *) {
            statusBarBackgroundView.effect = UIBlurEffect(style: .prominent)
        }
        statusBarBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusBarBackgroundView)
        NSLayoutConstraint.activate([
            statusBarBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            statusBarBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            statusBarBackgroundView.topAnchor.constraint(equalTo: view.topAnchor),
        ])
        statusBarBackgroundViewHeightConstraint = statusBarBackgroundView.heightAnchor.constraint(equalToConstant: 0)
        statusBarBackgroundViewHeightConstraint.isActive = true
    }

    private func setStatusBarBackgroundViewHeight() {
        guard #available(iOS 13.0, *) else { return }

        guard let statusBarManager = view.window?.windowScene?.statusBarManager else {
            return
        }

        statusBarBackgroundViewHeightConstraint.constant = statusBarManager.statusBarFrame.height
        statusBarBackgroundView.setNeedsLayout()
    }

    private func setupChildViewController(_ childViewController: ChildViewController) {
        addChild(childViewController)
        view.addSubview(childViewController.view)
        childViewController.view.translatesAutoresizingMaskIntoConstraints = false
        childViewController.view.pinToSuperviewEdges()
        childViewController.didMove(toParent: self)
    }

    private func setupChildView(_ childView: ChildView) {
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
        let headerTranslation = -max(0, min(headerView.frame.height, yOffset))
        headerView.transform = CGAffineTransform(translationX: 0, y: headerTranslation)
        statusBarBackgroundView.alpha = abs(headerTranslation / headerView.frame.height)
    }
}
