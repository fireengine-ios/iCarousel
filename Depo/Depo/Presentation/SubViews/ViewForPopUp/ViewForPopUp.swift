//
//  CardsContainerView.swift
//  Depo_LifeTech
//
//  Created by Oleg on 19.09.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

@objc protocol ViewForPopUpDelegate {
    func onUpdateViewForPopUpH(h: CGFloat)
}

class CardsContainerView: UIView, UITableViewDelegate, UITableViewDataSource, SwipeableCardCellDelegate, CardsManagerViewProtocol {

    var hConstraint: NSLayoutConstraint?
    weak var delegate: ViewForPopUpDelegate?
    
    var tableView: UITableView = UITableView()
    var viewsArray = [BaseCardView]()
    var notPermittedPopUpViewTypes  = Set<String>()
    var permittedPopUpViewTypes     = Set<String>()
    var isEnable: Bool = false
    
    var viewsByType = [OperationType: BaseCardView]()
    
    static let indent: CGFloat = 10
    
    var isActive = false
    
    let lock = NSLock()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configurate()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configurate()
    }
    
    func configurate() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tableView)
        var constraints = [NSLayoutConstraint]()
        constraints.append(NSLayoutConstraint(item: tableView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: tableView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: tableView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: tableView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
        NSLayoutConstraint.activate(constraints)
        
        tableView.register(nibCell: SwipeableCardCell.self)
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
    }

    func addPopUpSubView(popUp: BaseCardView) {
        DispatchQueue.main.async {
            
            self.lock.lock()
            self.viewsArray.insert(popUp, at: 0)
            let path = IndexPath(row: 0, section: 0)
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: [path], with: .automatic)
            self.tableView.endUpdates()
            self.updateH()
            
            self.lock.unlock()
        }
    }
    
    func deletePopUpSubView(popUp: BaseCardView) {
        DispatchQueue.main.async {
            if let index = self.viewsArray.index(of: popUp) {
                self.lock.lock()
                let path = IndexPath(row: index, section: 0)
                self.viewsArray.remove(at: path.row)
                self.tableView.beginUpdates()
                self.tableView.deleteRows(at: [path], with: .automatic)
                self.tableView.endUpdates()
                self.updateH()
                self.lock.unlock()
            }
        }
    }
    
    private func updateH() {
        if hConstraint != nil {
            let h = calulateCurrentH()
            UIView.animate(withDuration: NumericConstants.animationDuration) {
                self.hConstraint?.constant = h
                self.superview?.layoutIfNeeded()
            }
        }
        if let delegate_ = delegate {
            delegate_.onUpdateViewForPopUpH(h: calulateCurrentH())
        }
    }
    
    private func calulateCurrentH() -> CGFloat {
        var h: CGFloat = 0
        for view in viewsArray {
            h = h + view.frame.size.height + 2 * CardsContainerView.indent
        }
        return h
    }
    
    // MARK: UITableView delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewsArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let view = viewsArray[indexPath.row]
        return view.frame.size.height + 2 * CardsContainerView.indent
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(reusable: SwipeableCardCell.self, for: indexPath)
        
        let view = viewsArray[indexPath.row]
        cell.addViewOnCell(subView: view, withShadow: true)
        cell.isSwipeEnable = view.canSwipe
        cell.cellDelegate = self
        
        return cell
    }
    
    func onCellDeleted(cell: UITableViewCell) {
        guard let path = tableView.indexPath(for: cell) else {
            return
        }
        
        viewsArray.remove(at: path.row)
        tableView.beginUpdates()
        tableView.deleteRows(at: [path], with: .automatic)
        tableView.endUpdates()
        updateH()
    }
    
    
    // MARK: WrapItemOperationViewProtocol
    
    private func checkIsThisIsPermittedType(type: OperationType) -> Bool {
        
        if !isEnable {
            return false
        }

        if notPermittedPopUpViewTypes.contains(type.rawValue){
            return false
        }
        
        if !permittedPopUpViewTypes.isEmpty {
            return permittedPopUpViewTypes.contains(type.rawValue)
        }
        
        return true
    }
    
    private func checkIsNeedShowPopUpFor(operationType: OperationType) -> Bool {
        switch operationType {
        case .prepareToAutoSync:
            return viewsByType[.sync] == nil
        default:
            return true
        }
    }
    
    func getViewForOperation(operation: OperationType) -> BaseCardView {
        return CardsManager.cardViewForOperaion(type: operation)
    }
    
    func configureInstaPick(with analysisStatus: InstapickAnalyzesCount) {
        ///DO NOT DELETE. This delegate method used in BaseCollectionViewDataSource
    }
    
    func startOperationWith(type: OperationType, allOperations: Int?, completedOperations: Int?) {
        startOperationWith(type: type, object: nil, allOperations: allOperations, completedOperations: completedOperations)
    }
    
    func startOperationWith(type: OperationType, object: WrapData?, allOperations: Int?, completedOperations: Int?) {
        ///TODO: remove 'type == .instaPick' after (because of lines 227-229)
        if type == .premium || type == .instaPick {
            /// not let some cards appear anywhere else than in HomePage
            return
        }
        
        if !checkIsThisIsPermittedType(type: type) {
            return
        }
        
        if !checkIsNeedShowPopUpFor(operationType: type) {
            return
        }
        
        if viewsByType[type] == nil {
            
            let view = getViewForOperation(operation: type)
            
            if type == .sync || type == .upload || type == .prepareToAutoSync {
                view.shouldScrollToTop = true
            }
            
            viewsByType[type] = view
            if let popUp = view as? ProgressCard {
                popUp.setProgress(allItems: allOperations, readyItems: completedOperations)
                if let item = object {
                    popUp.setImageForUploadingItem(item: item)
                }
            }
            addPopUpSubView(popUp: view)
            
        }
    }
    
    func startOperationsWith(serverObjects: [HomeCardResponse]) {
        
    }
    
    func setProgressForOperationWith(type: OperationType, object: WrapData?, allOperations: Int, completedOperations: Int ) {
        if let view = viewsByType[type] {
            if let popUp = view as? ProgressCard {
                popUp.setProgress(allItems: allOperations, readyItems: completedOperations)
                if let item = object {
                    popUp.setImageForUploadingItem(item: item)
                }
            }
        } else {
            startOperationWith(type: type, allOperations: allOperations, completedOperations: completedOperations)
        }
    }
    
    func setProgress(ratio: Float, for operationType: OperationType, object: WrapData? ) {
        guard isActive else {
            return
        }
        guard let popUp = viewsByType[operationType] as? ProgressCard else {
            return
        }
        
        popUp.setProgressBar(ratio: ratio)
        if let `object` = object {
            popUp.setImageForUploadingItem(item: object)
        }
    }
    
    func stopOperationWithType(type: OperationType) {
        if let view = viewsByType[type] {
            viewsByType[type] = nil
            deletePopUpSubView(popUp: view)
        }
    }
    
    func stopOperationWithType(type: OperationType, serverObject: HomeCardResponse) {
        stopOperationWithType(type: type)
    }
    
    func isEqual(object: CardsManagerViewProtocol) -> Bool {
        if let compairedView = object as? CardsContainerView {
            return compairedView == self
        }
        return false
    }
    
    func addNotPermittedCardViewTypes(types: [OperationType]) {
        let array = types.map { $0.rawValue }
        for operationName in array {
            notPermittedPopUpViewTypes.insert(operationName)
        }
    }
    
    func addPermittedPopUpViewTypes(types: [OperationType]) {
        let array = types.map { $0.rawValue }
        for operationName in array {
            permittedPopUpViewTypes.insert(operationName)
        }
    }
    
}
