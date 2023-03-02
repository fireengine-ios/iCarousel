//
//  AlertFilesActionView.swift
//  Depo
//
//  Created by Hady on 6/14/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation
import UIKit

protocol AlertFilesActionViewDelegate: AnyObject {
    func alertFilesActionView(_ actionView: AlertFilesActionView, handleTapForAction action: AlertFilesAction)
}

class AlertFilesActionView: UIView, NibInit {
    @IBOutlet private var imageView: UIImageView! {
        willSet {
            newValue.tintColor = AppColor.label.color
        }
    }

    @IBOutlet private var label: UILabel! {
        willSet {
            newValue.font = UIFont.appFont(.medium, size: 16, relativeTo: .body)
            newValue.textColor = AppColor.label.color
        }
    }

    @IBOutlet private var separatorView: UIView! {
        willSet {
            newValue.backgroundColor = AppColor.separator.color
        }
    }

    private var currentAction: AlertFilesAction?

    weak var delegate: AlertFilesActionViewDelegate?

    var isHighlighted: Bool = false {
        didSet {
            backgroundColor = isHighlighted ? AppColor.separator.color : nil
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        addGestureRecognizer(TapGestureRecognizerWithClosure { [weak self] in
            guard let self = self, let action = self.currentAction else {
                return
            }
            self.delegate?.alertFilesActionView(self, handleTapForAction: action)
        })
    }

    func configure(with action: AlertFilesAction, showsBottomSeparator: Bool) {
        currentAction = action
        
        imageView.image = action.isTemplate ? action.icon?.withRenderingMode(.alwaysTemplate) : action.icon
        label.text = action.title
        separatorView.isHidden = !showsBottomSeparator
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        updateHighlightState(with: touches)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        updateHighlightState(with: touches)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        isHighlighted = false
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        isHighlighted = false
    }

    private func updateHighlightState(with touches: Set<UITouch>) {
        guard let touch = touches.first else {
            return
        }

        let point = touch.location(in: self)
        isHighlighted = bounds.contains(point)
    }
}
