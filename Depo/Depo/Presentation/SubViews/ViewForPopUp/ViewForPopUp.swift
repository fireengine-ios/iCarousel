//
//  ViewForPopUp.swift
//  Depo_LifeTech
//
//  Created by Oleg on 19.09.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

@objc protocol ViewForPopUpDelegate{
    func onUpdateViewForPopUpH(h: CGFloat)
}

class ViewForPopUp: UIView, UITableViewDelegate, UITableViewDataSource, PopUpSwipeCellDelegate, WrapItemOperationViewProtocol {

    var hConstraint: NSLayoutConstraint? = nil
    weak var delegate: ViewForPopUpDelegate? = nil
    
    var tableView: UITableView = UITableView()
    var viewsArray = [BaseView]()
    var notPermittedPopUpViewTypes = Set<String>()
    var isEnable: Bool = true
    
    var viewsByType = [OperationType: BaseView]()
    
    static let indent: CGFloat = 10
    
    let lock = NSLock()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configurate()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configurate()
    }
    
    func configurate(){
        tableView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tableView)
        var constraints = [NSLayoutConstraint]()
        constraints.append(NSLayoutConstraint(item: tableView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: tableView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: tableView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: tableView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
        NSLayoutConstraint.activate(constraints)
        
        tableView.register(nibCell: PopUpSwipeCell.self)
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
    }
    
    func setHConstraint(hConstraint: NSLayoutConstraint){
        self.hConstraint = hConstraint
    }

    func addPopUpSubView(popUp: BaseView){
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
    
    func deletePopUpSubView(popUp: BaseView){
        DispatchQueue.main.async {
            if let index = self.viewsArray.index(of: popUp){
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
    
    private func addShadowForView(subView: UIView){
        
        subView.layer.cornerRadius = BaseView.baseViewCornerRadius
        subView.clipsToBounds = false
        
        let layer = CALayer()
        layer.frame = CGRect(x: 0 , y: 0 , width: subView.layer.frame.size.width , height: subView.layer.frame.size.height )
        
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = 3
        layer.shadowPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: layer.frame.size.width, height: layer.frame.size.height)).cgPath
        layer.shouldRasterize = true
        layer.cornerRadius = BaseView.baseViewCornerRadius
        
        subView.layer.addSublayer(layer)
        subView.layer.insertSublayer(layer, at: 0)
    }
    
    private func updateH(){
        if hConstraint != nil {
            let h = calulateCurrentH()
            UIView.animate(withDuration: NumericConstants.animationDuration) {
                self.hConstraint?.constant = h
                self.superview?.layoutIfNeeded()
            }
        }
        if let delegate_ = delegate{
            delegate_.onUpdateViewForPopUpH(h: calulateCurrentH())
        }
    }
    
    private func calulateCurrentH() -> CGFloat {
        var h: CGFloat = 0
        for view in viewsArray {
            h = h + view.frame.size.height + 2 * ViewForPopUp.indent
        }
        return h
    }
    
    //MARK: UITableView delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewsArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let view = viewsArray[indexPath.row]
        return view.frame.size.height + 2 * ViewForPopUp.indent
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(reusable: PopUpSwipeCell.self, for: indexPath)
        
        let view = viewsArray[indexPath.row]
        cell.addViewOnCell(subView: view, withShadow: true)
        cell.isSwipeEnable = view.canSwipe
        cell.cellDelegate = self
        
        return cell
    }
    
    func onCellDeleted(cell: UITableViewCell){
        guard let path = tableView.indexPath(for: cell) else {
            return
        }
        
        viewsArray.remove(at: path.row)
        tableView.beginUpdates()
        tableView.deleteRows(at: [path], with: .automatic)
        tableView.endUpdates()
        updateH()
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
        return WrapItemOperatonManager.popUpViewForOperaion(type: operation)
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
            viewsByType[type] = view
            if let popUp = view as? ProgressPopUp {
                popUp.setProgress(allItems: allOperations, readyItems: completedOperations)
                if let item = object{
                    popUp.setImageForUploadingItem(item: item)
                }
            }
            addPopUpSubView(popUp: view)
            
        }
    }
    
    func setProgressForOperationWith(type: OperationType, allOperations: Int, completedOperations: Int ){
        setProgressForOperationWith(type: type, object: nil, allOperations: allOperations, completedOperations: completedOperations)
    }
    
    func setProgressForOperationWith(type: OperationType, object: WrapData?, allOperations: Int, completedOperations: Int ){
        if let view = viewsByType[type] {
            if let popUp = view as? ProgressPopUp {
                popUp.setProgress(allItems: allOperations, readyItems: completedOperations)
                if let item = object{
                    popUp.setImageForUploadingItem(item: item)
                }
            }
        }else{
            startOperationWith(type: type, allOperations: allOperations, completedOperations: completedOperations)
        }
    }
    
    func setProgress(ratio: Float, for operationType: OperationType ) {
        guard let popUp = viewsByType[operationType] as? ProgressPopUp else {
            return
        }
        
        popUp.setProgressBar(ratio: ratio)
    }
    
    func stopOperationWithType(type: OperationType){
        if let view = viewsByType[type] {
            viewsByType[type] = nil
            deletePopUpSubView(popUp: view)
        }
    }
    
    func isEqual(object: WrapItemOperationViewProtocol) -> Bool{
        if let compairedView = object as? ViewForPopUp{
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
