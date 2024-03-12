//
//  GarentaViewController.swift
//  Depo
//
//  Created by Ozan Salman on 29.02.2024.
//  Copyright © 2024 LifeTech. All rights reserved.
//

import UIKit
import AVFoundation

final class GarentaViewController: BaseViewController {
    
    private lazy var descriptionTextView: UITextView = {
        let view = UITextView()
        view.textColor = AppColor.textButton.color
        view.font = .appFont(.regular, size: 12)
        view.textAlignment = .left
        view.textContainer.lineBreakMode = .byWordWrapping
        view.isSelectable = true
        view.dataDetectorTypes = .link
        view.isEditable = false
        view.sizeToFit()
        view.isScrollEnabled = false
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private var details: String = ""
    private var pageTitle: String = ""
    
    init(details: String, pageTitle: String) {
        self.details = details
        self.pageTitle = pageTitle
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPage()
        setTitle(withString: pageTitle)
        view.backgroundColor = AppColor.background.color
        setLabel(details: details)
    }
}

extension GarentaViewController {
    private func setupPage() {
        view.addSubview(descriptionTextView)
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        descriptionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        descriptionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        descriptionTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
    }
    
    private func setLabel(details: String) {
        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle == .light {
                descriptionTextView.attributedText = details.getAsHtml
            } else {
                descriptionTextView.attributedText = details.getAsHtmldarkMode
            }
        } else {
            descriptionTextView.attributedText = details.getAsHtml
        }
    }
}
