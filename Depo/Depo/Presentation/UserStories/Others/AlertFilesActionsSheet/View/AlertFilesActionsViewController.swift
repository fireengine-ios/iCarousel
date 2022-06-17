//
//  AlertFilesActionsViewController.swift
//  Depo
//
//  Created by Hady on 6/14/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation
import UIKit

class AlertFilesActionsViewController: UIViewController {
    private let stackView = UIStackView()

    override func viewDidLoad() {
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        stackView.pinToSuperviewEdges(offset: .init(top: 8, left: 0, bottom: 8, right: 0))
    }

    func configure(with actions: [AlertFilesAction]) {
        emptyStackView()

        let lastIndex = actions.count - 1
        for (index, action) in actions.enumerated() {
            let actionView = AlertFilesActionView.initFromNib()
            actionView.configure(with: action, showsBottomSeparator: index != lastIndex)
            actionView.delegate = self
            stackView.addArrangedSubview(actionView)
        }
    }

    private func emptyStackView() {
        stackView.arrangedSubviews.forEach { view in
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
}

extension AlertFilesActionsViewController: AlertFilesActionViewDelegate {
    func alertFilesActionView(_ actionView: AlertFilesActionView, handleTapForAction action: AlertFilesAction) {
        dismiss(animated: true, completion: action.handler)
    }
}
