//
//  ItemGroupAnnotationView.swift
//  Depo
//
//  Created by Hady on 2/19/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import UIKit
import MapKit

final class ItemGroupAnnotationView: ItemAnnotationView {
    private static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()

    private let badgeContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.backgroundColor = .lrTiffanyBlue
        return view
    }()

    private let countLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .TurkcellSaturaBolFont(size: 14)
        label.textColor = .white
        return label
    }()

    override func setupView() {
        super.setupView()

        badgeContainerView.addSubview(countLabel)
        NSLayoutConstraint.activate([
            countLabel.leadingAnchor.constraint(equalTo: badgeContainerView.leadingAnchor, constant: 8),
            countLabel.trailingAnchor.constraint(equalTo: badgeContainerView.trailingAnchor, constant: -8),
            countLabel.topAnchor.constraint(equalTo: badgeContainerView.topAnchor),
            countLabel.bottomAnchor.constraint(equalTo: badgeContainerView.bottomAnchor)
        ])

        addSubview(badgeContainerView)
        NSLayoutConstraint.activate([
            badgeContainerView.centerYAnchor.constraint(equalTo: imageView.topAnchor),
            badgeContainerView.centerXAnchor.constraint(equalTo: imageView.trailingAnchor)
        ])
    }

    override var annotation: MKAnnotation? {
        get { super.annotation }
        set {
            super.annotation = newValue
            populateCountLabel()
        }
    }

    private func populateCountLabel() {
        guard let annotation = self.annotation as? ItemGroupAnnotation else {
            badgeContainerView.isHidden = true
            return
        }

        let itemCount = annotation.itemCount
        countLabel.text = Self.numberFormatter.string(from: NSNumber(value: itemCount))
        badgeContainerView.isHidden = itemCount == 1
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        badgeContainerView.layer.cornerRadius = badgeContainerView.frame.height / 2
    }
}
