//
//  HomeViewTopView.swift
//  Depo
//
//  Created by Oleg on 22.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

protocol HomeViewTopViewActions: class {
    func allFilesButtonGotPressed()
    func createAStoryButtonGotPressed()
    func favoritesButtonGotPressed()
    func syncContactsButtonGotPressed()
}

class HomeViewTopView: UICollectionReusableView {

    @IBOutlet weak var allFilesButton: CircleButton!
    @IBOutlet weak var createAStoryButton: CircleButton!
    @IBOutlet weak var favoritesButton: CircleButton!
    @IBOutlet weak var syncContactsButton: CircleButton!
    

    weak var actionsDelegate: HomeViewTopViewActions?
    
    class func getHeight() -> CGFloat {
        if (Device.isIpad) {
            return 173.0
        }
        return 136.0
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configurateView()
    }
    
    private func configurateView() {
        allFilesButton.setImage(UIImage(named: "homeAllFiles"), for: .normal)
        allFilesButton.setBottomTitleText(titleText: TextConstants.homeButtonAllFiles)
        allFilesButton.accessibilityLabel = TextConstants.homeButtonAllFiles
        
        createAStoryButton.setImage(UIImage(named: "homeCreateStory"), for: .normal)
        createAStoryButton.setBottomTitleText(titleText: TextConstants.homeButtonCreateStory)
        createAStoryButton.accessibilityLabel = TextConstants.homeButtonCreateStory
        
        favoritesButton.setImage(UIImage(named: "homeFavorites"), for: .normal)
        favoritesButton.setBottomTitleText(titleText: TextConstants.homeButtonFavorites)
        favoritesButton.accessibilityLabel = TextConstants.homeButtonFavorites
        
        syncContactsButton.setImage(UIImage(named: "homeSyncContacts"), for: .normal)
        syncContactsButton.setBottomTitleText(titleText: TextConstants.homeButtonSyncContacts)
        syncContactsButton.accessibilityLabel = TextConstants.homeButtonSyncContacts
    }
    
    // MARK: Buttons action
    
    @IBAction func onAllFilesButton() {
        actionsDelegate?.allFilesButtonGotPressed()
    }
    
    @IBAction func onCreateAStoryButton() {
        actionsDelegate?.createAStoryButtonGotPressed()
    }
    
    @IBAction func onFavoritesButton() {
        actionsDelegate?.favoritesButtonGotPressed()
    }
    
    @IBAction func onSyncContactsButton() {
        actionsDelegate?.syncContactsButtonGotPressed()
    }

}
