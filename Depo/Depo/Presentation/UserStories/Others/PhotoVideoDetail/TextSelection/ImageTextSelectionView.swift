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

    private var selection: ClosedRange<ImageTextSelectionIndex>?

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
    var gesturesToIgnore: [UIGestureRecognizer]?

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
        let point = layout.imagePoint(for: tapGesture.location(in: self))

        guard let tappedWordIndex = layout.findFirstIndex(predicate: { word in
            let minX = word.bounds.topLeft.x
            let maxX = word.bounds.topRight.x
            let minY = min(word.bounds.topLeft.y, word.bounds.topRight.y)
            let maxY = max(word.bounds.bottomLeft.y, word.bounds.bottomRight.y)
            return point.x >= minX && point.x <= maxX && point.y >= minY && point.y <= maxY
        }) else {
            selection = nil
            selectionChanged()
            hideMenuController()
            return
        }

        let isAlreadySelected = selection?.contains(tappedWordIndex) ?? false
        guard selection == nil || !isAlreadySelected else {
            if UIMenuController.shared.isMenuVisible {
                hideMenuController()
            } else {
                showMenuControllerIfNeeded()
            }
            return
        }

        selection = tappedWordIndex...tappedWordIndex
        selectionChanged()
        showMenuControllerIfNeeded()
    }

    @objc private func grabberMoved(_ panGesture: UIPanGestureRecognizer) {
        guard let selection = self.selection else {
            return
        }

        if panGesture.state == .began || panGesture.state == .changed {
            hideMenuController()
            let location = panGesture.location(in: self)
            let point = layout.imagePoint(for: location)

            if panGesture == startGrabberPanGesture {
                guard let firstSelectedIndex = layout.findFirstIndex(predicate: { word in
                    let maxX = max(word.bounds.topRight.x, word.bounds.bottomRight.x)
                    let maxY = min(word.bounds.bottomLeft.y, word.bounds.bottomRight.y)
                    return point.x <= maxX && point.y <= maxY
                }) else {
                    return
                }

                guard firstSelectedIndex <= selection.upperBound else {
                    return
                }


                self.selection = firstSelectedIndex...selection.upperBound
                selectionChanged()

            } else if panGesture == endGrabberPanGesture {

                guard let lastSelectedIndex = layout.findLastIndex(predicate: { word in
                    let minX = min(word.bounds.topLeft.x, word.bounds.bottomLeft.x)
                    let minY = min(word.bounds.topLeft.y, word.bounds.topRight.y)
                    return point.x >= minX && point.y >= minY
                }) else {
                    return
                }

                guard lastSelectedIndex >= selection.lowerBound else {
                    return
                }

                self.selection = selection.lowerBound...lastSelectedIndex
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
        guard let selection = self.selection else {
            return nil
        }

        let index = selection.lowerBound
        return layout.sortedLines[index.line].words[index.word]
    }

    private var lastSelectedWord: RecognizedText? {
        guard let selection = self.selection else {
            return nil
        }

        let index = selection.upperBound
        return layout.sortedLines[index.line].words[index.word]
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

        context.setFillColor(tintColor.withAlphaComponent(0.5).cgColor)

        if let selection = self.selection {
            let ranges = layout.rangesOfLinesBetween(first: selection.lowerBound, last: selection.upperBound)
            for lineRange in ranges {
                let firstWord = layout.word(at: lineRange.lowerBound)
                let lastWord = layout.word(at: lineRange.upperBound)

                let path = CGMutablePath()
                let topLeft = layout.imageViewPoint(for: firstWord.bounds.topLeft)
                let topRight = layout.imageViewPoint(for: lastWord.bounds.topRight)
                let bottomRight = layout.imageViewPoint(for: lastWord.bounds.bottomRight)
                let bottomLeft = layout.imageViewPoint(for: firstWord.bounds.bottomLeft)

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
//            let topLeft = layout.imageViewPoint(for: word.bounds.topLeft)
//            let topRight = layout.imageViewPoint(for: word.bounds.topRight)
//            let bottomRight = layout.imageViewPoint(for: word.bounds.bottomRight)
//            let bottomLeft = layout.imageViewPoint(for: word.bounds.bottomLeft)
//
//            path.move(to: topLeft)
//            path.addLine(to: topRight)
//            path.addLine(to: bottomRight)
//            path.addLine(to: bottomLeft)
//            path.addLine(to: topLeft)
//            context.addPath(path)
//        }

//        context.drawPath(using: .stroke)
    }

    // MARK: - MenuController

    override var canBecomeFirstResponder: Bool { true }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(copy(_:)) || action == #selector(selectAll(_:))
    }

    private func showMenuControllerIfNeeded() {
        guard let selection = self.selection else {
            return
        }

        becomeFirstResponder()
        let menuController = UIMenuController.shared
        var selectionBoundingRect: CGRect!

        let ranges = layout.rangesOfLinesBetween(first: selection.lowerBound, last: selection.upperBound)
        for lineRange in ranges {
            let startIndex = lineRange.lowerBound
            let endIndex = lineRange.upperBound
            let currentLine = startIndex.line

            let selectedWords = layout.getWords(inLine: currentLine, startIndex: startIndex.word, endIndex: endIndex.word)
            for word in selectedWords {
                var wordRect = word.bounds.boundingBox
                wordRect.origin = layout.imageViewPoint(for: wordRect.origin)
                wordRect.size.width = layout.imageViewDimension(for: wordRect.size.width)
                wordRect.size.height = layout.imageViewDimension(for: wordRect.size.height)
                if selectionBoundingRect == nil {
                    selectionBoundingRect = wordRect
                } else {
                    selectionBoundingRect = selectionBoundingRect.union(wordRect)
                }
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
        guard let selection = self.selection else {
            return
        }

        var lines: [String] = []

        let ranges = layout.rangesOfLinesBetween(first: selection.lowerBound, last: selection.upperBound)
        for lineRange in ranges {
            let startIndex = lineRange.lowerBound
            let endIndex = lineRange.upperBound
            let currentLine = startIndex.line

            let selectedWords = layout.getWords(inLine: currentLine, startIndex: startIndex.word, endIndex: endIndex.word)
            let combined = selectedWords.map({ $0.text }).joined(separator: " ")
            lines.append(combined)
        }

        let text = lines.joined(separator: "\n")
        UIPasteboard.general.string = text
    }

    override func selectAll(_ sender: Any?) {
        guard let startIndex = layout.startIndex, let endIndex = layout.endIndex else {
            return
        }

        selection = startIndex...endIndex
        selectionChanged()
    }

    // MARK: - Gestures
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gesturesToIgnore?.contains(gestureRecognizer) == true else {
            return super.gestureRecognizerShouldBegin(gestureRecognizer)
        }

        // ignore when unselecting / tapping selection
        guard selection == nil else {
            return false
        }

        // TODO: move to a separate func
        let point = layout.imagePoint(for: tapGesture.location(in: self))
        let tappedWord = layout.findFirstIndex(predicate: { word in
            let minX = word.bounds.topLeft.x
            let maxX = word.bounds.topRight.x
            let minY = min(word.bounds.topLeft.y, word.bounds.topRight.y)
            let maxY = max(word.bounds.bottomLeft.y, word.bounds.bottomRight.y)
            return point.x >= minX && point.x <= maxX && point.y >= minY && point.y <= maxY
        })

        // ignore when selecting a word
        if tappedWord != nil {
            return false
        }

        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
}
