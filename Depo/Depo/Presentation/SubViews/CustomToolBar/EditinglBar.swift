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
    case moveToTrash
    
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
    case hide
    case hideAlbums
    case unhide
    case unhideAlbumItems
    case smash
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
    case completelyMoveToTrash
    //instaPick
    case instaPick
}

typealias AnimationBlock = () -> Void

class EditinglBar: CustomTabBar {
    
    struct PreDetermendTypes { //use super setup method with these
        static let share = ("ShareButtonIcon", TextConstants.tabBarShareLabel, "")
        static let info = ("InfoButtonIcon", TextConstants.tabBarInfoLabel, "")
        static let edit = ("EditButtonIcon", TextConstants.tabBarEditeLabel, "")
        static let print = ("PrintButtonIcon", TextConstants.tabBarPrintLabel, "")
        static let delete = ("DeleteShareButton", TextConstants.tabBarDeleteLabel, "")
        static let deleteFaceImage = ("DeleteShareButton", TextConstants.tabBarDeleteLabel, "")
        static let removeAlbum = ("DeleteShareButton", TextConstants.tabBarRemoveAlbumLabel, "")
        static let move = ("MoveButtonIcon", TextConstants.tabBarMoveLabel, "")
        static let addToAlbum = ("MoveButtonIcon", TextConstants.tabBarAddToAlbumLabel, "")
        static let makeCover = ("MoveButtonIcon", TextConstants.tabAlbumCoverAlbumLabel, "")
        static let removeFromAlbum = ("DeleteShareButton", TextConstants.tabBarRemoveLabel, "")//from album
        static let removeFromFaceImageAlbum = ("DeleteShareButton", TextConstants.tabBarRemoveLabel, "")//from album
        static let sync = ("tabbarSync", TextConstants.tabBarSyncLabel, "")
        static let download = ("downloadTB", TextConstants.tabBarDownloadLabel, "")
        static let hide = ("HideButtonIcon", TextConstants.tabBarHideLabel, "")
        static let hideAlbums = ("HideButtonIcon", TextConstants.tabBarHideLabel, "")
        static let unhide = ("UnhideButtonIcon", TextConstants.tabBarUnhideLabel, "")
        static let unhideAlbumItems = ("UnhideButtonIcon", TextConstants.tabBarUnhideLabel, "")
        static let smash = ("SmashButtonIcon", TextConstants.tabBarSmashLabel, "")
        static let completelyMoveToTrash = ("DeleteShareButton", TextConstants.tabBarDeleteLabel, "")
    }
    
    private let tabBarHeight: CGFloat = 49
    
    private let originalY: CGFloat = -49
    private let originalX: CGFloat = 0
    
    private var animationsArray = [AnimationBlock]()

    // MARK: -
    
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
    
    deinit{
        animationsArray.removeAll()
    }
    
    func show(animated: Bool = true, onView sourceView: UIView) {
        animationWithBlock(needShow: true, withAnimation: animated, onView: sourceView)
    }
    
    func dismiss(animated: Bool = true) {
        animationWithBlock(needShow: false, withAnimation: animated)
    }
    
    private func animateAppearance(with newY: CGFloat, completionBlock: (() -> Void)?) {
        UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
            self.frame.origin = CGPoint(x: 0, y: newY)
        }, completion: { _ in
            completionBlock?()
        })
    }
    
    private func animationWithBlock(needShow: Bool, withAnimation: Bool, onView: UIView? = nil) {
        let animationBlock : AnimationBlock = ({ [weak self, weak onView] in
            guard let `self` = self else {
                return
            }
            
            if needShow {
                guard let sourceView = onView else{
                    self.nextAnimation()
                    return
                }
                
                if self.superview != nil {
                    self.nextAnimation()
                    return
                }
                
                sourceView.addSubview(self)
                sourceView.bringSubview(toFront: self)
                let sourceViewSize = sourceView.frame.size
                self.frame = CGRect(x: self.originalX, y: sourceViewSize.height - self.originalY, width: sourceViewSize.width, height: self.tabBarHeight)
                if withAnimation {
                    self.animateAppearance(with: sourceViewSize.height - self.tabBarHeight, completionBlock: { [weak self] in
                        guard let `self` = self else {
                            return
                        }
                        
                        self.nextAnimation()
                    })
                } else {
                    self.frame.origin = CGPoint(x: 0, y: sourceViewSize.height - self.tabBarHeight)
                    self.nextAnimation()
                }
            } else {
                if withAnimation {
                    var animationFrame = self.frame.origin.y - self.originalY
                    
                    if #available(iOS 11.0, *) {
                        animationFrame += UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
                    }
                    
                    self.animateAppearance(with: animationFrame) { [weak self] in
                        guard let `self` = self else {
                            return
                        }
                        
                        self.removeFromSuperview()
                        self.nextAnimation()
                    }
                } else {
                    self.frame.origin = CGPoint(x: 0, y: self.frame.origin.y - self.originalY)
                    self.removeFromSuperview()
                    self.nextAnimation()
                }
            }
        })
        
        animationsArray.append(animationBlock)
        if animationsArray.count == 1{
            animationBlock()
        }
    }
    
    private func nextAnimation() {
        if animationsArray.count > 1 {
            if let lastBlock = animationsArray.last{
                animationsArray = [lastBlock]
                lastBlock()
            }
        }else{
            animationsArray.removeAll()
        }
    }
    
    override func setupItems(withImageToTitleNames names: [ImageNameToTitleTupple]) {
        let items = names.map { item -> CustomTabBarItem in
            var image = UIImage(named: item.imageName)
            
            ///red 'delete' and 'hide' icon
            switch item.imageName {
            case PreDetermendTypes.delete.0,
                 PreDetermendTypes.hideAlbums.0,
                 PreDetermendTypes.hide.0,
                 PreDetermendTypes.completelyMoveToTrash.0,
                 PreDetermendTypes.unhide.0:
                image = image?.withRenderingMode(.alwaysOriginal)
            default: break
            }
            
            return CustomTabBarItem(title: item.title,
                             image: image,
                             tag: 0)
        }
        
        items.forEach { item in
            item.isAccessibilityElement = true
            item.accessibilityLabel = item.title
        }
  
        setItems(items, animated: false)
    }
    
}
