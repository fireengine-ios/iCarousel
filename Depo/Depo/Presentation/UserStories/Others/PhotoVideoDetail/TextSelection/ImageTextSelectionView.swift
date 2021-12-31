//
//  ImageTextSelectionView.swift
//  TextSelection
//
//  Created by Hady on 12/3/21.
//

import Foundation
import UIKit

final class ImageTextSelectionView: UIView {
    private let highlightView = ImageTextHighlightView()
    private let startGrabber = SelectionGrabberView(dotPosition: .top)
    private let endGrabber = SelectionGrabberView(dotPosition: .bottom)

    //TODO: REMOVE
    private var selectedRange: ClosedRange<Int>?
    private var data: [RecognizedText] {
        return layout.sortedWords
    }

    // MARK: - Setup

    private lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        gesture.cancelsTouchesInView = false
        gesture.numberOfTapsRequired = 1
        return gesture
    }()

    private lazy var startGrabberPanGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(grabberMoved))
        return gesture
    }()

    private lazy var endGrabberPanGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(grabberMoved))
        return gesture
    }()

    private var image: UIImage!
    private var layout: ImageTextLayout!

    convenience init(image: UIImage, recognizedWords: [RecognizedText]) {
        self.init(frame: .zero)
        self.image = image
        self.layout = ImageTextLayout(image: image, recognizedWords: recognizedWords)
        setup()
    }

    private func setup() {
        // redraws selection on size change
        contentMode = .redraw
        backgroundColor = .clear

        // highlight view
        addSubview(highlightView)
        highlightView.layout = layout

        // tap gesture
        addGestureRecognizer(tapGesture)

        // selection grabbers
        addSubview(startGrabber)
        addSubview(endGrabber)

        startGrabber.addGestureRecognizer(startGrabberPanGesture)
        endGrabber.addGestureRecognizer(endGrabberPanGesture)

        startGrabber.isUserInteractionEnabled = true
        endGrabber.isUserInteractionEnabled = true
    }

    @objc private func tapped(_ tapGesture: UITapGestureRecognizer) {
        let location = tapGesture.location(in: self)
        let scaled = layout.imagePoint(for: location)

        let selectedWordIndex = data.firstIndex { text in
            let minY = min(text.bounds.topLeft.y, text.bounds.topRight.y)
            let maxY = max(text.bounds.bottomLeft.y, text.bounds.bottomRight.y)
            return scaled.x >= text.bounds.topLeft.x && scaled.x <= text.bounds.topRight.x &&
            scaled.y >= minY && scaled.y <= maxY
        }

        guard let selectedWordIndex = selectedWordIndex else {
            selectedRange = nil
            selectionChanged()
            hideMenuController()
            return
        }

        let isAlreadySelected = selectedRange?.contains(selectedWordIndex) ?? false
        guard selectedRange == nil || !isAlreadySelected else {
            if UIMenuController.shared.isMenuVisible {
                hideMenuController()
            } else {
                showMenuControllerIfNeeded()
            }
            return
        }

        selectedRange = selectedWordIndex...selectedWordIndex
        selectionChanged()
        showMenuControllerIfNeeded()
    }

    @objc private func grabberMoved(_ panGesture: UIPanGestureRecognizer) {
//        self.touchPhase = SETouchPhaseNone;
//        self.mouseLocation = [gestureRecognizer locationInView:self];
//
//        SESelectionGrabber *startGrabber = self.textSelectionView.startGrabber;
//        SESelectionGrabber *endGrabber = self.textSelectionView.endGrabber;
//

        guard let selectedRange = selectedRange else {
            return
        }

        if panGesture.state == .began || panGesture.state == .changed {
            hideMenuController()
            let location = panGesture.location(in: self)
            let scaled = layout.imagePoint(for: location)
            print(#function, location, scaled)

            if panGesture == startGrabberPanGesture {
                let firstSelectedIndex = data.firstIndex { text in
                    let maxX = max(text.bounds.topRight.x, text.bounds.bottomRight.x)
                    let maxY = min(text.bounds.bottomLeft.y, text.bounds.bottomRight.y)
                    return scaled.x <= maxX && scaled.y <= maxY
                }

                guard let firstSelectedIndex = firstSelectedIndex else {
                    return
                }


                guard firstSelectedIndex <= selectedRange.last! else {
                    return
                }


                self.selectedRange = firstSelectedIndex...selectedRange.last!
                print(#function, self.selectedRange)
                selectionChanged()

            } else if panGesture == endGrabberPanGesture {

                let lastSelectedIndex = data.lastIndex { text in
                    let minX = min(text.bounds.topLeft.x, text.bounds.bottomLeft.x)
                    let minY = min(text.bounds.topLeft.y, text.bounds.topRight.y)
                    return scaled.x >= minX && scaled.y >= minY
                }

                guard let lastSelectedIndex = lastSelectedIndex else {
                    return
                }


                guard lastSelectedIndex >= selectedRange.first! else {
                    return
                }

                self.selectedRange = selectedRange.first!...lastSelectedIndex
                print(#function, self.selectedRange)
                selectionChanged()
            }

        } else if (panGesture.state == .ended || panGesture.state == .cancelled || panGesture.state == .failed) {
            showMenuControllerIfNeeded()
        }
    }

    private func selectionChanged() {
        // redraw selection
        setNeedsDisplay()
        // update grabbers position
        setNeedsLayout()
    }

    private var firstSelectedWord: RecognizedText? {
        if let selectedRange = selectedRange {
            return data[selectedRange.first!]
        }

        return nil
    }

    private var lastSelectedWord: RecognizedText? {
        if let selectedRange = selectedRange {
            return data[selectedRange.last!]
        }

        return nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layout.imageViewSize = bounds.size

        highlightView.frame = bounds
        // update position of grabber views
        if let firstSelectedWord = firstSelectedWord {
            startGrabber.transform = .identity
            startGrabber.isHidden = false
            endGrabber.isHidden = false
            print("firstSelectedWord", firstSelectedWord)
            startGrabber.frame.origin = layout.imageViewPoint(for: firstSelectedWord.bounds.topLeft)

            startGrabber.frame.size.width = 32
            startGrabber.frame.origin.x -= 32/2
            startGrabber.frame.origin.y -= 10
            let height = CGPointDistance(from: firstSelectedWord.bounds.topLeft, to: firstSelectedWord.bounds.bottomLeft)
            startGrabber.frame.size.height = layout.imageViewDimension(for: height) + 10

            let topRight = layout.imageViewPoint(for: firstSelectedWord.bounds.topLeft)
            let bottomRight = layout.imageViewPoint(for: firstSelectedWord.bounds.bottomLeft)
            let tan = (bottomRight.x - topRight.x) / (bottomRight.y - topRight.y)
            let rotationAngle = -atan(tan) //* 180 / Double.pi
            startGrabber.setRotationAngle(rotationAngle)
            print("rotationAngle", rotationAngle)


            if let lastSelectedWord = lastSelectedWord {
                print("lastSelectedWord", lastSelectedWord)
                endGrabber.transform = .identity
                endGrabber.frame.origin = layout.imageViewPoint(for: lastSelectedWord.bounds.topRight)
                endGrabber.frame.size.width = 32
                endGrabber.frame.origin.x -= 32/2
                let height = CGPointDistance(from: lastSelectedWord.bounds.topRight, to: lastSelectedWord.bounds.bottomRight)
                endGrabber.frame.size.height = layout.imageViewDimension(for: height) + 10

                // y2-y1 / x2-x1
                // tan-1

                let topRight = layout.imageViewPoint(for: lastSelectedWord.bounds.topRight)
                let bottomRight = layout.imageViewPoint(for: lastSelectedWord.bounds.bottomRight)
                let tan = (bottomRight.x - topRight.x) / (bottomRight.y - topRight.y)
                let rotationAngle = -atan(tan) //* 180 / Double.pi
                endGrabber.setRotationAngle(rotationAngle)
                print("rotationAngle", rotationAngle)
            }
        } else {
            startGrabber.isHidden = true
            endGrabber.isHidden = true
        }
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        context.setFillColor(UIColor.systemBlue.withAlphaComponent(0.5).cgColor)

        if let selectedRange = selectedRange {
            for i in selectedRange {
                let word = data[i]

                let path = CGMutablePath()
                let topLeft = layout.imageViewPoint(for: word.bounds.topLeft)
                let topRight = layout.imageViewPoint(for: word.bounds.topRight)
                let bottomRight = layout.imageViewPoint(for: word.bounds.bottomRight)
                let bottomLeft = layout.imageViewPoint(for: word.bounds.bottomLeft)

                path.move(to: topLeft)
                path.addLine(to: topRight)
                path.addLine(to: bottomRight)
                path.addLine(to: bottomLeft)
                path.addLine(to: topLeft)
                context.addPath(path)
            }
        }

        context.drawPath(using: .fill)


//        context.setStrokeColor(UIColor.red.cgColor)
//        context.setLineWidth(1)
//        for word in data {
//            let path = CGMutablePath()
//            let topLeft = createScaledPoint(featurePoint: word.bounds.topLeft, imageSize: image.size, viewSize: bounds.size)
//            let topRight = createScaledPoint(featurePoint: word.bounds.topRight, imageSize: image.size, viewSize: bounds.size)
//            let bottomRight = createScaledPoint(featurePoint: word.bounds.bottomRight, imageSize: image.size, viewSize: bounds.size)
//            let bottomLeft = createScaledPoint(featurePoint: word.bounds.bottomLeft, imageSize: image.size, viewSize: bounds.size)
//
//            path.move(to: topLeft)
//            path.addLine(to: topRight)
//            path.addLine(to: bottomRight)
//            path.addLine(to: bottomLeft)
//            path.addLine(to: topLeft)
//            context.addPath(path)
//        }
//
//        context.drawPath(using: .stroke)
    }

    // MARK: - MenuController

    override var canBecomeFirstResponder: Bool { true }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(copy(_:)) || action == #selector(selectAll(_:))
    }

    private func showMenuControllerIfNeeded() {
        // TODO: move to layout
        guard let selectedRange = self.selectedRange else { return }

        becomeFirstResponder()
        let menuController = UIMenuController.shared
        var selectionBoundingRect: CGRect!
        for index in selectedRange {
            var wordRect = data[index].bounds.boundingBox
            wordRect.origin = layout.imageViewPoint(for: wordRect.origin)
            wordRect.size.width = layout.imageViewDimension(for: wordRect.size.width)
            wordRect.size.height = layout.imageViewDimension(for: wordRect.size.height)
            if selectionBoundingRect == nil {
                selectionBoundingRect = wordRect
            } else {
                selectionBoundingRect = selectionBoundingRect.union(wordRect)
            }
        }

        if #available(iOS 13.0, *) {
            menuController.showMenu(from: self, rect: selectionBoundingRect)
        } else {
            menuController.setTargetRect(selectionBoundingRect, in: self)
            menuController.setMenuVisible(true, animated: true)
        }
    }

    private func hideMenuController() {
        let menuController = UIMenuController.shared
        if #available(iOS 13.0, *) {
            menuController.hideMenu(from: self)
        } else {
            menuController.setMenuVisible(false, animated: true)
        }
    }

    // actions
    override func copy(_ sender: Any?) {
        guard let selectedRange = selectedRange else {
            return
        }

        let selectedWords = data[selectedRange]

        let text = selectedWords.map { $0.text }.joined(separator: " ")
        UIPasteboard.general.string = text
    }

    override func selectAll(_ sender: Any?) {
        selectedRange = 0...data.count-1
        selectionChanged()
    }
}
