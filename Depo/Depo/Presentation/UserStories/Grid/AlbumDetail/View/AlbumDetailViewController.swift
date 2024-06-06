//
//  AlbumDetailAlbumDetailViewController.swift
//  Depo
//
//  Created by Oleg on 24/08/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class AlbumDetailViewController: BaseFilesGreedChildrenViewController {

    var album: AlbumItem?
    private lazy var storageVars: StorageVars = factory.resolve()
    private lazy var closeSelfButton = UIBarButtonItem(image: NavigationBarImage.back.image,
                                                       style: .plain,
                                                       target: self,
                                                       action: #selector(closeSelf))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = closeSelfButton
        view.addInteraction(UIDropInteraction(delegate: self))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let name = album?.name {
            mainTitle = name
        }
        super.viewWillAppear(animated)
    }
    
    @objc private func closeSelf() {
        if storageVars.albumDetailFromDeeplink {
            dismiss(animated: false)
            let root = RouterVC()
            root.openTabBarItem(index: .forYou)
        } else {
            navigationController?.popViewController(animated: true)
        }
        storageVars.albumDetailFromDeeplink = false
    }
    
    override func stopSelection() {
        super.stopSelection()
        configurateNavigationBar()
    }
    
    override func configureNavBarActions(isSelecting: Bool = false) {
        let search = NavBarWithAction(navItem: NavigationBarList().search, action: { [weak self] _ in
            self?.output.searchPressed(output: self)
        })
        
        let more = NavBarWithAction(navItem: NavigationBarList().newAlbum, action: { [weak self] _ in
            let menuItems = self?.floatingButtonsArray.map { buttonType in
                AlertFilesAction(title: buttonType.title, icon: buttonType.image) { [weak self] in
                    self?.customTabBarController?.handleAction(buttonType.action)
                }
            }
            
            let menu = AlertFilesActionsViewController()
            menu.configure(with: menuItems ?? [])
            menu.presentAsDrawer()
        })
        
        let rightActions: [NavBarWithAction] = [more, search]
        search.navItem.imageInsets.left = 28
        navBarConfigurator.configure(right: isSelecting ? [] : rightActions, left: [])
        
        let navigationItem = (parent as? SegmentedController)?.navigationItem ?? self.navigationItem
        navigationItem.rightBarButtonItems = navBarConfigurator.rightItems
        navigationItem.title = ""
    }
    
    override func showNoFilesTop(text: String) {
        noFilesTopLabel?.text = text
        noFilesTopLabel?.isHidden = !cardsContainerView.viewsArray.isEmpty
        topBarContainer.isHidden = false
        view.layoutIfNeeded()
    }
}

extension AlbumDetailViewController: UIDropInteractionDelegate {
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: DragAndDropMediaType.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        DragAndDropHelper.shared.performDrop(with: session, itemType: DragAndDropMediaType.self, albumUUID: self.album?.uuid)
    }
}
