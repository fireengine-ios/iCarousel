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
        backgroundColor = UIColor.black.withAlphaComponent(0.4)
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

        // TODO: Round corners
//        for block in layout.sortedBlocks {
//            for (index, line) in block.lines.enumerated() {
//                let topLeft = layout.imageViewPoint(for: line.bounds.topLeft)
//                let topRight = layout.imageViewPoint(for: line.bounds.topRight)
//                let bottomRight = layout.imageViewPoint(for: line.bounds.bottomRight)
//
//                let isFirstLine = index == 0
//                if isFirstLine {
//                    path.move(to: topLeft)
//                }
//
//                path.addLine(to: topRight)
//                path.addLine(to: bottomRight)
//            }
//
//            for line in block.lines.reversed() {
//                let topLeft = layout.imageViewPoint(for: line.bounds.topLeft)
//                let bottomLeft = layout.imageViewPoint(for: line.bounds.bottomLeft)
//
//                path.addLine(to: bottomLeft)
//                path.addLine(to: topLeft)
//            }
//        }
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
