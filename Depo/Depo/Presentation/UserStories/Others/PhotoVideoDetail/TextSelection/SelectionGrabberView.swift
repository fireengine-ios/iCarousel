//
//  SelectionGrabberView.swift
//  TextSelection
//
//  Created by Hady on 12/7/21.
//

import Foundation
import UIKit

final class SelectionGrabberView: UIView {
    enum DotPosition {
        case top
        case bottom
    }

    var dotPosition: DotPosition = .top
    let caretWidth: CGFloat = 2
    let dotSize: CGFloat = 10

    convenience init(dotPosition: DotPosition) {
        self.init(frame: .zero)
        self.dotPosition = dotPosition
        setup()
    }

    func setRotationAngle(_ angle: CGFloat) {
        switch dotPosition {
        case .top:
            setAnchorPoint(CGPoint(x: 0.5, y: dotView.frame.height / bounds.height))
        case .bottom:
            setAnchorPoint(CGPoint(x: 0.5, y: 0))
        }

        transform = CGAffineTransform(rotationAngle: angle)
        setAnchorPoint(CGPoint(x: 0.5, y: 0.5))
    }

    private let caretView = UIView()
    private let dotView = UIView()

    private func setup() {
        caretView.frame = CGRect(x: 0, y: 0, width: caretWidth, height: 0)
        caretView.backgroundColor = .blue
        addSubview(caretView)

        dotView.frame = CGRect(x: 0, y: 0, width: dotSize, height: dotSize)
        dotView.backgroundColor = .blue
        dotView.clipsToBounds = false
        dotView.layer.cornerRadius = dotSize / 2
        dotView.layer.masksToBounds = false
        addSubview(dotView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        caretView.frame.origin.x = (bounds.width - caretView.frame.width) / 2
        caretView.frame.size.height = bounds.height

        dotView.frame.origin.x = (bounds.width - dotView.frame.width) / 2
        switch dotPosition {
        case .top:
            dotView.frame.origin.y = 0
        case .bottom:
            dotView.frame.origin.y = bounds.height - dotView.bounds.height
        }
    }

    private func setAnchorPoint(_ point: CGPoint) {
        var newPoint = CGPoint(x: bounds.size.width * point.x, y: bounds.size.height * point.y)
        var oldPoint = CGPoint(x: bounds.size.width * layer.anchorPoint.x, y: bounds.size.height * layer.anchorPoint.y);

        newPoint = newPoint.applying(transform)
        oldPoint = oldPoint.applying(transform)

        var position = layer.position

        position.x -= oldPoint.x
        position.x += newPoint.x

        position.y -= oldPoint.y
        position.y += newPoint.y

        layer.position = position
        layer.anchorPoint = point
    }
}
