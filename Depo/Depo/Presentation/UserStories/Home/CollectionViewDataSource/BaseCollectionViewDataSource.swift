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

final class BaseCollectionViewDataSource: NSObject, BaseCollectionViewCellWithSwipeDelegate {
    
    private weak var delegate: BaseCollectionViewDataSourceDelegate?

    private var collectionView: UICollectionView!
    private var viewController: UIViewController!
        
    private var viewsByType = [OperationType: [BaseView]]()
    
    private var notPermittedPopUpViewTypes = Set<String>()
        
    private var isRefreshing = false ///determine collectionView refresh state (batchUpdate AND reloadData)
    private var isFinishedLoading = false ///determine first collectionView filling
    private var afterRefreshHandlers = [VoidHandler?]() ///handlers happened while refreshing

    private var insertPopUps = [BaseView]()
    private var removePopUpIndexes = [Int]()
    
    private var refreshCollectionViewTask: DispatchWorkItem?
    
    var popUps = [BaseView]()

    var isEnable = true
    var isActive = false
    var isViewActive = false
    
    func configurateWith(collectionView: UICollectionView, viewController: UIViewController, delegate: BaseCollectionViewDataSourceDelegate?) {
        
        self.collectionView = collectionView
        self.delegate = delegate

        collectionView.dataSource = self
        collectionView.delegate = self
        
        if let layout = collectionView.collectionViewLayout as? CollectionViewLayout {
            if let numberOfColumns = delegate?.numberOfColumns() {
                layout.numberOfColumns = numberOfColumns
            } else {
                layout.numberOfColumns = 1
            }
            
            layout.delegate = self
        }
        
        let headerNib = UINib(nibName: "HomeViewTopView", bundle: nil)
        collectionView.register(headerNib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HomeViewTopView")
        let nibName = UINib(nibName: CollectionViewCellsIdsConstant.cellForController, bundle: nil)
        collectionView.register(nibName, forCellWithReuseIdentifier: CollectionViewCellsIdsConstant.cellForController)
        collectionView.reloadData()
    }
    
    // MARK: BaseCollectionViewCellWithSwipeDelegate
    
    func onCellDeleted(cell: UICollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell), let view = popUps[safe: indexPath.row] else {
            return
        }

        popUps.remove(view)
        refreshCollection(remove: [indexPath.row], delay: .now())
    }
    
    // MARK: WrapItemOperationViewProtocol
    
    private func checkIsThisIsPermittedType(type: OperationType) -> Bool {
        let isPermitted: Bool
        
        if !isEnable {
            isPermitted = false
            
        } else if notPermittedPopUpViewTypes.isEmpty {
            isPermitted = true
            
        } else {
            isPermitted = !notPermittedPopUpViewTypes.contains(type.rawValue)
            
        }
        
        return isPermitted
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
        
        if CardsManager.default.checkIsThisOperationStartedByDevice(operation: operation), array?.isEmpty != false {
            return
        }
        
        array?.append(view)
        viewsByType[operation] = array
    }
    
    private func refreshPremiumCard() {
        if let view = popUps.first(where: { $0 is PremiumInfoCard }) as? PremiumInfoCard,
            (view.isPremium != AuthoritySingleton.shared.accountType.isPremium || AuthoritySingleton.shared.isLosePremiumStatus) {
            
            view.configurateWithType(viewType: .premium)
            
            resetCollectionViewUpdate { [weak self] in
                self?.collectionView.reloadData()
            }
        }
    }
    
    ///cancelling batchUpdate on reloadData
    private func resetCollectionViewUpdate(completion: VoidHandler? = nil) {
        self.removePopUpIndexes.removeAll()
        self.insertPopUps.removeAll()
        
        refreshCollectionViewTask?.cancel()
        refreshCollectionViewTask = nil
        
        if isRefreshing {
            afterRefreshHandlers.append(completion)
        } else {
            isRefreshing = true
            completion?()
            isRefreshing = false
        }
    }
    
