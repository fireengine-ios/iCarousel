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
    
    @IBOutlet private weak var progress: UIProgressView! {
        willSet {
            newValue.progressTintColor = .white
            newValue.backgroundColor = ColorConstants.UploadProgress.progressBackground
            newValue.progress = 0
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
    
    private var uploadedBytesStable: Int = 0
    
    private var uploadedBytesProgress: Int = 0 {
        didSet {
           updateTotalProgress()
        }
    }
    
    private var totalBytes: Int = 0 {
        didSet {
            updateTotalProgress()
        }
    }
    

    //MARK: - Override
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = ColorConstants.Text.labelTitle
    }
    
    //MARK: - Public
    
    func set(uploaded: Int, total: Int) {
        DispatchQueue.main.async {
            self.counter.isHidden = false
            self.counter.text = "\(uploaded)/\(total)"
        }
    }
    
    func addTo(uploadedBytesProgress: Int) {
        self.uploadedBytesProgress = uploadedBytesStable + uploadedBytesProgress
    }
    
    func addTo(uploadedBytesStable: Int) {
        self.uploadedBytesStable += uploadedBytesStable
        uploadedBytesProgress = self.uploadedBytesStable
    }
    
    func addTo(totalBytes: Int) {
        self.totalBytes += totalBytes
    }
    
    func clean() {
        DispatchQueue.main.async {
            self.counter.isHidden = true
            self.counter.text = ""
            self.totalBytes = 0
            self.uploadedBytesProgress = 0
            self.uploadedBytesStable = 0
        }
    }
    
    //MARK: - Private
    
    @IBAction private func onActionButtonTap() {
        delegate?.onActionButtonTap()
    }
    
    private func updateTotalProgress() {
        DispatchQueue.main.async {
            guard self.totalBytes != 0 else {
                self.progress.setProgress(0, animated: false)
                return
            }
            
            let ratio = Float(self.uploadedBytesProgress) / Float(self.totalBytes)
            print("Total Ratio: \(ratio)")
            self.progress.setProgress(ratio, animated: true)
        }
    }
}
