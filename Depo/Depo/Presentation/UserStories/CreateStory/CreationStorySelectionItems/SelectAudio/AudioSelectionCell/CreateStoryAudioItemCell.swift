//
//  CreateStoryAudioItemCell.swift
//  Depo
//
//  Created by Maxim Soldatov on 7/4/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

protocol CreateStoryAudioItemCellDelegate {
    func playButtonPressed(cell index: Int)
    func selectButtonPressed(cell index: Int)
}

final class CreateStoryAudioItemCell: UITableViewCell {

    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.textGrayColor
            newValue.font = .appFont(.medium, size: 14)
        }
    }
    
    @IBOutlet private weak var playButton: UIButton! {
        willSet {
            newValue.accessibilityLabel = TextConstants.accessibilityPlus
        }
    }

    @IBOutlet private weak var selectButton: UIButton! {
        willSet {
            newValue.titleLabel?.adjustsFontSizeToFitWidth()
        }
    }
    
    private var cellIndexPathRow: Int?
    
    var createStoryAudioItemCellDelegate: CreateStoryAudioItemCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        setPlaying(playing: false)
    }
    
    func setTextForLabel(titleText: String) {
        titleLabel.text = titleText
    }

    func setCellIndexPath(index: Int) {
        self.cellIndexPathRow = index
    }
    
    @IBAction private func playButtonTapped(_ sender: UIButton) {
        guard let index = cellIndexPathRow else {
            assertionFailure()
            return
        }
        createStoryAudioItemCellDelegate?.playButtonPressed(cell: index)
    }
    
    @IBAction private func selectButtonPressed(_ sender: UIButton) {
        guard let index = cellIndexPathRow else {
            assertionFailure()
            return
        }
        createStoryAudioItemCellDelegate?.selectButtonPressed(cell: index)
    }
    
    func setSelected(selected: Bool) {
        if selected {
            selectButton.setImage(Image.iconRadioButtonSelectBlue.image, for: .normal)
        } else {
            selectButton.setImage(Image.iconAddSelect.image, for: .normal)
        }
    }
    
    func setPlaying(playing: Bool) {
        if playing {
            let image = Image.iconPauseRed.image
            playButton.setImage(image, for: .normal)
            playButton.accessibilityLabel = TextConstants.accessibilityPause
            titleLabel.font = .appFont(.medium, size: 14)
        } else {
            let image = Image.iconPlayRed.image
            playButton.setImage(image, for: .normal)
            playButton.accessibilityLabel = TextConstants.accessibilityPlay
            titleLabel.font = .appFont(.medium, size: 14)
        }
    }
    
}