    ///method with delay because stopping cards performs one by one
    private func refreshCollection(remove: [Int] = [], insert: [BaseView] = [], delay: DispatchTime = .now() + NumericConstants.animationDuration) {
        
        ///batch update starts working only after arriving server cards
        ///if not it's works BUT cards may appear without BaseView on it
        ///isViewActive AND isActive solve some crashes on home page  appear/dismiss process
        guard isFinishedLoading, isViewActive, isActive else {
            resetCollectionViewUpdate {
                self.collectionView.reloadData()
            }
            return
        }
        
        refreshCollectionViewTask?.cancel()
                
        insertPopUps.append(contentsOf: insert)
        removePopUpIndexes.append(contentsOf: remove)

        let refreshCollectionViewTask = DispatchWorkItem { [weak self] in
            guard let self = self, !self.isRefreshing else {
                return
            }
            
            guard self.isViewActive, self.isActive else {
                self.collectionView.reloadData()
                return
            }

            self.isRefreshing = true
            
            var remove = self.removePopUpIndexes
            var insert = self.insertPopUps.compactMap { self.popUps.index(of: $0) }
            
            self.removePopUpIndexes.removeAll()
            self.insertPopUps.removeAll()

            ///find same indexes and convert to update indexes
            let update = remove.filter { insert.contains($0) }
            
            ///remove common indexes
            update.forEach {
                remove.remove($0)
                insert.remove($0)
            }
            
            DispatchQueue.main.async {
                self.collectionView.performBatchUpdates({ [weak self] in
                    guard let self = self else {
                        return
                    }
                    
                    if !insert.isEmpty {
                        self.collectionView.insertItems(at: insert.map { IndexPath(item: $0, section: 0) })
                    }
                    
                    if !remove.isEmpty {
                        self.collectionView.deleteItems(at: remove.map { IndexPath(item: $0, section: 0) })
                    }
                    
                    if !update.isEmpty {
                        self.collectionView.reloadItems(at: update.map { IndexPath(item: $0, section: 0) })
                    }
                    
                }, completion: { [weak self] _ in
                    guard let self = self else {
                        return
                    }
                    
                    self.isRefreshing = false
                    
                    for refreshHandler in self.afterRefreshHandlers {
                        refreshHandler?()
                    }
                    
                    self.afterRefreshHandlers.removeAll()
                                        
                    self.delegate?.didReloadCollectionView(self.collectionView)
                })
            }
        }
        
        DispatchQueue.global().asyncAfter(deadline: delay, execute: refreshCollectionViewTask)
        self.refreshCollectionViewTask = refreshCollectionViewTask
    }
    
    private func changePopUps(insert: BaseView? = nil, remove: Int? = nil) {
        if let insert = insert {
            self.popUps.append(insert)
        }
        
        if let remove = remove {
            let view = self.popUps.remove(at: remove)
            
            if let index = self.insertPopUps.index(of: view) {
                self.insertPopUps.remove(at: index)
                return
            }
        }
        
        self.popUps = self.popUps.sorted(by: { view1, view2 -> Bool in
            let order1 = view1.cardObject?.order ?? 0
            let order2 = view2.cardObject?.order ?? 0
            if order1 == order2 {
                return view1 is PremiumInfoCard
            }
            return order1 < order2
        })
        
        self.refreshCollection(remove: [remove].compactMap { $0 }, insert: [insert].compactMap { $0 })
    }
}

//MARK: CardsManagerViewProtocol
extension BaseCollectionViewDataSource: CardsManagerViewProtocol {
    
