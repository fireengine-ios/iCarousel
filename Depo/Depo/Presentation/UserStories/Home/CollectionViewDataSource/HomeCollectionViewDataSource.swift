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
        
    private var isRefreshing = false ///determine collectionView refresh state (batchUpdate AND reloadData)
    private var isFinishedLoading = false ///determine first collectionView filling
    private var afterRefreshHandlers = [VoidHandler?]() ///handlers happened while refreshing

    private var insertCards = [BaseCardView]()
    private var removeCardsIndexes = [Int]()
    
    private var refreshCollectionViewTask: DispatchWorkItem?
    
    var cards = [BaseCardView]()
    
    private let cardsRefreshQueue = DispatchQueue(label: DispatchQueueLabels.homePageCardsUpdateQueue, qos: .userInitiated)

    var isEnable = true
    var isActive = false
    var isViewActive = false
    
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
        collectionView.reloadData()
    }
    
    // MARK: BaseCollectionViewCellWithSwipeDelegate
    
    func onCellDeleted(cell: UICollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell), indexPath.row < cards.count else {
            return
        }

        changeCards(remove: indexPath.row, delay: .now())
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
            
            resetCollectionViewUpdate { [weak self] in
                self?.collectionView.reloadData()
            }
        }
    }
    
    ///cancelling batchUpdate on reloadData
    private func resetCollectionViewUpdate(completion: VoidHandler? = nil) {
        guard !isRefreshing else {
            afterRefreshHandlers.append { [weak self] in
                self?.resetCollectionViewUpdate(completion: completion)
            }
            return
        }
        
        isRefreshing = true

        removeCardsIndexes.removeAll()
        insertCards.removeAll()
        
        refreshCollectionViewTask?.cancel()
        refreshCollectionViewTask = nil
        
        DispatchQueue.main.async {
            completion?()
            self.isRefreshing = false
            
            if self.afterRefreshHandlers.hasItems {
                let handler = self.afterRefreshHandlers.removeFirst()
                handler?()
            }
        }
    }
    
    ///method with delay because stopping cards performs one by one
    private func refreshCollection(remove: [Int] = [], insert: [BaseCardView] = [], delay: DispatchTime) {
        
        ///batch update starts working only after arriving server cards
        ///if not it's works BUT cards may appear without BaseView on it
        ///isViewActive AND isActive solve some crashes on home page  appear/dismiss process
        guard isFinishedLoading, isViewActive, isActive else {
            resetCollectionViewUpdate { [weak self] in
                self?.collectionView.reloadData()
            }
            
            return
        }
        
        refreshCollectionViewTask?.cancel()
                
        insertCards.append(contentsOf: insert)
        removeCardsIndexes.append(contentsOf: remove)

        let refreshCollectionViewTask = DispatchWorkItem { [weak self] in
            guard let self = self, !self.isRefreshing else {
                return
            }
            
            guard self.isViewActive, self.isActive else {
                self.resetCollectionViewUpdate {
                    self.collectionView.reloadData()
                }
                return
            }

            self.isRefreshing = true

            var remove = self.removeCardsIndexes
            var insert = self.insertCards.compactMap { self.cards.index(of: $0) }
            
            self.removeCardsIndexes.removeAll()
            self.insertCards.removeAll()

            ///find same indexes and convert to update indexes
            let update = remove.filter { insert.contains($0) }
            
            ///remove common indexes
            update.forEach {
                remove.remove($0)
                insert.remove($0)
            }
            
            DispatchQueue.main.async {
                ///fix crash if  batch update starts performing while collectionView scrolled to the bottom
                self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .bottom, animated: false)
                
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
                    
                    if self.afterRefreshHandlers.hasItems {
                        let handler = self.afterRefreshHandlers.removeFirst()
                        handler?()
                    }

                    self.delegate?.didReloadCollectionView(self.collectionView)
                })
            }
        }
        
        cardsRefreshQueue.asyncAfter(deadline: delay, execute: refreshCollectionViewTask)
        self.refreshCollectionViewTask = refreshCollectionViewTask
    }
    
    private func changeCards(insert: BaseCardView? = nil, remove: Int? = nil, delay: DispatchTime = .now() + NumericConstants.animationDuration) {
        guard !isRefreshing else {
            afterRefreshHandlers.append { [weak self] in
                self?.changeCards(insert: insert, remove: remove)
            }
            return
        }
        
        if let insert = insert {
            cards.append(insert)
        }
        
        if let remove = remove {
            let view = cards.remove(at: remove)
            
            if let index = insertCards.index(of: view) {
                insertCards.remove(at: index)
                return
            }
        }
        
        cards = cards.sorted(by: { view1, view2 -> Bool in
            let order1 = view1.cardObject?.order ?? 0
            let order2 = view2.cardObject?.order ?? 0
            if order1 == order2 {
                return view1 is PremiumInfoCard
            }
            return order1 < order2
        })
        
        refreshCollection(remove: [remove].compactMap { $0 }, insert: [insert].compactMap { $0 }, delay: delay)
    }
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
            view.layoutIfNeeded()
            if let card = view as? ProgressCard{
                card.setProgress(allItems: allOperations, readyItems: completedOperations)
                
                if let item = object {
                    card.setImageForUploadingItem(item: item)
                }
            }
            
            setViewByType(view: view, operation: type)
            changeCards(insert: view)
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
            ///tricky moment for Premiun info card
            ///popUp.cardObject?.getOperationType() - return nil
            ///BUT
            ///CardsManager.default.checkIsThisOperationStartedByDevice(operation: type) - true
            ///don't use guard-else OR find out a way to modefy code
            if let type = card.cardObject?.getOperationType(), !CardsManager.default.checkIsThisOperationStartedByDevice(operation: type) {
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

        resetCollectionViewUpdate { [weak self, sortedCards] in
            guard let self = self else {
                return
            }
            
            self.cards = sortedCards
            
            self.collectionView.reloadData()
            
            self.isFinishedLoading = true
        }
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
            if let index = cards.index(of: view) {
                changeCards(remove: index)
            }
        }
    }
    
    func stopOperationWithType(type: OperationType, serverObject: HomeCardResponse) {
        guard let views = viewsByType[type] else {
            return
        }
        
        var newArray = [BaseCardView]()

        views.forEach { view in
            if let index = cards.index(of: view), view.cardObject == serverObject {
                 changeCards(remove: index)
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
            instaPickCard.isNeedReloadWithNew(status: analysisStatus),
            let index = cards.index(of: instaPickCard)
        else {
            return
        }
        
        changeCards(insert: instaPickCard, remove: index)
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
            
        } else {
            assertionFailure("number of cells different with number of cards")
            resetCollectionViewUpdate { [weak self] in
                self?.collectionView.reloadData()
            }
            
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
