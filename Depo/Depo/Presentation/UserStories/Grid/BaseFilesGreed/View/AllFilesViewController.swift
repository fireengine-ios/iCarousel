//
//  AllFilesViewController.swift
//  Depo
//
//  Created by Alex Developer on 25.11.2020.
//  Copyright © 2020 LifeTech. All rights reserved.
//

final class AllFilesViewController: BaseFilesGreedChildrenViewController {
    
    private let sharedFilesManager = PrivateShareSliderFilesCollectionManager()
    
    private var isSliderSetuped = false
    
    private var lastCardContainerHeight: CGFloat = 0
    private let sortAreaHeight: CGFloat = 36
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBarHidden = true
        collectionView.addInteraction(UIDropInteraction(delegate: self))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func startSelection(with numberOfItems: Int) {
        super.startSelection(with: numberOfItems)
        configureCountView(isShown: true)
    }
    
    @objc override func loadData() {
        guard isRefreshAllowed else {
            return
        }
        if !output.isSelectionState() {
            output.onReloadData()
            contentSlider?.reloadAllData()
        } else {
            refresher.endRefreshing()
        }
    }
}

extension AllFilesViewController: UIDropInteractionDelegate {
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: DragAndDropAllFilesType.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        DragAndDropHelper.shared.performDrop(with: session, itemType: DragAndDropAllFilesType.self)
    }
}
