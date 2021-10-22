//
//  TooltipViewController.swift
//  Depo
//
//  Created by Hady on 10/18/21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

final class TooltipViewController: UIViewController {
    convenience init(message: String) {
        self.init()
        label.text = message
    }

    func present(over viewController: UIViewController,
                 sourceView: UIView,
                 permittedArrowDirections: UIPopoverArrowDirection = .any) {
        modalPresentationStyle = .popover
        popoverPresentationController?.sourceView = sourceView
        popoverPresentationController?.permittedArrowDirections = permittedArrowDirections
        popoverPresentationController?.delegate = self
        popoverPresentationController?.backgroundColor = AppColor.secondaryBackground.color

        viewController.present(self, animated: true)
    }

    let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.TurkcellSaturaFont(size: 18)
        label.textColor = AppColor.darkTextAndLightGray.color
        label.numberOfLines = 0
        return label
    }()

    var widthInRegularSizeClass: CGFloat = 450

    override func loadView() {
        super.loadView()

        view.backgroundColor = .clear

        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)

        let superviewLayoutGuide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: superviewLayoutGuide.leadingAnchor, constant: 14),
            label.topAnchor.constraint(equalTo: superviewLayoutGuide.topAnchor, constant: 14),
            label.trailingAnchor.constraint(equalTo: superviewLayoutGuide.trailingAnchor, constant: -14),
            label.bottomAnchor.constraint(equalTo: superviewLayoutGuide.bottomAnchor, constant: -14)
        ])

        preferredContentSize = view.systemLayoutSizeFitting(
            CGSize(width: preferredWidth, height: 0),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .defaultLow
        )
    }

    private var preferredWidth: CGFloat {
        let maxWidth = view.frame.width - 40

        if traitCollection.horizontalSizeClass == .regular || traitCollection.userInterfaceIdiom == .pad {
            return min(widthInRegularSizeClass, maxWidth)
        }

        return maxWidth
    }
}

extension TooltipViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController,
                                   traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}
