//
//  EditinglBar.swift
//  Depo
//
//  Created by Aleksandr on 8/2/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

typealias AnimationBlock = () -> Void
typealias PreDetermendType = (String, String, String)

class EditinglBar: CustomTabBar {
    
    struct PreDetermendTypes { //use super setup method with these
        static let share = ("ShareButtonIcon", TextConstants.tabBarShareLabel, "")
        static let info = ("InfoButtonIcon", TextConstants.tabBarInfoLabel, "")
        static let edit = ("EditButtonIcon", TextConstants.tabBarEditeLabel, "")
        static let print = ("PrintButtonIcon", TextConstants.tabBarPrintLabel, "")
        static let delete = ("DeleteShareButton", TextConstants.tabBarDeleteLabel, "")
        static let removeAlbum = ("DeleteShareButton", TextConstants.tabBarRemoveAlbumLabel, "")
        static let move = ("MoveButtonIcon", TextConstants.tabBarMoveLabel, "")
        static let addToAlbum = ("MoveButtonIcon", TextConstants.tabBarAddToAlbumLabel, "")
        static let makeCover = ("MoveButtonIcon", TextConstants.tabAlbumCoverAlbumLabel, "")
        static let removeFromAlbum = ("DeleteShareButton", TextConstants.tabBarRemoveLabel, "")//from album
        static let removeFromFaceImageAlbum = ("DeleteShareButton", TextConstants.tabBarRemoveLabel, "")//from album
        static let sync = ("tabbarSync", TextConstants.tabBarSyncLabel, "")
        static let syncInProgress = ("", TextConstants.tabBarSyncLabel, "")
        static let download = ("downloadTB", TextConstants.tabBarDownloadLabel, "")
        static let hide = ("HideButtonIcon", TextConstants.tabBarHideLabel, "")
        static let unhide = ("UnhideButtonIcon", TextConstants.tabBarUnhideLabel, "")
        static let smash = ("SmashButtonIcon", TextConstants.tabBarSmashLabel, "")
        static let restore = ("RestoreButtonIcon", TextConstants.actionSheetRestore, "")
    }
    
    private let tabBarHeight: CGFloat = 49
    
    private let originalY: CGFloat = -49
    private let originalX: CGFloat = 0
    
    private var animationsArray = [AnimationBlock]()
    
    private lazy var syncProgressAnimation: AnimatedCircularLoader = {
        let side = bounds.height / 2
        let frame = CGRect(x: bounds.width / 2 - side / 2,
                           y: 8,
                           width: side, height: side)
        let loader = AnimatedCircularLoader(frame: frame)
        
        loader.set(lineBackgroundColor: .clear)
        loader.set(lineColor: .white)
        loader.set(duration: 1.0)
        
        loader.translatesAutoresizingMaskIntoConstraints = true
        loader.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        loader.isHidden = true
        
        return loader
    }()

    // MARK: - Override
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupAnimation()
    }
    
    deinit {
        animationsArray.removeAll()
    }
    
    // MARK: - Public
    
    func show(animated: Bool = true, onView sourceView: UIView) {
        animationWithBlock(needShow: true, withAnimation: animated, onView: sourceView)
    }
    
    func dismiss(animated: Bool = true) {
        animationWithBlock(needShow: false, withAnimation: animated)
    }
    
    func setupItems(withImageToTitleNames names: [ImageNameToTitleTupple]) {
          var syncInProgress = false
          
          let items = names.map { item -> CustomTabBarItem in
              var image = UIImage(named: item.imageName)
              
              ///red 'delete', 'hide', 'unhide', 'restore' icons
              switch item.imageName {
                  case PreDetermendTypes.delete.0,
                       PreDetermendTypes.hide.0,
                       PreDetermendTypes.unhide.0,
                       PreDetermendTypes.restore.0:
                      image = image?.withRenderingMode(.alwaysOriginal)
                  case PreDetermendTypes.syncInProgress.0:
                      image = nil
                      syncInProgress = true
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
          
          syncInProgress ? showAnimation() : hideAnimation()
    
          setItems(items, animated: false)
      }
    
    // MARK: - Private
    
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
                    let animationFrame = self.frame.origin.y - self.originalY + (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0)
                    
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
        } else {
            animationsArray.removeAll()
        }
    }
}


// MARK: - Sync in progress animation

extension EditinglBar {
    private func setupAnimation() {
        syncProgressAnimation.removeFromSuperview()
        addSubview(syncProgressAnimation)
    }
    
    private func showAnimation() {
        syncProgressAnimation.isHidden = false
        syncProgressAnimation.startAnimation()
    }
    
    private func hideAnimation() {
        syncProgressAnimation.stopAnimation()
        syncProgressAnimation.isHidden = true
    }
}