    func startOperationWith(type: OperationType, allOperations: Int?, completedOperations: Int?) {
        startOperationWith(type: type, object: nil, allOperations: allOperations, completedOperations: completedOperations)
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
            changePopUps(insert: view)
        }
    }
    
    func startOperationsWith(serverObjects: [HomeCardResponse]) {
        var newPopUps = Set<BaseView>()
        
        for key in viewsByType.keys where !CardsManager.default.checkIsThisOperationStartedByDevice(operation: key) {
            viewsByType[key] = nil
        }
        
        for object in serverObjects {
            guard let type = object.getOperationType() else {
                continue
            }
            
            if let views = viewsByType[type], CardsManager.default.checkIsThisOperationStartedByDevice(operation: type) {
                views.forEach { view in
                    view.removeFromSuperview()
                    view.set(object: object)
                    
                    newPopUps.insert(view)
                }
                
            } else if !CardsManager.default.checkIsThisOperationStartedByDevice(operation: type), checkIsThisIsPermittedType(type: type) {
                let view = getViewForOperation(operation: type)
                
                /// seems like duplicated logic "set(object:".
                //TODO: drop before regression tests.
                view.set(object: object)
                
                newPopUps.insert(view)
                setViewByType(view: view, operation: type)
            }
        }
        
        for popUp in popUps where !newPopUps.contains(popUp) {
            ///tricky moment for Premiun info card
            ///popUp.cardObject?.getOperationType() - return nil
            ///BUT
            ///CardsManager.default.checkIsThisOperationStartedByDevice(operation: type) - true
            ///don't use guard-else OR find out a way to modefy code
            if let type = popUp.cardObject?.getOperationType(), !CardsManager.default.checkIsThisOperationStartedByDevice(operation: type) {
                continue
            }
            
            newPopUps.insert(popUp)
        }

        let sortedPopUps = Array(newPopUps).sorted(by: { view1, view2 -> Bool in
            let order1 = view1.cardObject?.order ?? 0
            let order2 = view2.cardObject?.order ?? 0
            if order1 == order2 {
                return view1 is PremiumInfoCard
            }
            return order1 < order2
        })
                
        resetCollectionViewUpdate { [sortedPopUps] in
            self.popUps = sortedPopUps

            self.collectionView.reloadData()

            self.isFinishedLoading = true
        }
    }
    
    func setProgressForOperationWith(type: OperationType, object: WrapData?, allOperations: Int, completedOperations: Int) {
        guard isViewActive else {
            return
        }
        
        if let popUp = viewsByType[type]?.first as? ProgressPopUp {
            popUp.setProgress(allItems: allOperations, readyItems: completedOperations)
            if let item = object {
                popUp.setImageForUploadingItem(item: item)
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
        guard let views = self.viewsByType[type] else {
            return
        }
        
        self.viewsByType[type] = nil
        views.forEach { view in
            if let index = self.popUps.index(of: view) {
                changePopUps(remove: index)
            }
        }
    }
    
    func stopOperationWithType(type: OperationType, serverObject: HomeCardResponse) {
        guard let views = self.viewsByType[type] else {
            return
        }
        
        var newArray = [BaseView]()
        
        views.forEach { view in
            if let index = self.popUps.index(of: view), view.cardObject == serverObject {
                changePopUps(remove: index)
            } else {
                newArray.append(view)
            }
        }
        
        if newArray.isEmpty {
            self.viewsByType[type] = nil
        } else {
            self.viewsByType[type] = newArray
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
    
    func configureInstaPick(with analysisStatus: InstapickAnalyzesCount) {
        guard
            let instaPickCard = popUps.first(where: { $0 is InstaPickCard }) as? InstaPickCard,
            instaPickCard.isNeedReloadWithNew(status: analysisStatus),
            let index = popUps.index(of: instaPickCard)
        else {
            return
        }
        
        changePopUps(insert: instaPickCard, remove: index)
    }
}

//MARK: UICollectionView datasource/delegate
extension BaseCollectionViewDataSource: UICollectionViewDataSource,  UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return popUps.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let delegate = self.delegate else {
            assert(false, "Unexpected element kind")
            return UICollectionReusableView()
        }
        
        return delegate.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCellsIdsConstant.cellForController, for: indexPath)
        guard let baseCell = cell as? CollectionViewCellForController else {
            return cell
        }
        
        baseCell.setStateToDefault()
        baseCell.cellDelegate = self
        
        if let popUpView = popUps[safe: indexPath.row] {
            baseCell.addViewOnCell(controllersView: popUpView)
            popUpView.viewWillShow()
        } else {
            assertionFailure("something went wrong! number of items in datasource and number of cells are different")
        }
        
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
        guard let popUpView = popUps[safe: indexPath.row] else {
            return 40
        }
        
        popUpView.frame.size = CGSize(width: withWidth,
                                      height: popUpView.frame.size.height)
        popUpView.layoutIfNeeded()

        return popUpView.calculatedH
    }
    
    func collectionView(collectionView: UICollectionView, heightForHeaderinSection section: Int) -> CGFloat {
        return 0.1
        // TODO: clean project from HomeViewTopView and collectionView delegates from it
        /// to show home buttons
        //return HomeViewTopView.getHeight()
    }
}
