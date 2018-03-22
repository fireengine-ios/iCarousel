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

typealias AnimationBlock = () -> Void

class EditinglBar: CustomTabBar {
    
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
            }else {
                if withAnimation {
                    self.animateAppearance(with: self.frame.origin.y - self.originalY, completionBlock: { [weak self] in
                        guard let `self` = self else {
                            return
                        }
                        
                        self.removeFromSuperview()
                        self.nextAnimation()
                    })
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
        let items = names.map { CustomTabBarItem(title: $0.title,
                                                image: UIImage(named: $0.imageName),
                                                tag: 0)
        }
  
        setItems(items, animated: false)
    }
    
}
