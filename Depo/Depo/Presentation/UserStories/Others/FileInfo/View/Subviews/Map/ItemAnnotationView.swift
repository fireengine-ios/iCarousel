//
//  ItemAnnotationView.swift
//  Depo
//
//  Created by Hady on 11/11/21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import MapKit
import Photos

final class ItemAnnotationView: MKAnnotationView {
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 4
        return view
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 2
        return imageView
    }()

    private let bottomArrow: ArrowShapeView = {
        let view = ArrowShapeView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // for PHAsset loading
    private lazy var filesDataSource = FilesDataSource()
    private var currentAsset: PHAsset?
    private var imageRequestId: PHImageRequestID?

    // for mediumURL loading
    private var cellImageManager: CellImageManager?

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        populateImage()
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        populateImage()
        setupView()
    }

    override var annotation: MKAnnotation? {
        get { super.annotation }
        set {
            super.annotation = newValue
            populateImage()
        }
    }

    private func populateImage() {
        guard let annotation = self.annotation as? ItemAnnotation else {
            imageView.image = nil
            return
        }

        cancelCurrentImageLoad()
        imageView.image = nil

        if let asset = annotation.item?.asset {
            setImage(asset: asset)
        } else if let item = annotation.item, let mediumURL = item.metaData?.mediumUrl {
            setImage(thumbnailURL: mediumURL, isOwner: item.isOwner, isPublicSharedItem: item.isPublicSharedItem)
        }
    }

    private func setImage(asset: PHAsset) {
        currentAsset = asset
        FilesDataSource.cacheQueue.async { [weak self] in
            guard self?.currentAsset?.localIdentifier == asset.localIdentifier else {
                return
            }

            self?.filesDataSource.getAssetThumbnail(asset: asset, requestID: { [weak self] requestId in
                DispatchQueue.main.async {
                    self?.imageRequestId = requestId
                }
            }, completion: { [weak self] image in
                DispatchQueue.main.async {
                    if self?.currentAsset?.localIdentifier == asset.localIdentifier {
                        self?.imageView.image = image
                    }
                }
            })
        }
    }

    private func setImage(thumbnailURL: URL, isOwner: Bool, isPublicSharedItem: Bool? = false) {
        cellImageManager?.cancelImageLoading()

        let cacheKey = thumbnailURL.byTrimmingQuery
        cellImageManager = CellImageManager.instance(by: cacheKey)

        let imageSetBlock: CellImageManagerOperationsFinished = { [weak self] image, _, _, uniqueId in
            DispatchQueue.main.async {
                guard self?.cellImageManager?.uniqueId == uniqueId, let image = image else {
                    return
                }

                self?.imageView.image = image
            }
        }

        cellImageManager?.loadImage(thumbnailUrl: thumbnailURL, url: nil,
                                    isOwner: isOwner && isPublicSharedItem != true,
                                    completionBlock: imageSetBlock)
    }

    private func cancelCurrentImageLoad() {
        imageView.sd_cancelCurrentImageLoad()
        cellImageManager?.cancelImageLoading()
        if let requestId = imageRequestId {
            filesDataSource.cancelImageRequest(requestImageID: requestId)
            imageRequestId = nil
        }
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        layer.shadowColor = UIColor.black.withAlphaComponent(0.5).cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = .zero
        clipsToBounds = false

        addSubview(bottomArrow)
        NSLayoutConstraint.activate([
            bottomArrow.centerXAnchor.constraint(equalTo: centerXAnchor),
            bottomArrow.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomArrow.widthAnchor.constraint(equalToConstant: 16),
            bottomArrow.heightAnchor.constraint(equalToConstant: 8),
        ])

        addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomArrow.topAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 50),
            containerView.heightAnchor.constraint(equalToConstant: 50),
        ])

        containerView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 2),
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 2),
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -2),
            imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -2),
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        centerOffset.y = -frame.height / 2
    }
}

private extension ItemAnnotationView {
    class ArrowShapeView: UIView {
        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = .clear
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            backgroundColor = .clear
        }

        override func draw(_ rect: CGRect) {
            guard let context = UIGraphicsGetCurrentContext() else { return }

            context.move(to: rect.origin)
            context.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            context.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            context.closePath()

            context.setFillColor(UIColor.white.cgColor)
            context.fillPath()
        }
    }
}
