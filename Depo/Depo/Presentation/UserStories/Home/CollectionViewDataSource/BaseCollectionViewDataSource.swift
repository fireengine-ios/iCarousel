//
//  BaseCollectionViewDataSource.swift
//  Depo
//
//  Created by Oleg on 26.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

protocol BaseCollectionViewDataSourceDelegate {
    func onCellHasBeenRemovedWith(controller:UIViewController)
    func numberOfColumns()->Int
    func collectionView(collectionView: UICollectionView, heightForHeaderinSection section: Int) -> CGFloat
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
}

class BaseCollectionViewDataSource: NSObject, UICollectionViewDataSource, CollectionViewLayoutDelegate, BaseCollectionViewCellWithSwipeDelegate, CardsManagerViewProtocol {
    
    var collectionView: UICollectionView!
    var viewController: UIViewController!
    
    var controllersArray = [UIViewController]()
    
    var delegate:BaseCollectionViewDataSourceDelegate?
    
    var viewsByType = [OperationType: BaseView]()
    
    var popUps = [BaseView]()
    var notPermittedPopUpViewTypes = Set<String>()
    var isEnable: Bool = true
    var isActive: Bool = false
    
    func configurateWith(collectionView: UICollectionView, viewController:UIViewController, data:[UIViewController], delegate:BaseCollectionViewDataSourceDelegate?){
        
        self.collectionView = collectionView
        collectionView.dataSource = self
        self.delegate = delegate
        
        if let layout = collectionView.collectionViewLayout as? CollectionViewLayout {
            layout.delegate = self
            if (delegate != nil){
                layout.numberOfColumns = delegate!.numberOfColumns()
            }else{
                layout.numberOfColumns = 1
            }
        }
        
        let nibName = UINib(nibName: CollectionViewCellsIdsConstant.cellForController, bundle: nil)
        collectionView.register(nibName, forCellWithReuseIdentifier: CollectionViewCellsIdsConstant.cellForController)
        
        controllersArray.removeAll()
        controllersArray.insert(contentsOf: data, at: 0)
        
        for controller in controllersArray{
            controller.view.layoutSubviews()
            viewController.addChildViewController(controller)
        }
        
        collectionView.reloadData()
        
    }
    
    func collectionView(collectionView: UICollectionView, heightForCellAtIndexPath indexPath: IndexPath, withWidth:CGFloat) -> CGFloat{
        if (isPopUpCell(path: indexPath)){
            let popUpView = popUps[indexPath.row]
            return popUpView.frame.size.height
        }
            
        let vC = controllersArray[indexPath.row - popUps.count]
        guard let contr = vC as? BaseCollectionViewController else {
            return 40
        }
        contr.calculateHeight(forWidth: withWidth)
        return contr.calculatedH
    }
    
    func collectionView(collectionView: UICollectionView, heightForHeaderinSection section: Int) -> CGFloat{
        return HomeViewTopView.getHeight()
    }
    
    func isPopUpCell(path: IndexPath) -> Bool{
        return path.row < popUps.count
    }
    
