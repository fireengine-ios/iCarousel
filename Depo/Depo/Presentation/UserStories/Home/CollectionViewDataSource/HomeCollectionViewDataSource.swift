//
//  HomeCollectionViewDataSource.swift
//  Depo
//
//  Created by Oleg on 26.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

protocol HomeCollectionViewDataSourceDelegate: class {
    func onCellHasBeenRemovedWith(controller: UIViewController)
    func numberOfColumns() -> Int
    func collectionView(collectionView: UICollectionView, heightForHeaderinSection section: Int) -> CGFloat
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
    func didReloadCollectionView(_ collectionView: UICollectionView)
}

final class HomeCollectionViewDataSource: NSObject, BaseCollectionViewCellWithSwipeDelegate {
    
    private weak var delegate: HomeCollectionViewDataSourceDelegate?
    
    private var collectionView: UICollectionView!
    private var viewController: UIViewController!
    
    private var viewsByType = [OperationType: [BaseCardView]]()
    
    private var notPermittedCardsViewTypes = Set<String>()
    
    var isEnable = true
    var isViewActive = false
    
    var cards = [BaseCardView]()
    
    //FE-1720
//    private let cardsRefreshQueue = DispatchQueue(label: DispatchQueueLabels.homePageCardsUpdateQueue)
    
    func configurateWith(collectionView: UICollectionView, viewController: UIViewController, delegate: HomeCollectionViewDataSourceDelegate?) {
        
        self.collectionView = collectionView
        self.delegate = delegate
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        if let layout = collectionView.collectionViewLayout as? HomeCollectionViewLayout {
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
    }
    
    // MARK: BaseCollectionViewCellWithSwipeDelegate
    
    func onCellDeleted(cell: UICollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell), let view = self.cards[safe: indexPath.row] else {
            return
        }
        
        updateCards(remove: [view])
    }
    
    // MARK: WrapItemOperationViewProtocol
    
    private func checkIsThisIsPermittedType(type: OperationType) -> Bool {
        let isPermitted: Bool
        
        if !isEnable {
            isPermitted = false
            
        } else if notPermittedCardsViewTypes.isEmpty {
            isPermitted = true
            
        } else {
            isPermitted = !notPermittedCardsViewTypes.contains(type.rawValue)
            
        }
        
        return isPermitted
    }
    
    private func checkIsNeedShowCardFor(operationType: OperationType) -> Bool {
        switch operationType {
        case .prepareToAutoSync:
            return viewsByType[.sync] == nil
        case .premium:
            return !cards.contains(where: { $0 is PremiumInfoCard })
        default:
            return true
        }
    }
    
    func getViewForOperation(operation: OperationType) -> BaseCardView {
        return CardsManager.cardViewForOperaion(type: operation)
    }
    
