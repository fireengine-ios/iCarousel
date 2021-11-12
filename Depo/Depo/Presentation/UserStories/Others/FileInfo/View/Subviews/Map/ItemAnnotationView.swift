//
//  ItemAnnotationView.swift
//  Depo
//
//  Created by Hady on 11/11/21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import MapKit

final class ItemAnnotationView: MKAnnotationView {
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 4
        return view
    }()

    private let imageView: LoadingImageView = {
        let imageView = LoadingImageView()
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


    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setImage()
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setImage()
        setupView()
    }

    override var annotation: MKAnnotation? {
        get { super.annotation }
        set {
            super.annotation = newValue
            setImage()
        }
    }

    private func setImage() {
        guard let annotation = self.annotation as? ItemAnnotation else {
            imageView.image = nil
            return
        }

        // TODO: update to display thumbnail like in PhotoVideoCell.swift
        imageView.cancelLoadRequest()
        imageView.loadImage(with: annotation.item)
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
