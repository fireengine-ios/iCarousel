//
//  EditinglBar.swift
//  Depo
//
//  Created by Aleksandr on 8/2/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

enum ElementTypes {
    
    case share
    case info//one for alert one for tab
    case edit
    case delete
    case deleteFaceImage
    case deleteDeviceOriginal
    case move
    case sync
    case download
    case undetermend
    case rename
    case removeAlbum
    
    //used only in alert sheet:
    //photos:
    case createStory
    case createAlbum
    case copy
    case addToFavorites
    case removeFromFavorites
    case addToAlbum
    case backUp
    case addToCmeraRoll
    case removeFromAlbum
    case removeFromFaceImageAlbum
    case print
    case changeCoverPhoto
    //upload?
    case photos
    case iCloudDrive
    case lifeBox
    case more
    //all files/select
    case select
    case selectAll
    case deSelectAll
    //doc viewing
    case documentDetails
    //music
    case addToPlaylist
    case musicDetails
    case shareAlbum
    case makeAlbumCover
    case albumDetails
    case completelyDeleteAlbums
}


class EditinglBar: CustomTabBar {
    
    typealias Item = WrapData
    
    struct PreDetermendTypes { //use super setup method with these
        static let share = ("ShareButtonIcon", TextConstants.tabBarShareLabel)
        static let info = ("InfoButtonIcon", TextConstants.tabBarInfoLabel)
        static let edit = ("EditButtonIcon", TextConstants.tabBarEditeLabel)
        static let print = ("PrintButtonIcon", TextConstants.tabBarPrintLabel)
        static let delete = ("DeleteShareButton", TextConstants.tabBarDeleteLabel)
        static let deleteFaceImage = ("DeleteShareButton", TextConstants.tabBarDeleteLabel)
        static let removeAlbum = ("DeleteShareButton", TextConstants.tabBarRemoveAlbumLabel)
        static let move = ("MoveButtonIcon", TextConstants.tabBarMoveLabel)
        static let addToAlbum = ("MoveButtonIcon", TextConstants.tabBarAddToAlbumLabel)
        static let makeCover = ("MoveButtonIcon", TextConstants.tabAlbumCoverAlbumLabel)
        static let removeFromAlbum = ("DeleteShareButton", TextConstants.tabBarRemoveLabel)//from album
        static let removeFromFaceImageAlbum = ("DeleteShareButton", TextConstants.tabBarRemoveLabel)//from album
        static let sync = ("tabbarSync", TextConstants.tabBarSyncLabel)
        static let download = ("downloadTB", TextConstants.tabBarDownloadLabel)
    }
    
    private let tabBarHeight: CGFloat = 49
    
    private let originalY: CGFloat = -49
    private let originalX: CGFloat = 0
    

    //MARK: -
    
    class func getFromXib() -> EditinglBar? {
        guard let view = UINib(nibName: "EditinglBar", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? EditinglBar else {
            return nil
        }
        view.config()
        return view
    }
    
    private func config() {
        tintColor = ColorConstants.selectedBottomBarButtonColor
        isTranslucent = false
    }
    
    func show(animated: Bool = true, onView sourceView: UIView) {
        if superview != nil {
            return
        }
        sourceView.addSubview(self)
        sourceView.bringSubview(toFront: self)
        let sourceViewSize = sourceView.frame.size
        frame = CGRect(x: originalX, y: sourceViewSize.height - originalY, width: sourceViewSize.width, height: tabBarHeight)
        if animated {
            animateAppearance(with: sourceViewSize.height - tabBarHeight, completionBlock: nil)
        } else {
            frame.origin = CGPoint(x: 0, y:  sourceViewSize.height - tabBarHeight)
        }
        
    }
    
    func dismiss(animated: Bool = true) {
        if animated {
            animateAppearance(with: frame.origin.y - originalY , completionBlock: {
                self.removeFromSuperview()
            })
        } else {
            self.frame.origin = CGPoint(x: 0, y:  frame.origin.y - originalY)
            self.removeFromSuperview()
        }
        
    }
    
    private func animateAppearance(with newY: CGFloat, completionBlock: (()->Void)?) {
        UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
            self.frame.origin = CGPoint(x: 0, y: newY)
        }, completion: { _ in
            completionBlock?()
        })
    }
    
    override func setupItems(withImageToTitleNames names: [ImageNameToTitleTupple]) {
        let items = names.map{ CustomTabBarItem(title: $0.title,
                                                image: UIImage(named:$0.imageName),
                                                tag: 0)
        }
  
        setItems(items, animated: false)
    }
    
}