    //MARK UICollectionView delegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return controllersArray.count + popUps.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if (self.delegate != nil){
            return self.delegate!.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
        }
        assert(false, "Unexpected element kind")
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCellsIdsConstant.cellForController, for: indexPath)
        guard let baseCel = cell as? CollectionViewCellForController else {
            return cell
        }
        baseCel.setStateToDefault()
        baseCel.cellDelegate = self
        if (isPopUpCell(path: indexPath)){
            let popUpView = popUps[indexPath.row]
            baseCel.addViewOnCell(controllersView: popUpView, withShadow: true)
        }else{
            let viewController = controllersArray[indexPath.row - popUps.count]
            baseCel.addViewOnCell(controllersView: viewController.view, withShadow: true)
        }
        
        return baseCel
    }
    
    // MARK: BaseCollectionViewCellWithSwipeDelegate
    
    func onCellDeleted(cell: UICollectionViewCell){
        let indehPath = collectionView.indexPath(for: cell)
        guard let path = indehPath else {
            return
        }
        if (isPopUpCell(path: path)){
            popUps.remove(at: path.row)
        }else{
            let controller = controllersArray[path.row]
            controllersArray.remove(at: path.row)
            controller.removeFromParentViewController()
            delegate?.onCellHasBeenRemovedWith(controller: controller)
        }
        collectionView.deleteItems(at: [path])
    }
    
    //MARK: animation of collectionView
    
    func addCellAtIndex(index: Int){
        //collectionView.reloadData()
        //return
        
        if (isActive){
            print(Date().timeIntervalSince1970)
            self.collectionView.performBatchUpdates({
                print(Date().timeIntervalSince1970)
                let indexPath = IndexPath(row: index, section: 0)
                self.collectionView.insertItems(at: [indexPath])
            }, completion: { (succes) in
                print("finished competition")
            })
        }else{
            collectionView.reloadData()
        }
    }
    
    func deleteCellAtIndex(index: Int){
        var needReload = true
        if (isActive){
            let rowIndexes = collectionView.indexPathsForVisibleItems.map({ $0.row })
            if rowIndexes.contains(index){
                needReload = false
                popUps.remove(at: index)
                collectionView.performBatchUpdates({
                    let indexPath = IndexPath(row: index, section: 0)
                    self.collectionView.deleteItems(at: [indexPath])
                }, completion: { (succes) in
                    print("finished competition")
                })
            }
        }
        
        if needReload {
            popUps.remove(at: index)
            collectionView.reloadData()
        }
    }
    
    //MARK: WrapItemOperationViewProtocol
    
    private func checkIsThisIsPermittedType(type: OperationType) -> Bool{
        
        if !isEnable{
            return false
        }
        
        if notPermittedPopUpViewTypes.count == 0 {
            return true
        }
        return !notPermittedPopUpViewTypes.contains(type.rawValue)
    }
    
    private func checkIsNeedShowPopUpFor(operationType: OperationType) -> Bool{
        switch operationType {
        case .prepareToAutoSync:
            return viewsByType[.sync] == nil
        default:
            return true
        }
    }
    
    func getViewForOperation(operation: OperationType) -> BaseView{
        return CardsManager.popUpViewForOperaion(type: operation)
    }
    
    func startOperationWith(type: OperationType){
        if viewsByType[type] == nil {
            let view = getViewForOperation(operation: type)
            viewsByType[type] = view
            let index = 0
            
            print("insert at index ", index, type.rawValue)
            self.popUps.insert(view, at: index)
            self.addCellAtIndex(index: index)
        }
    }
    
    func startOperationWith(type: OperationType, allOperations: Int?, completedOperations: Int?){
        startOperationWith(type: type, object: nil, allOperations: allOperations, completedOperations: completedOperations)
    }
    
    func startOperationWith(type: OperationType, object: WrapData?, allOperations: Int?, completedOperations: Int?){
        if !checkIsThisIsPermittedType(type: type){
            return
        }
        if !checkIsNeedShowPopUpFor(operationType: type){
            return
        }
        
        if viewsByType[type] == nil {
            let view = getViewForOperation(operation: type)
            
            if let popUp = view as? ProgressPopUp {
                popUp.setProgress(allItems: allOperations, readyItems: completedOperations)
                if let item = object{
                    popUp.setImageForUploadingItem(item: item)
                }
            }
            
            viewsByType[type] = view
            let index = 0
            print("insert at index ", index, type.rawValue)
            self.popUps.insert(view, at: index)
            self.addCellAtIndex(index: index)
        }
    }
    
    func setProgressForOperationWith(type: OperationType, allOperations: Int, completedOperations: Int ) {
        setProgressForOperationWith(type: type, object: nil, allOperations: allOperations, completedOperations: completedOperations)
    }
    
    func setProgressForOperationWith(type: OperationType, object: WrapData?, allOperations: Int, completedOperations: Int ) {
        if let view = viewsByType[type] {
            if let popUp = view as? ProgressPopUp {
                popUp.setProgress(allItems: allOperations, readyItems: completedOperations)
                if let item = object{
                    popUp.setImageForUploadingItem(item: item)
                }
            }
        } else {
            startOperationWith(type: type, allOperations: allOperations, completedOperations: completedOperations)
        }
    }
    
    func setProgress(ratio: Float, for operationType: OperationType, object: WrapData?) {
        guard let popUp = viewsByType[operationType] as? ProgressPopUp else {
            return
        }
        
        popUp.setProgressBar(ratio: ratio)
        if let object = object{
            popUp.setImageForUploadingItem(item: object)
        }
    }
    
    
    func stopOperationWithType(type: OperationType){
        if let view = self.viewsByType[type] {
            self.viewsByType[type] = nil
            if let index = self.popUps.index(of: view){
                
                print("delete at index ", index, type.rawValue)
                self.deleteCellAtIndex(index: index)
            }else{
                
            }
        }
    }
    
    func isEqual(object: CardsManagerViewProtocol) -> Bool{
        if let compairedView = object as? BaseCollectionViewDataSource{
            return compairedView == self
        }
        return false
    }
    
    func addNotPermittedPopUpViewTypes(types: [OperationType]){
        let array = types.map{$0.rawValue}
        for operationName in array{
            notPermittedPopUpViewTypes.insert(operationName)
        }
    }
    
}
