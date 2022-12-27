//
//  ImageTextHighlightView.swift
//  TextSelection
//
//  Created by Hady on 12/30/21.
//

import Foundation
import UIKit

final class ImageTextHighlightView: UIView {
    var layout: ImageTextLayout!
    var image = UIImage()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = AppColor.tint.color.withAlphaComponent(0.4)
        isUserInteractionEnabled = false
        // Hack to make highlight view below grabber views
        layer.zPosition = -1
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        updateLayerMask()
    }

    private func updateLayerMask() {
        let path = UIBezierPath()

        for word in layout.words {
            let topLeft = layout.imageViewPoint(for: word.bounds.topLeft)
            let topRight = layout.imageViewPoint(for: word.bounds.topRight)
            let bottomRight = layout.imageViewPoint(for: word.bounds.bottomRight)
            let bottomLeft = layout.imageViewPoint(for: word.bounds.bottomLeft)

            path.move(to: topLeft)
            path.addLine(to: topRight)
            path.addLine(to: bottomRight)
            path.addLine(to: bottomLeft)
            path.close()
        }

        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath

        layer.mask = maskLayer
    }
}
