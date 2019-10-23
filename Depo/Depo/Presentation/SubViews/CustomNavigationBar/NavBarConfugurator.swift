//
//  NavBarConfugurator.swift
//  Depo
//
//  Created by Alexander Gurin on 7/27/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import Foundation


typealias  ContainsAction = (_ sender: UIBarButtonItem) -> Void

class NavigationBarList {
    
    let settings: UIBarButtonItem
    
    let search: UIBarButtonItem
    
    let more: UIBarButtonItem
    
    let delete: UIBarButtonItem
    
    let showHide: UIBarButtonItem
    
    let done: UIBarButtonItem
    
    let gift: UIBarButtonItem

    init() {
        settings = UIBarButtonItem(image: UIImage(named: TextConstants.cogBtnImgName),
                                   style: .plain,
                                   target: nil,
                                   action: nil)
        
        settings.accessibilityLabel = TextConstants.accessibilitySettings
        
        search = UIBarButtonItem(image: UIImage(named: TextConstants.searchBtnImgName),
                                 style: .plain,
                                 target: nil,
                                 action: nil )
        search.accessibilityLabel = TextConstants.accessibilitySearch

        more = UIBarButtonItem(image: UIImage(named: TextConstants.moreBtnImgName),
                               style: .plain,
                               target: nil,
                               action: nil)
        more.accessibilityLabel = TextConstants.accessibilityMore
        
        delete = UIBarButtonItem(image: UIImage(named: TextConstants.deleteBtnImgName),
                                 style: .plain,
                                 target: nil,
                                 action: nil)
        delete.accessibilityLabel = TextConstants.accessibilityDelete
        
        showHide = UIBarButtonItem.init(title: TextConstants.showHideBtnTitleName,
                                        target: nil,
                                        selector: nil)
        showHide.accessibilityLabel = TextConstants.accessibilityshowHide
        
        done = UIBarButtonItem(title: TextConstants.faceImageDone,
                               style: .plain,
                               target: nil,
                               selector: nil)
        
        done.accessibilityLabel = TextConstants.accessibilityDone
        
        gift = UIBarButtonItem(image: UIImage(),
                                        style: .plain,
                                        target: nil,
                                        action: nil)
        gift.setBackgroundImage(UIImage(named: TextConstants.giftButtonName), for: .normal, barMetrics: .default)
        gift.setBackgroundImage(UIImage(named: TextConstants.giftButtonName)?.mask(with: .gray), for: .selected, barMetrics: .default)
        gift.accessibilityLabel = TextConstants.accessibilityGift
        
        
        // upload 
        // create
        // add
        // edit
    }
}

class NavBarWithAction: NSObject {
    
    var navItem: UIBarButtonItem
    
    let action: ContainsAction
    
    init(navItem: UIBarButtonItem, action : @escaping ContainsAction) {
        self.navItem = navItem
        self.action = action
    }
}


class NavigationBarConfigurator {
    
    private var right: [NavBarWithAction]?
    
    private var left: [NavBarWithAction]?
    
    var rightItems: [UIBarButtonItem]? {
        return self.right?.compactMap { $0.navItem }
    }
    
    func configure(right: [NavBarWithAction]?, left: [NavBarWithAction]?) {
        self.right = right
        self.right?.forEach {
            setActionAndTarget(navBarAction: $0)
        }
    }
    
    func append(rightButton: NavBarWithAction?, leftButton: NavBarWithAction?) {
        if let rightButton = rightButton {
            right?.append(rightButton)
            setActionAndTarget(navBarAction: rightButton)
        }
        if let leftButton = leftButton {
            left?.append(leftButton)
            setActionAndTarget(navBarAction: leftButton)
        }
    }
    
    private func setActionAndTarget(navBarAction: NavBarWithAction?) {
        navBarAction?.navItem.action = #selector(baseAction(sender:))
        navBarAction?.navItem.target = self
    }
    
    @objc func baseAction(sender: UIBarButtonItem) {

        var list: [NavBarWithAction]?
        list = right
        
        if let btn = list?.filter({ $0.navItem == sender }) {
            btn.first?.action(sender)
        }

    }
}
