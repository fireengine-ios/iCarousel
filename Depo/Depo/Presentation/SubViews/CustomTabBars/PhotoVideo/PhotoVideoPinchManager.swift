//
//  PhotoVideoPinchManager.swift
//  Depo
//
//  Created by Hady on 4/29/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation
import UIKit

final class PhotoVideoPinchManager: NSObject, UIGestureRecognizerDelegate {
    private weak var collectionView: UICollectionView!

    init(collectionView: UICollectionView) {
        super.init()

        pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinch(_:)))
        pinchGesture.delegate = self
        collectionView.addGestureRecognizer(pinchGesture)

        self.collectionView = collectionView
    }

    private var pinchGesture: UIPinchGestureRecognizer!
    private var transitionLayout: UICollectionViewTransitionLayout?
    private var isZoomingIn = false
    private var currentPhotoVideoLayout: PhotoVideoCollectionViewLayout? {
        collectionView?.collectionViewLayout as? PhotoVideoCollectionViewLayout
    }

    @objc func pinch(_ gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began:
            print("pinch", "began", gesture.scale, gesture.velocity)
            guard let newSize = getNewGridSizeForGestureStart() else {
                fatalError()
                break
            }
            print("pinch", "began", newSize)
            isZoomingIn = gesture.velocity > 0
            let newLayout = PhotoVideoCollectionViewLayout(gridSize: newSize)
            newLayout.delegate = currentPhotoVideoLayout?.delegate
            newLayout.pinsSectionHeadersToLayoutGuide = currentPhotoVideoLayout?.pinsSectionHeadersToLayoutGuide
            transitionLayout = collectionView.startInteractiveTransition(to: newLayout) { [weak collectionView] _, _ in
                // Hack: fixes header disposition in HeaderContainingViewController.swift#192
                // Reason this is needed is that after the layout transition completes
                // the last contentOffset update received in HeaderContainingViewController is sometimes wrong
                // causing the header to appear where it shouldn't.
                // The contentOffset seems to be correct here so just triggering a kvo update to fix the header.
                collectionView?.contentOffset = collectionView!.contentOffset
            }

        case .changed:
            print("pinch", "changed", gesture.scale, gesture.velocity)
            transitionLayout?.transitionProgress = abs(1.0 - gesture.scale)

        case .ended:
            print("pinch", "ended")
            collectionView.finishInteractiveTransition()
            transitionLayout = nil

        case .cancelled, .failed:
            print("pinch", "failed/cancelled")
            collectionView.cancelInteractiveTransition()
            transitionLayout = nil

        default:
            break
        }
    }


    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer == self.pinchGesture else {
            return true
        }

        return getNewGridSizeForGestureStart() != nil
    }

    private func getNewGridSizeForGestureStart() -> PhotoVideoCollectionViewLayout.GridSize? {
        guard let currentLayout = collectionView?.collectionViewLayout as? PhotoVideoCollectionViewLayout else {
            return nil
        }

        return pinchGesture.velocity > 0 ? currentLayout.gridSize.previous : currentLayout.gridSize.next
    }
}
