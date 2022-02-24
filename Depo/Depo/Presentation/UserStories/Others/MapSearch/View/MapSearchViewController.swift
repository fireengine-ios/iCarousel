//
//  MapSearchViewController.swift
//  Depo
//
//  Created by Hady on 2/15/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation
import MapKit

final class MapSearchViewController: BaseViewController {
    var output: MapSearchViewOutput!
    private var currentGroups: [MapMediaGroup] = []

    @IBOutlet private weak var progressView: UIProgressView! {
        willSet {
            newValue.alpha = 0
            newValue.progress = 0
        }
    }

    @IBOutlet private weak var mapView: MKMapView! {
        willSet {
            newValue.isRotateEnabled = false
            newValue.register(ItemGroupAnnotationView.self,
                              forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        output.viewIsReady()
        mapView.delegate = self
    }
}

extension MapSearchViewController: MapSearchViewInput {
    func showLoading() {
        progressView.alpha = 1
        let fakeProgress: Float = 0.8
        if progressView.progress != fakeProgress {
            UIView.animate(withDuration: NumericConstants.slowAnimationDuration) {
                self.progressView.progress = fakeProgress
                self.progressView.layoutIfNeeded()
            }
        }
    }

    func hideLoading() {
        UIView.animate(withDuration: NumericConstants.fastAnimationDuration, delay: 0, options: [.beginFromCurrentState]) {
            self.progressView.progress = 1.0
            self.progressView.layoutIfNeeded()
        } completion: { _ in
            UIView.animate(withDuration: NumericConstants.animationDuration, delay: 0.5) {
                self.progressView.alpha = 0
            } completion: { _ in
                self.progressView.progress = 0
            }
        }
    }

    func setZoomRange(minimumZoomLevel: Int, maximumZoomLevel: Int) {
        if #available(iOS 13.0, *) {
            mapView.setCameraZoomRange(
                minimumZoomLevel: CGFloat(minimumZoomLevel),
                maximumZoomLevel: CGFloat(maximumZoomLevel),
                animated: true
            )
        }
    }

    func setCurrentGroups(_ groups: [MapMediaGroup]) {
        // TODO: handle blinks?
        mapView.removeAnnotations(mapView.annotations)
        // TODO: maybe move these to presenter
        currentGroups = groups

        let annotations = groups.map { group -> MKAnnotation in
            let annotation = ItemGroupAnnotation()
            annotation.coordinate = group.point.locationCoorindate2D
            annotation.item = WrapData(privateShareFileInfo: group.sample)
            annotation.itemCount = group.count
            return annotation
        }
        mapView.addAnnotations(annotations)
    }
}

extension MapSearchViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let params = MapSearchParams(northWest: mapView.northWest,
                                     southEast: mapView.southEast,
                                     zoomLevel: Int(mapView.zoomLevel.rounded(.down)))
        output.mapRegionChanged(params: params)
    }
}