    func setViewByType(view: BaseCardView, operation: OperationType) {
        var array = viewsByType[operation]
        if array == nil {
            array = [BaseCardView]()
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
        if let view = cards.first(where: { $0 is PremiumInfoCard }) as? PremiumInfoCard,
            (view.isPremium != AuthoritySingleton.shared.accountType.isPremium || AuthoritySingleton.shared.isLosePremiumStatus) {
            
            view.configurateWithType(viewType: .premium)
            
            //FE-1720
//            reloadCollectionView()
            collectionView.reloadData()
        }
    }
    
    //FE-1720
//    private func reloadCollectionView() {
//        cardsRefreshQueue.async(flags: .barrier) { [weak self] in
//            let semaphore = DispatchSemaphore(value: 0)
//
//            DispatchQueue.main.async { [weak self] in
//                self?.collectionView.reloadData()
//
//                semaphore.signal()
//            }
//
//            semaphore.wait()
//        }
//    }
    
    func updateCards(insert: [BaseCardView] = [], remove: [BaseCardView] = []) {
        ///remove
        var removeIndexes = [Int]()
        
        var removingCards = [BaseCardView]()
        for card in remove {
            if let index = self.cards.firstIndex(where: { $0 == card && !$0.isContained(in: removingCards) }) {
                removingCards.append(self.cards[index])
                removeIndexes.append(index)
            }
        }
        
        removeIndexes.forEach { self.cards.remove(at: $0) }
        
        ///insert
        let insertedCards = insert.filter { insertingCard in
            !self.cards.contains(insertingCard)
        }
        
        self.cards.append(contentsOf: insertedCards)
        
        ///sort
        self.cards = self.cards.sorted(by: { view1, view2 -> Bool in
            let order1 = view1.cardObject?.order ?? 0
            let order2 = view2.cardObject?.order ?? 0
            if order1 == order2 {
                return view1 is PremiumInfoCard
            }
            return order1 < order2
        })
        
        collectionView.reloadData()
    }

    //FE-1720
//    func updateCards(insert: [BaseCardView] = [], remove: [BaseCardView] = []) {
//        cardsRefreshQueue.async(flags: .barrier) { [weak self] in
//            guard let self = self else {
//                return
//            }
//
//            ///remove
//            var removeIndexes = [Int]()
//
//            var removingCards = [BaseCardView]()
//            for card in remove {
//                if let index = self.cards.firstIndex(where: { $0 == card && !$0.isContained(in: removingCards) }) {
//                    removingCards.append(self.cards[index])
//                    removeIndexes.append(index)
//                }
//            }
//
//            removeIndexes.forEach { self.cards.remove(at: $0) }
//
//            ///insert
//            let insertedCards = insert.filter { insertingCard in
//                !self.cards.contains(insertingCard)
//            }
//
//            self.cards.append(contentsOf: insertedCards)
//
//            ///sort
//            self.cards = self.cards.sorted(by: { view1, view2 -> Bool in
//                let order1 = view1.cardObject?.order ?? 0
//                let order2 = view2.cardObject?.order ?? 0
//                if order1 == order2 {
//                    return view1 is PremiumInfoCard
//                }
//                return order1 < order2
//            })
//
//            guard self.isViewActive else {
//                let semaphore  = DispatchSemaphore(value: 0)
//
//                DispatchQueue.main.async {
//                    self.collectionView.reloadData()
//                    semaphore.signal()
//                }
//
//                semaphore.wait()
//                return
//            }
//
//            ///get indexes
//            var insertIndexes = insert.compactMap { self.cards.firstIndex(of: $0) }
//
//            ///find same indexes and convert to update indexes
//            let updateIndexes = removeIndexes.filter { insertIndexes.contains($0) }
//
//            ///remove common indexes
//            updateIndexes.forEach {
//                removeIndexes.remove($0)
//                insertIndexes.remove($0)
//            }
//
//            guard updateIndexes.hasItems || insertIndexes.hasItems || removeIndexes.hasItems else {
//                return
//            }
//
//            let semaphore = DispatchSemaphore(value: 0)
//
//            DispatchQueue.main.async {
//                self.collectionView.isUserInteractionEnabled = false
//
//                ///fix crash if  batch update starts performing while collectionView scrolled to the bottom
//                let rect = CGRect(origin: self.collectionView.contentOffset, size: .zero)
//                self.collectionView.scrollRectToVisible(rect, animated: true)
//
//                self.collectionView.performBatchUpdates({ [weak self] in
//                    guard let self = self else {
//                        return
//                    }
//
//                    if removeIndexes.hasItems {
//                        self.collectionView.deleteItems(at: removeIndexes.map { IndexPath(item: $0, section: 0) })
//                    }
//
//                    if insertIndexes.hasItems {
//                        self.collectionView.insertItems(at: insertIndexes.map { IndexPath(item: $0, section: 0) })
//                    }
//
//                    if updateIndexes.hasItems {
//                        self.collectionView.reloadItems(at: updateIndexes.map { IndexPath(item: $0, section: 0) })
//                    }
//
//                }, completion: { [weak self] _ in
//                    guard let self = self else {
//                        return
//                    }
//
//                    self.collectionView.isUserInteractionEnabled = true
//
//                    self.delegate?.didReloadCollectionView(self.collectionView)
//
//                    semaphore.signal()
//                })
//            }
//
//            semaphore.wait()
//        }
//    }
}

//MARK: CardsManagerViewProtocol
extension HomeCollectionViewDataSource: CardsManagerViewProtocol {
    
    func startOperationWith(type: OperationType, allOperations: Int?, completedOperations: Int?) {
        startOperationWith(type: type, object: nil, allOperations: allOperations, completedOperations: completedOperations)
    }
    
    func startOperationWith(type: OperationType, object: WrapData?, allOperations: Int?, completedOperations: Int?) {
        if !checkIsThisIsPermittedType(type: type), type != .premium {
            return
        }
        
        if !checkIsNeedShowCardFor(operationType: type) {
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
            
            if let card = view as? ProgressCard{
                card.setProgress(allItems: allOperations, readyItems: completedOperations)
                
                if let item = object {
                    card.setImageForUploadingItem(item: item)
                }
            }
            
            setViewByType(view: view, operation: type)
            updateCards(insert: [view])
        }
    }
    
