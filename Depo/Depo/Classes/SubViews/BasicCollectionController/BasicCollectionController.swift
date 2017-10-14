//
//  BasicCollectionController.swift
//  Depo
//
//  Created by Aleksandr on 6/28/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

//SimpleBasicCollectionController : BasicCustomNavBarViewController
protocol BasicCollectionControllerActionsDelegate: class {
    func cellGotPressed(cell: BasicCollectionMultiFileCell)
}

class BasicCollectionController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    typealias Item = WrapData
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    weak var actionsDelegate: BasicCollectionControllerActionsDelegate?
    
    var models: [Item] = []
    
    let dataSource = BasicCollectionMultiFileDataSource()
    
    var currentAppearanceModel: CellAppearanceModel! {
        didSet {
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Device.isIpad {
            currentAppearanceModel = BasicCollectionControllerAppearanceConfig.cellGridAppearanceModeliPad
        } else {
           currentAppearanceModel = BasicCollectionControllerAppearanceConfig.cellGridAppearanceModeliPhone
        }
        //cellListAppearanceModeliPhone //TODO: get it from user last settings
        
//        scrollViewTopConstraint.constant = 50
//        collectionView.backgroundColor = UIColor.cyan

        collectionView.register(UINib(nibName: CollectionViewCellsIdsConstant.baseMultiFileCell, bundle: nil), forCellWithReuseIdentifier: CollectionViewCellsIdsConstant.baseMultiFileCell)
        
        collectionView.register(UINib(nibName: CollectionViewSuplementaryConstants.baseCollectionSuplementaryHeaderXIBName, bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: CollectionViewSuplementaryConstants.baseCollectionSuplementaryHeaderReuseID)
        
        
        collectionView.delegate = self
        collectionView.dataSource = self// dataSource
        
        collectionView.layoutSubviews()
        
    }
    
    func setupWith(fileModels: [Item]) {
        models = fileModels
        collectionView.reloadData()
    }
    
    func addNewFileModels(fileModels: [BaseMediaContent]) {
        
    }
    
    func presentAsList() {
        if currentAppearanceModel.appearanceType == BasicCollectionControllerAppearanceConfig.cellListAppearanceModeliPhone.appearanceType {//FIXME: chnage it to generic value instead of raw
            debugPrint("already list")
            return
        }
        currentAppearanceModel = BasicCollectionControllerAppearanceConfig.cellListAppearanceModeliPhone
    }
    
    func presentAsGrid() {
        if currentAppearanceModel.appearanceType == BasicCollectionControllerAppearanceConfig.cellGridAppearanceModeliPhone.appearanceType {
            debugPrint("already grid")
            return
        }
        if Device.isIpad {
            currentAppearanceModel = BasicCollectionControllerAppearanceConfig.cellGridAppearanceModeliPad
        } else {
            currentAppearanceModel = BasicCollectionControllerAppearanceConfig.cellGridAppearanceModeliPhone
        }

    }
    //TODO: convey
    private func conveyFileModelToCellModel() -> BasicCollectionMultiFileCellModel? {
    
        return nil
    }
    
    
    //MARK: - Collection delegates:
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCellsIdsConstant.baseMultiFileCell, for: indexPath)
        
        if let multiCell = cell as? BasicCollectionMultiFileCell {
            multiCell.confireWithWrapperd(wrappedObj: models[indexPath.row])
            FilesDataSource().getImage(patch: models[indexPath.row].patchToPreview, compliteImage: { (img) in
                //multiCell.contentImageView.image = img
            })
        }
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: CollectionViewSuplementaryConstants.baseCollectionSuplementaryHeaderReuseID, for: indexPath)
        guard let basicCollectionHeader = header as? SupplementaryLabelHeader else {
            return header
        }
        basicCollectionHeader.setupTitle(withText: "Section")
        return basicCollectionHeader
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return currentAppearanceModel.size
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return currentAppearanceModel.minimumSectionLineSpacing
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return currentAppearanceModel.minimumInteritemSpacingSection
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return currentAppearanceModel.headerSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return currentAppearanceModel.insetsEdge
    }
    
    
    //MARK: - collection selection delegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let pressedCell = collectionView.cellForItem(at: indexPath) as? BasicCollectionMultiFileCell else {
            return
        }
        actionsDelegate?.cellGotPressed(cell: pressedCell)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
    }

}
