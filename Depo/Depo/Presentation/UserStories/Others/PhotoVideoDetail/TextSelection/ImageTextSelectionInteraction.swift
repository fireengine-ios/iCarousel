//
//  ImageTextSelectionInteraction.swift
//  TextSelection
//
//  Created by Hady on 12/3/21.
//

import Foundation
import UIKit

public class ImageTextSelectionInteraction: NSObject, UIInteraction {
    /// The list of recognized words. Must be set before adding the interaction to a view.
    public var recognizedWords: [RecognizedText]?

    /// An array of gestures that should fail when taping selectable content.
    public var gesturesToIgnore: [UIGestureRecognizer]?

    /// The UIImageView instance associated with the interaction.
    private(set) public weak var view: UIView?

    /// The view responsible for higlight & selection.
    private var selectionView: ImageTextSelectionView?

    public convenience init(recognizedWords: [RecognizedText]) {
        self.init()
        self.recognizedWords = recognizedWords
    }

    public func willMove(to view: UIView?) {
        selectionView?.removeFromSuperview()
        selectionView = nil
    }

    public func didMove(to view: UIView?) {
        self.view = view

        guard let newView = view else { return }

        guard let imageView = newView as? UIImageView else {
            invalidUsage("The interaction can only be added to a UIImageView")
            return
        }

        guard let image = imageView.image else {
            invalidUsage("""
Interaction should be added on a UIImageView with an image.
Set an image to your UIImageView before adding the interaction.
""")
            return
        }

        guard let recognizedWords = recognizedWords else {
            assertionFailure("Set recognizedWords before adding the interaction.")
            return
        }

        newView.isUserInteractionEnabled = true

        let selectionView = ImageTextSelectionView(image: image, recognizedWords: recognizedWords)
        selectionView.gesturesToIgnore = gesturesToIgnore
        selectionView.isUserInteractionEnabled = true
        selectionView.translatesAutoresizingMaskIntoConstraints = false
        newView.addSubview(selectionView)
        NSLayoutConstraint.activate([
            selectionView.leadingAnchor.constraint(equalTo: newView.leadingAnchor),
            selectionView.trailingAnchor.constraint(equalTo: newView.trailingAnchor),
            selectionView.topAnchor.constraint(equalTo: newView.topAnchor),
            selectionView.bottomAnchor.constraint(equalTo: newView.bottomAnchor)
        ])

        self.selectionView = selectionView
    }

    private func invalidUsage(_ message: String) {
        assertionFailure("\(type(of: self)): \(message)")
    }
}
