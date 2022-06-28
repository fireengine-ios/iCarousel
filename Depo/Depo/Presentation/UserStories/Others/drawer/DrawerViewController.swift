//
//  DrawerViewController.swift
//  drawer
//
//  Created by Hady on 6/11/22.
//

import Foundation
import UIKit

final class DrawerViewController: UIViewController {

    init(content: UIViewController) {
        self.contentViewController = content
        super.init(nibName: nil, bundle: nil)
        transitioningDelegate = DrawerTransitioningDelegate.instance
        modalPresentationStyle = .custom
    }

    private override init(nibName: String?, bundle: Bundle?) {
        fatalError()
    }

    required init?(coder: NSCoder) { fatalError() }

    private let contentViewController: UIViewController
    var showsDrawerIndicator = true
    let drawerIndicatorView = UIView()
    let contentContainerView = ResizableScrollView()

    var drawerPresentationController: DrawerPresentationController? {
        presentationController as? DrawerPresentationController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = AppColor.drawerBackground.color
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        view.layer.shadowColor = AppColor.drawerShadow.cgColor
        view.layer.shadowRadius = 24
        view.layer.shadowOffset = CGSize(width: 0, height: 6)

        setupDrawerIndicator()
        setupContainerView()
        setupContentView()
    }

    func layoutDrawerContentViewBeforePresenting() {
        guard let drawerPresentationController = drawerPresentationController else {
            return
        }

        view.frame = drawerPresentationController.frameOfPresentedViewInContainerView
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    private func setupDrawerIndicator() {
        let indicatorWidth: CGFloat = 30
        let indicatorHeight: CGFloat = 5

        drawerIndicatorView.backgroundColor = AppColor.drawerIndicator.color
        view.addSubview(drawerIndicatorView)
        drawerIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        drawerIndicatorView.layer.cornerRadius = indicatorHeight / 2
        NSLayoutConstraint.activate([
            drawerIndicatorView.widthAnchor.constraint(equalToConstant: indicatorWidth),
            drawerIndicatorView.heightAnchor.constraint(equalToConstant: indicatorHeight),
            drawerIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            drawerIndicatorView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8)
        ])

        drawerIndicatorView.isHidden = !showsDrawerIndicator
    }

    private func setupContainerView() {
        view.addSubview(contentContainerView)
        contentContainerView.translatesAutoresizingMaskIntoConstraints = false

        let topConstraint: NSLayoutConstraint
        if showsDrawerIndicator {
            topConstraint = contentContainerView.topAnchor.constraint(equalTo: drawerIndicatorView.bottomAnchor)
        } else {
            topConstraint = contentContainerView.topAnchor.constraint(equalTo: view.topAnchor)
        }

        NSLayoutConstraint.activate([
            topConstraint,
            contentContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentContainerView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor)
        ])
    }

    func setupContentView() {
        let contentView: UIView = contentViewController.view
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentContainerView.addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: contentContainerView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: contentContainerView.widthAnchor)
        ])

        contentViewController.willMove(toParent: self)
        addChild(contentViewController)
        contentViewController.didMove(toParent: self)
    }
}
