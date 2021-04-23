//
//  AudioSelectionCollectionViewCell.swift
//  Depo
//
//  Created by Oleg on 03.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

protocol AudioSelectionCollectionViewCellDelegate {
    func onPlayButton(inCell: AudioSelectionCollectionViewCell)
}

class AudioSelectionCollectionViewCell: BaseCollectionViewCell {
    
    @IBOutlet weak var selectionImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var playingButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        nameLabel.textColor = ColorConstants.textGrayColor.color
        nameLabel.font = UIFont.GTAmericaStandardRegularFont(size: 18)
        
        contentView.backgroundColor = ColorConstants.whiteColor.color
    }
    
    override func configureWithWrapper(wrappedObj: BaseDataSourceItem) {
        nameLabel.text = wrappedObj.name
    }
    
    override func setSelection(isSelectionActive: Bool, isSelected: Bool) {
        let image = UIImage(named: isSelected ? "selectedList": "pselected")
        self.selectionImage.image = image
    }
    
    override func setSelectionWithAnimation(isSelectionActive: Bool, isSelected: Bool) {
        UIView.transition(with: selectionImage,
                          duration: NumericConstants.animationDuration,
                          options: .transitionCrossDissolve,
                          animations: {
                            let image = UIImage(named: isSelected ? "selectedList": "pselected")
                            self.selectionImage.image = image
        }, completion: nil)
    }
    
    func changeButtonState(playing: Bool) {
        playing ? (self.playingButton.isSelected = true) : (self.playingButton.isSelected = false)
    }
    
    @IBAction func onPlayButton() {
        if let d = delegate as? AudioSelectionCollectionViewCellDelegate {
            d.onPlayButton(inCell: self)
        }
    }

}
