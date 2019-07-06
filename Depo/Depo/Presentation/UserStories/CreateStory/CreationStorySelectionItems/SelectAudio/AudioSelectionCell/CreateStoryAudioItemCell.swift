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

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var playButton: UIButton!
    @IBOutlet private weak var selectButton: UIButton!
    @IBOutlet private weak var separateLine: UIView!
    
    var cellIndexPath: Int?
    var isPlaying = false
    
    var createStoryAudioItemCellDelegate: CreateStoryAudioItemCellDelegate?
    
    private let choosenSelectedButtonColor = UIColor(red: 250/255, green: 155/255, blue: 77/255, alpha: 1)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = ColorConstants.textGrayColor
        titleLabel.font = UIFont.TurkcellSaturaRegFont(size: 18)
    }
    
    func setTextForLabel(titleText: String, needShowSeparator: Bool) {
        titleLabel.text = titleText
        separateLine.isHidden = !needShowSeparator
    }

    func setCellIndexPath(index: Int) {
        self.cellIndexPath = index
    }
    
    @IBAction private func playButtonTapped(_ sender: UIButton) {
        guard let index = cellIndexPath else {
            return
        }
        createStoryAudioItemCellDelegate?.playButtonPressed(cell: index)
    }
    
    @IBAction private func selectButtonPressed(_ sender: UIButton) {
        guard let index = cellIndexPath else {
            return
        }
        createStoryAudioItemCellDelegate?.selectButtonPressed(cell: index)
    }
    
    
    func isSelectedItem(selected: Bool) {
        if selected {
            selectButton.setTitleColor(self.choosenSelectedButtonColor, for: .normal)
            selectButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 21)
            selectButton.setTitle(TextConstants.createStoryAudioSelectedItem, for: .normal)
        } else {
            selectButton.setTitleColor(ColorConstants.blueColor, for: .normal)
            selectButton.titleLabel?.font = UIFont.TurkcellSaturaMedFont(size: 18)
            selectButton.setTitle(TextConstants.createStoryAudioSelectItem, for: .normal)

        }
    }
    
    func selectItem() {
            selectButton.setTitleColor(self.choosenSelectedButtonColor, for: .normal)
            selectButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 21)
            selectButton.titleLabel?.text = TextConstants.createStoryAudioSelectedItem
    }
    
    func deselectItem() {
            selectButton.setTitleColor(ColorConstants.blueColor, for: .normal)
            selectButton.titleLabel?.font = UIFont.TurkcellSaturaMedFont(size: 18)
            selectButton.titleLabel?.text = TextConstants.createStoryAudioSelectItem
    }
    
    func onPlay() {
            playButton.setImage(UIImage(named: "creationStoryItemPause"), for: .normal)
            titleLabel.font = UIFont.TurkcellSaturaBolFont(size: 18)
    }
    
    func isStopped() {
        playButton.setImage(UIImage(named: "creationStroryItemPlay"), for: .normal)
        titleLabel.font = UIFont.TurkcellSaturaRegFont(size: 18)
    }
}
