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
            newValue.font = UIFont.TurkcellSaturaRegFont(size: 18)
        }
    }
    @IBOutlet private weak var playButton: UIButton!
    @IBOutlet private weak var selectButton: UIButton!
    @IBOutlet private weak var separateLine: UIView!
    
    private var cellIndexPathRow: Int?
    
    var createStoryAudioItemCellDelegate: CreateStoryAudioItemCellDelegate?
    
    func setTextForLabel(titleText: String, needShowSeparator: Bool) {
        titleLabel.text = titleText
        separateLine.isHidden = !needShowSeparator
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
            selectButton.setTitleColor(ColorConstants.choosenSelectedButtonColor, for: .normal)
            selectButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 21)
            selectButton.setTitle(TextConstants.createStoryAudioSelectedItem, for: .normal)
        } else {
            selectButton.setTitleColor(ColorConstants.blueColor, for: .normal)
            selectButton.titleLabel?.font = UIFont.TurkcellSaturaMedFont(size: 18)
            selectButton.setTitle(TextConstants.createStoryAudioSelectItem, for: .normal)
        }
    }
    
    func setPlaying(playing: Bool) {
        if playing {
            playButton.setImage(UIImage(named: "creationStoryItemPause"), for: .normal)
            titleLabel.font = UIFont.TurkcellSaturaBolFont(size: 18)
        } else {
            playButton.setImage(UIImage(named: "creationStroryItemPlay"), for: .normal)
            titleLabel.font = UIFont.TurkcellSaturaRegFont(size: 18)
        }
    }
    
}
