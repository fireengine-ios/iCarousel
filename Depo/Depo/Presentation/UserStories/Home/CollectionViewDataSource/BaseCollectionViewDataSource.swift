//
//  BaseCollectionViewDataSource.swift
//  Depo
//
//  Created by Oleg on 26.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

protocol BaseCollectionViewDataSourceDelegate: class {
    func onCellHasBeenRemovedWith(controller: UIViewController)
    func numberOfColumns() -> Int
    func collectionView(collectionView: UICollectionView, heightForHeaderinSection section: Int) -> CGFloat
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
    func didReloadCollectionView(_ collectionView: UICollectionView)
}

class BaseCollectionViewDataSource: NSObject, BaseCollectionViewCellWithSwipeDelegate, CardsManagerViewProtocol {
    
    var collectionView: UICollectionView!
    var viewController: UIViewController!
    
    weak var delegate: BaseCollectionViewDataSourceDelegate?
    
    var viewsByType = [OperationType: [BaseView]]()
    
    var popUps = [BaseView]()
    var notPermittedPopUpViewTypes = Set<String>()
    var isEnable: Bool = true
    var isActive: Bool = false
    var isViewActive = false
    
    func configurateWith(collectionView: UICollectionView, viewController: UIViewController, delegate: BaseCollectionViewDataSourceDelegate?) {
        
        self.collectionView = collectionView
        collectionView.delegate = self
        collectionView.dataSource = self
        self.delegate = delegate
        
        if let layout = collectionView.collectionViewLayout as? CollectionViewLayout {
            layout.delegate = self
            if (delegate != nil) {
                layout.numberOfColumns = delegate!.numberOfColumns()
            } else {
                layout.numberOfColumns = 1
            }
        }
        let headerNib = UINib(nibName: "HomeViewTopView", bundle: nil)
        collectionView.register(headerNib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HomeViewTopView")
        let nibName = UINib(nibName: CollectionViewCellsIdsConstant.cellForController, bundle: nil)
        collectionView.register(nibName, forCellWithReuseIdentifier: CollectionViewCellsIdsConstant.cellForController)
        collectionView.reloadData()
    }
    
    func isPopUpCell(path: IndexPath) -> Bool {
        return path.row < popUps.count
    }
    
    // MARK: BaseCollectionViewCellWithSwipeDelegate
    
    func onCellDeleted(cell: UICollectionViewCell) {
        let indehPath = collectionView.indexPath(for: cell)
        guard let path = indehPath else {
            return
        }
        popUps.remove(at: path.row)
        collectionView.deleteItems(at: [path])
    }
    
    // MARK: animation of collectionView
    
    func addCellAtIndex(index: Int) {
        if (isActive) {
            print(Date().timeIntervalSince1970)
            self.collectionView.performBatchUpdates({
                print(Date().timeIntervalSince1970)
                let indexPath = IndexPath(row: index, section: 0)
                self.collectionView.insertItems(at: [indexPath])
            }, completion: { succes in
                print("finished competition")
            })
        } else {
            collectionView.reloadData()
        }
    }
    
    // MARK: WrapItemOperationViewProtocol
    
    private func checkIsThisIsPermittedType(type: OperationType) -> Bool {
        
        if !isEnable {
            return false
        }
        
        if notPermittedPopUpViewTypes.count == 0 {
            return true
        }
        return !notPermittedPopUpViewTypes.contains(type.rawValue)
    }
    
    private func checkIsNeedShowPopUpFor(operationType: OperationType) -> Bool {
        switch operationType {
        case .prepareToAutoSync:
            return viewsByType[.sync] == nil
        case .premium:
            return !popUps.contains(where: { $0 is PremiumInfoCard })
        default:
            return true
        }
    }
    
    func getViewForOperation(operation: OperationType) -> BaseView {
        return CardsManager.popUpViewForOperaion(type: operation)
    }
    
    func setViewByType(view: BaseView, operation: OperationType) {
        var array = viewsByType[operation]
        if array == nil {
            array = [BaseView]()
            array?.append(view)
            viewsByType[operation] = array
            return
        }
        if CardsManager.default.checkIsThisOperationStartedByDevice(operation: operation) && array!.isEmpty != false {
            return
        }
        array?.append(view)
        viewsByType[operation] = array
    }
    
    func configureInstaPick(with analysisStatus: InstapickAnalyzesCount) {
        guard let instaPickCard = popUps.first(where: { $0 is InstaPickCard }) as? InstaPickCard,
            instaPickCard.isNeedReloadWithNew(status: analysisStatus),
            let index = popUps.index(of: instaPickCard) else {
            return
        }

        let indexPath = IndexPath(item: index, section: 0)
        collectionView.performBatchUpdates({ [weak self] in
            self?.collectionView.reloadItems(at: [indexPath])
        }, completion: nil)
    }
    
    func startOperationWith(type: OperationType) {
        if viewsByType[type] == nil {
            let view = getViewForOperation(operation: type)
            setViewByType(view: view, operation: type)
            //helps to keep PremiumInfoCard on top
            let index = (popUps.first(where: { $0.isKind(of: PremiumInfoCard.self) }) != nil) ? 1 : 0
            
            print("insert at index ", index, type.rawValue)
            self.popUps.insert(view, at: index)
            self.addCellAtIndex(index: index)
        }
    }
    
    func startOperationWith(type: OperationType, allOperations: Int?, completedOperations: Int?) {
        startOperationWith(type: type, object: nil, allOperations: allOperations, completedOperations: completedOperations)
    }
    
    func startOperationsWith(serverObjects: [HomeCardResponse]) {
        var newPopUps = [BaseView]()
        
        for key in viewsByType.keys {
            if !CardsManager.default.checkIsThisOperationStartedByDevice(operation: key) {
                viewsByType[key] = nil
            }
        }
        
        for object in serverObjects {
            if let type = object.getOperationType(){
                if let views = viewsByType[type], CardsManager.default.checkIsThisOperationStartedByDevice(operation: type) {
                    for view in views {
                        view.removeFromSuperview()
                        view.set(object: object)
                        newPopUps.append(view)
                        if let index = popUps.index(of: view){
                            popUps.remove(at: index)
                        }
                    }
                } else {
                    if !checkIsThisIsPermittedType(type: type) {
                        continue
                    }
                    if !checkIsNeedShowPopUpFor(operationType: type) {
                        continue
                    }
                    if !CardsManager.default.checkIsThisOperationStartedByDevice(operation: type) {
                        let view = getViewForOperation(operation: type)
                        
                        /// seems like duplicated logic "set(object:".
                        /// needs to drop before regression tests.
                        view.set(object: object)
                        
                        newPopUps.insert(view, at: 0)
                        setViewByType(view: view, operation: type)
                    }
                }
            }
        }
        
        for popUp in popUps {
            if let type = popUp.cardObject?.getOperationType(), !CardsManager.default.checkIsThisOperationStartedByDevice(operation: type) {
                continue
            } else {
                newPopUps.insert(popUp, at: 0)
            }
        }
        
        newPopUps = newPopUps.sorted(by: { view1, view2 -> Bool in
            let order1 = view1.cardObject?.order ?? 0
            let order2 = view2.cardObject?.order ?? 0
            if order1 == order2 {
                return view1 is PremiumInfoCard
            }
            return order1 < order2
        })
        
        popUps.removeAll()
        popUps.append(contentsOf: newPopUps)
        
        collectionView.reloadData()
        delegate?.didReloadCollectionView(self.collectionView)
    }
    
    func startOperationWith(type: OperationType, object: WrapData?, allOperations: Int?, completedOperations: Int?) {
        if !checkIsThisIsPermittedType(type: type), type != .premium {
            return
        }
        if !checkIsNeedShowPopUpFor(operationType: type) {
            if type == .premium {
                ///We setup it always as first item In “this” method, the cell does not store this view and adds it as subview
                if let view = collectionView.cellForItem(at: IndexPath(item: 0, section: 0))?.contentView.subviews.first as? PremiumInfoCard {
                    view.viewWillShow()
                }
                
                refreshPremiumCard()
            }
            return
        }
        
        if viewsByType[type] == nil {
            let view = getViewForOperation(operation: type)
            view.layoutIfNeeded()
            if let popUp = view as? ProgressPopUp {
                popUp.setProgress(allItems: allOperations, readyItems: completedOperations)
                if let item = object {
                    popUp.setImageForUploadingItem(item: item)
                }
            }
            
            setViewByType(view: view, operation: type)
            let index = 0
            popUps.insert(view, at: index)
            popUps = popUps.sorted(by: { view1, view2 -> Bool in
                let order1 = view1.cardObject?.order ?? 0
                let order2 = view2.cardObject?.order ?? 0
                if order1 == order2 {
                    return view1 is PremiumInfoCard
                }
                return order1 < order2
            })
            collectionView?.reloadData()
            delegate?.didReloadCollectionView(self.collectionView)
        }
    }

    private func refreshPremiumCard() {
        if let view = popUps.filter({ $0 is PremiumInfoCard }).first as? PremiumInfoCard,
            (view.isPremium != AuthoritySingleton.shared.accountType.isPremium || AuthoritySingleton.shared.isLosePremiumStatus) {
            view.configurateWithType(viewType: .premium)
            collectionView.reloadData()
        }
    }
    
    func setProgressForOperationWith(type: OperationType, allOperations: Int, completedOperations: Int ) {
        guard isViewActive else {
            return
        }
        setProgressForOperationWith(type: type, object: nil, allOperations: allOperations, completedOperations: completedOperations)
    }
    
    func setProgressForOperationWith(type: OperationType, object: WrapData?, allOperations: Int, completedOperations: Int ) {
        guard isViewActive else {
            return
        }
        if let view = viewsByType[type]?.first {
            if let popUp = view as? ProgressPopUp {
                popUp.setProgress(allItems: allOperations, readyItems: completedOperations)
                if let item = object {
                    popUp.setImageForUploadingItem(item: item)
                }
            }
        } else {
            startOperationWith(type: type, allOperations: allOperations, completedOperations: completedOperations)
        }
    }
    
    func setProgress(ratio: Float, for operationType: OperationType, object: WrapData?) {
        guard isViewActive, let popUp = viewsByType[operationType]?.first as? ProgressPopUp else {
            return
        }
        
        popUp.setProgressBar(ratio: ratio)
        if let object = object {
            popUp.setImageForUploadingItem(item: object)
        }
    }
    
    
    func stopOperationWithType(type: OperationType) {
        if let views = self.viewsByType[type] {
            self.viewsByType[type] = nil
            for view in views {
                if let index = self.popUps.index(of: view) {
                    popUps.remove(at: index)
                    collectionView.reloadData()
                }
            }
        }
    }
    
    func stopOperationWithType(type: OperationType, serverObject: HomeCardResponse) {
        if let views = self.viewsByType[type] {
            var newArray = [BaseView]()
            
            for view in views {
                if let cardObject = view.cardObject, cardObject == serverObject {
                    if let index = self.popUps.index(of: view) {
                        popUps.remove(at: index)
                    }
                } else {
                    newArray.append(view)
                }
            }
            
            if newArray.isEmpty {
                self.viewsByType[type] = nil
            } else {
                self.viewsByType[type] = newArray
            }
            
            collectionView.reloadData()
        }
    }
    
    func isEqual(object: CardsManagerViewProtocol) -> Bool {
        if let compairedView = object as? BaseCollectionViewDataSource {
            return compairedView == self
        }
        return false
    }
    
    func addNotPermittedPopUpViewTypes(types: [OperationType]) {
        let array = types.map { $0.rawValue }
        for operationName in array {
            notPermittedPopUpViewTypes.insert(operationName)
        }
    }    
}
//MARK UICollectionView datasource/delegate
extension BaseCollectionViewDataSource: UICollectionViewDataSource,  UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return popUps.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if (self.delegate != nil) {
            return self.delegate!.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
        }
        assert(false, "Unexpected element kind")
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCellsIdsConstant.cellForController, for: indexPath)
        guard let baseCell = cell as? CollectionViewCellForController else {
            return cell
        }
        
        baseCell.setStateToDefault()
        baseCell.cellDelegate = self
        let popUpView = popUps[indexPath.row]
        baseCell.addViewOnCell(controllersView: popUpView)
        popUpView.viewWillShow()
        baseCell.willDisplay()
        return baseCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let baseCell = cell as? CollectionViewCellForController else {
            return
        }
        baseCell.didEndDisplay()
    }
}

//MARK UICollectionView Layout delegate
extension BaseCollectionViewDataSource: CollectionViewLayoutDelegate {
    func collectionView(collectionView: UICollectionView, heightForCellAtIndexPath indexPath: IndexPath, withWidth: CGFloat) -> CGFloat {
        if (isPopUpCell(path: indexPath)) {
            let popUpView = popUps[indexPath.row]
            popUpView.frame.size = CGSize(width: withWidth, height: popUpView.frame.size.height)
            popUpView.layoutIfNeeded()
            return popUpView.calculatedH
        }
        return 40
    }
    
    func collectionView(collectionView: UICollectionView, heightForHeaderinSection section: Int) -> CGFloat {
        return 0.1
        // TODO: clean project from HomeViewTopView and collectionView delegates from it
        /// to show home buttons
        //return HomeViewTopView.getHeight()
    }
}
