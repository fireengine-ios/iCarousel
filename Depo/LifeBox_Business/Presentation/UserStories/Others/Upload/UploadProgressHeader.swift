//
//  UploadProgressHeader.swift
//  Depo
//
//  Created by Konstantin Studilin on 02.03.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit
protocol UploadProgressHeaderDelegate: class {
    func onActionButtonTap()
}


final class UploadProgressHeader: UIView, NibInit {
    
    @IBOutlet private var title: UILabel! {
        willSet {
            newValue.textColor = .white
            newValue.font = .GTAmericaStandardMediumFont(size: 12)
            newValue.text = TextConstants.uploadProgressHederTitle
        }
    }
    
    @IBOutlet private weak var actionButton: UIButton! {
        willSet {
            newValue.setTitle("", for: .normal)
            let image = UIImage(named: "arrowDown")?.withRenderingMode(.alwaysTemplate)
            newValue.setImage(image, for: .normal)
            newValue.tintColor = .white
        }
    }
    
    @IBOutlet weak var counter: UILabel! {
        willSet {
            newValue.text = ""
            newValue.font = .GTAmericaStandardMediumFont(size: 12)
            newValue.textColor = .white
            newValue.isHidden = true
        }
    }
    
    
    weak var delegate: UploadProgressHeaderDelegate?

    //MARK: - Override
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = ColorConstants.UploadProgress.headerBackground
    }
    
    //MARK: - Public
    
    func set(uploaded: Int, total: Int) {
        DispatchQueue.main.async {
            self.counter.isHidden = false
            self.counter.text = "\(uploaded)/\(total)"
        }
    }
    
    func clean() {
        DispatchQueue.main.async {
            self.counter.isHidden = true
            self.counter.text = ""
        }
    }
    
    //MARK: - Private
    
    @IBAction private func onActionButtonTap() {
        delegate?.onActionButtonTap()
    }
}
