//
//  UploadProgressCell.swift
//  Depo
//
//  Created by Konstantin Studilin on 26.02.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

final class UploadProgressCell: UICollectionViewCell {
    static let height: CGFloat = 48.0
    

    @IBOutlet private weak var progressStatusView: UIView! {
        willSet {
            newValue.backgroundColor = .clear
        }
    }
    
    @IBOutlet private weak var thumbnail: UIImageView! {
        willSet {
            newValue.contentMode = .scaleAspectFit
        }
    }
    
    @IBOutlet private weak var fileName: UILabel! {
        willSet {
            newValue.text = ""
            newValue.font = .GTAmericaStandardRegularFont(size: 12)
            newValue.textColor = ColorConstants.Text.labelTitle
        }
    }
    
    @IBOutlet private weak var fileSize: UILabel! {
        willSet {
            newValue.text = ""
            newValue.font = .GTAmericaStandardRegularFont(size: 11)
            newValue.textColor = ColorConstants.Text.textFieldText
        }
    }
    
    @IBOutlet private weak var removeButton: UIButton! {
        willSet {
            newValue.contentMode = .scaleAspectFit
            newValue.setTitle("", for: .normal)
            newValue.setImage(UIImage(named: "cancelButton"), for: .normal)
        }
    }
    
    @IBOutlet private weak var separator: UIView! {
        willSet {
            newValue.backgroundColor = ColorConstants.separator
        }
    }
    
    //MARK: - Override
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = ColorConstants.UploadProgress.cellBackground
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        fileName.text = ""
        fileSize.text = ""
        thumbnail.image = nil
        removeButton.isHidden = false
        progressStatusView.subviews.forEach { $0.removeFromSuperview() }
    }
    
    //MARK: - Public
    
    func setup(with item: UploadProgressItem) {
        guard let uploadingItem = item.item else {
            return
        }
        
        DispatchQueue.main.async {
            let byteFormatter = ByteCountFormatter()
            self.fileName.text = uploadingItem.name
            self.fileSize.text = byteFormatter.string(fromByteCount: uploadingItem.fileSize)
            self.thumbnail.image = WrapperedItemUtil.getSmallPreviewImageForWrapperedObject(fileType: uploadingItem.fileType)
            
            self.removeButton.isHidden = item.status.isContained(in: [.completed, .failed])
            
            self.progressStatusView.subviews.forEach { $0.removeFromSuperview() }
            if let statusView = self.createView(for: item.status) {
                self.progressStatusView.addSubview(statusView)
                statusView.translatesAutoresizingMaskIntoConstraints = false
                statusView.pinToSuperviewEdges()
                self.layoutIfNeeded()
            }
        }
    }
    
    //MARK: - Private
    
    private func createView(for status: UploadProgressStatus) -> UIView? {
        switch status {
            case .completed:
                let image = UIImage(named: "completed")
                let imageView = UIImageView(image: image)
                imageView.contentMode = .center
                return imageView
                
            case .failed:
                let image = UIImage(named: "failed")
                let imageView = UIImageView(image: image)
                imageView.contentMode = .center
                return imageView
                
            case .inProgress:
                return nil
                
            case .ready:
                return nil
        }
    }
    
    @IBAction private func onRemoveTapped(_ sender: Any) {
        //TODO:
    }
    
}
