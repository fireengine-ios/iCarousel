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
        static let share = ("moveBottom", TextConstants.tabBarShareLabel, "")
        static let privateShare = ("shareBottom", TextConstants.tabBarSharePrivatelyLabel, "")
        static let info = ("infoBottom", TextConstants.tabBarInfoLabel, "")
        static let delete = ("trashBottom", TextConstants.tabBarDeleteLabel, "")
        static let move = ("moveBottom", TextConstants.tabBarMoveLabel, "")
        static let download = ("downloadBottom", TextConstants.tabBarDownloadLabel, "")
        static let downloadDocument = ("downloadBottom", TextConstants.tabBarDownloadLabel, "")
        static let restore = ("RestoreButtonIcon", TextConstants.actionSheetRestore, "")
    }
    
    private let tabBarHeight: CGFloat = 49
    
    private let originalY: CGFloat = -49
    private let originalX: CGFloat = 0
    
    private var animationsArray = [AnimationBlock]()
    
    // MARK: - Override
    
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
    
    func setupItems(withImageToTitleNames names: [ImageNameToTitleTupple], style: UIBarStyle?) {
        let items = names.map { item -> CustomTabBarItem in
            let image = UIImage(named: item.imageName)?.withRenderingMode(.alwaysOriginal)
            
            let tabBarItem = CustomTabBarItem(title: item.title, image: image, tag: 0)
            let color: UIColor = (style == .default) ? .white : ColorConstants.bottomBarTint
            tabBarItem.set(textColor: color)
            return tabBarItem
        }
          
          items.forEach { item in
              item.isAccessibilityElement = true
              item.accessibilityLabel = item.title
          }
    
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
        let animationBlock : AnimationBlock = { [weak self, weak onView] in
            guard let self = self else {
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
                let newY = sourceViewSize.height - self.tabBarHeight - (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0)
                if withAnimation {
                    self.animateAppearance(with: newY, completionBlock: { [weak self] in
                        guard let self = self else {
                            return
                        }
                        
                        self.nextAnimation()
                    })
                } else {
                    self.frame.origin = CGPoint(x: 0, y: newY)
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
        }
        
        animationsArray.append(animationBlock)
        if animationsArray.count == 1 {
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
