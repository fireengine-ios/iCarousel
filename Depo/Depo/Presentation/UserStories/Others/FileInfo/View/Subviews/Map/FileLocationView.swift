//
//  FileLocationView.swift
//  Depo
//
//  Created by Hady on 11/9/21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit
import MapKit
import Contacts

protocol FileLocationViewProtocol {
    func setLocation(latitude: Double, longitude: Double, item: Item)
}

final class FileLocationView: UIView, NibInit, FileLocationViewProtocol {

    static func view() -> FileLocationView {
        return FileLocationView.initFromNib()
    }


    // MARK: - Outlets
    @IBOutlet private weak var stackView: UIStackView! {
        willSet {
            newValue.axis = .vertical
            newValue.alignment = .fill
            newValue.distribution = .fill
        }
    }

    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.text = localized(.fileInfoLocation)
            newValue.font = .TurkcellSaturaBolFont(size: 14)
            newValue.textColor = AppColor.marineTwoAndTealish.color
        }
    }

    @IBOutlet private weak var valueLabel: UILabel! {
        willSet {
            newValue.font = .TurkcellSaturaFont(size: 14)
            newValue.textColor = .lrBrownishGrey
            newValue.numberOfLines = 0
        }
    }

    @IBOutlet private weak var mapView: MKMapView! {
        willSet {
            newValue.layer.cornerRadius = 12
            newValue.isUserInteractionEnabled = false

            newValue.register(ItemAnnotationView.self,
                              forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        }
    }

    @IBOutlet private weak var mapTapView: UIView! {
        willSet {
            newValue.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(mapTapped)))
            newValue.isUserInteractionEnabled = true
        }
    }


    // MARK: - Config
    private lazy var geoCoder = CLGeocoder()
    private var currentCoordinate: CLLocationCoordinate2D?

    override func awakeFromNib() {
        super.awakeFromNib()
        configureStackViewSpacing()
    }

    private func configureStackViewSpacing() {
        stackView.spacing = 8
        stackView.setCustomSpacing(18, after: valueLabel)
    }

    @objc private func mapTapped() {
        guard let coordinate = currentCoordinate else { return }

        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: coordinate),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: mapView.region.span)
        ]
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        mapItem.openInMaps(launchOptions: options)
    }

    // MARK: - Public
    func setLocation(latitude: Double, longitude: Double, item: Item) {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        currentCoordinate = coordinate

        setAnnotationAndUpdateRegion(coordinate: coordinate, item: item)

        getAddress(latitude: latitude, longitude: longitude) { [weak self] address in
            self?.valueLabel.text = address
            self?.valueLabel.isHidden = address == nil || address?.isEmpty == true
        }
    }

    private func setAnnotationAndUpdateRegion(coordinate: CLLocationCoordinate2D, item: Item) {
        mapView.removeAnnotations(mapView.annotations)

        let annotation = ItemAnnotation()
        annotation.coordinate = coordinate
        annotation.item = item
        mapView.addAnnotation(annotation)

        let region = MKCoordinateRegion(center: adjustedCenterCoordinate(for: coordinate),
                                        latitudinalMeters: 2_000,
                                        longitudinalMeters: 2_000)

        mapView.setRegion(region, animated: false)
    }

    private func getAddress(latitude: Double, longitude: Double, completion: @escaping (String?) -> Void) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        geoCoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            // ignore delayed responses
            guard self?.currentCoordinate?.latitude != latitude,
                  self?.currentCoordinate?.longitude != longitude
            else {
                return
            }

            guard let postalAddress = placemarks?.first?.postalAddress else {
                completion(nil)
                return
            }

            let parts = [postalAddress.street, postalAddress.postalCode, postalAddress.city, postalAddress.state]
            let address = parts.filter { !$0.isEmpty }.joined(separator: ", ")
            completion(address)
        }
    }

    private func adjustedCenterCoordinate(for coordinate: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        // Adjust coordinate to show ItemAnnotationView centered
        return CLLocationCoordinate2D(latitude: coordinate.latitude + 0.003, longitude: coordinate.longitude)
    }
}