    func startOperationsWith(serverObjects: [HomeCardResponse]) {
        var newCards = Set<BaseCardView>()
        
        for key in viewsByType.keys where !CardsManager.default.checkIsThisOperationStartedByDevice(operation: key) {
            viewsByType[key] = nil
        }
        
        for object in serverObjects {
            guard let type = object.getOperationType() else {
                continue
            }
            
            if let views = viewsByType[type], CardsManager.default.checkIsThisOperationStartedByDevice(operation: type) {
                views.forEach { view in
                    //FIXME: removeFromSuperview make cell become only with a shadow
                    view.removeFromSuperview()
                    view.set(object: object)
                    
                    newCards.insert(view)
                }
                
            } else if !CardsManager.default.checkIsThisOperationStartedByDevice(operation: type), checkIsThisIsPermittedType(type: type) {
                let view = getViewForOperation(operation: type)
                
                /// seems like duplicated logic "set(object:".
                //TODO: drop before regression tests.
                view.set(object: object)
                
                newCards.insert(view)
                setViewByType(view: view, operation: type)
            }
        }
        
        for card in cards where !newCards.contains(card) {
            if let type = card.cardObject?.getOperationType(), !CardsManager.default.checkIsThisOperationStartedByDevice(operation: type) {
                if card is PremiumInfoCard {
                    newCards.insert(card)
                }
                
                continue
            }
            
            newCards.insert(card)
        }
        
        let sortedCards = Array(newCards).sorted(by: { view1, view2 -> Bool in
            let order1 = view1.cardObject?.order ?? 0
            let order2 = view2.cardObject?.order ?? 0
            if order1 == order2 {
                return view1 is PremiumInfoCard
            }
            return order1 < order2
        })
        
        cards = sortedCards
        
        collectionView.reloadData()
        
        //FE-1720
//        cardsRefreshQueue.async(flags: .barrier) { [weak self] in
//            guard let self = self else {
//                return
//            }
//
//            let sortedCards = Array(newCards).sorted(by: { view1, view2 -> Bool in
//                let order1 = view1.cardObject?.order ?? 0
//                let order2 = view2.cardObject?.order ?? 0
//                if order1 == order2 {
//                    return view1 is PremiumInfoCard
//                }
//                return order1 < order2
//            })
//
//            self.cards = sortedCards
//
//            let semaphore = DispatchSemaphore(value: 0)
//
//            DispatchQueue.main.async {
//                self.collectionView.reloadData()
//
//                semaphore.signal()
//            }
//
//            semaphore.wait()
//        }
    }
    
    func setProgressForOperationWith(type: OperationType, object: WrapData?, allOperations: Int, completedOperations: Int) {
        guard isViewActive else {
            return
        }
        
        if let card = viewsByType[type]?.first as? ProgressCard {
            card.setProgress(allItems: allOperations, readyItems: completedOperations)
            if let item = object {
                card.setImageForUploadingItem(item: item)
            }
            
        } else {
            startOperationWith(type: type, allOperations: allOperations, completedOperations: completedOperations)
        }
    }
    
    func setProgress(ratio: Float, for operationType: OperationType, object: WrapData?) {
        guard isViewActive, let card = viewsByType[operationType]?.first as? ProgressCard else {
            return
        }
        
        card.setProgressBar(ratio: ratio)
        if let object = object {
            card.setImageForUploadingItem(item: object)
        }
    }
    
    func stopOperationWithType(type: OperationType) {
        guard let views = viewsByType[type] else {
            return
        }
        
        viewsByType[type] = nil
        views.forEach { view in
            updateCards(remove: [view])
        }
    }
    
    func stopOperationWithType(type: OperationType, serverObject: HomeCardResponse) {
        guard let views = viewsByType[type] else {
            return
        }
        
        var newArray = [BaseCardView]()
        
        views.forEach { view in
            if view.cardObject == serverObject {
                updateCards(remove: [view])
            } else {
                newArray.append(view)
            }
        }
        
        if newArray.isEmpty {
            viewsByType[type] = nil
        } else {
            viewsByType[type] = newArray
        }
    }
    
    func isEqual(object: CardsManagerViewProtocol) -> Bool {
        if let compairedView = object as? HomeCollectionViewDataSource {
            return compairedView == self
        }
        
        return false
    }
    
    func addNotPermittedCardViewTypes(types: [OperationType]) {
        let array = types.map { $0.rawValue }
        for operationName in array {
            notPermittedCardsViewTypes.insert(operationName)
        }
    }
    
    func configureInstaPick(with analysisStatus: InstapickAnalyzesCount) {
        guard
            let instaPickCard = cards.first(where: { $0 is InstaPickCard }) as? InstaPickCard,
            instaPickCard.isNeedReloadWithNew(status: analysisStatus)
        else {
            return
        }
        
        collectionView.reloadData()
        
        //FE-1720
//        reloadCollectionView()
    }
}

//MARK: UICollectionView datasource/delegate
extension HomeCollectionViewDataSource: UICollectionViewDataSource,  UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cards.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let delegate = delegate else {
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
        
        if let cardUpView = cards[safe: indexPath.row] {
            baseCell.addViewOnCell(controllersView: cardUpView)
            cardUpView.viewWillShow()
            
        } //else {
        //FE-1720
//            reloadCollectionView()
//        }
        
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
extension HomeCollectionViewDataSource: CollectionViewLayoutDelegate {
    func collectionView(collectionView: UICollectionView, heightForCellAtIndexPath indexPath: IndexPath, withWidth: CGFloat) -> CGFloat {
        guard let cardView = cards[safe: indexPath.row] else {
            return 40
        }
        
        cardView.frame.size = CGSize(width: withWidth,
                                     height: cardView.frame.size.height)
        cardView.layoutIfNeeded()
        
        return cardView.calculatedH
    }
    
    func collectionView(collectionView: UICollectionView, heightForHeaderinSection section: Int) -> CGFloat {
        return 0.1
        // TODO: clean project from HomeViewTopView and collectionView delegates from it
        /// to show home buttons
        //return HomeViewTopView.getHeight()
    }
}
