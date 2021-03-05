//
//  UploadSelectionCell.swift
//  Depo
//
//  Created by Konstantin Studilin on 04.03.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

protocol UploadSelectionCellDelegate: class {
    func onRemoveTapped(cell: UploadSelectionCell)
}

final class UploadSelectionCell: UICollectionViewCell {
    
    static let height: CGFloat = 44
    

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
    
    @IBOutlet weak var removeButton: UIButton! {
        willSet {
            newValue.contentMode = .scaleAspectFit
            newValue.setTitle("", for: .normal)
            newValue.setImage(UIImage(named: "cancelButton"), for: .normal)
        }
    }
    
    weak var delegate: UploadSelectionCellDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 4
        layer.borderWidth = 1
        layer.borderColor = ColorConstants.separator.cgColor
    }
   
    override func prepareForReuse() {
        super.prepareForReuse()
        
        fileName.text = ""
        fileSize.text = ""
        thumbnail.image = nil
        removeButton.isHidden = false
        delegate = nil
    }

    
    //MARK: - Public
    
    func setup(with item: WrapData) {
        DispatchQueue.main.async {
            let byteFormatter = ByteCountFormatter()
            self.fileName.text = item.name
            self.fileSize.text = byteFormatter.string(fromByteCount: item.fileSize)
            self.thumbnail.image = WrapperedItemUtil.getSmallPreviewImageForWrapperedObject(fileType: item.fileType)
        }
    }
    
    //MARK: - Private
    
    @IBAction private func onRemoveButtonTap(_ sender: Any) {
        delegate?.onRemoveTapped(cell: self)
    }
    

}
