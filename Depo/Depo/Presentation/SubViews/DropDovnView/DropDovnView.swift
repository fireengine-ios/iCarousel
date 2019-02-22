//
//  DropDovnView.swift
//  Depo
//
//  Created by Oleg on 04.09.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

@objc protocol DropDovnViewDelegate {
    @objc optional func onWillShow()
    @objc optional func onDidShow()
    @objc optional func onWillHide()
    @objc optional func onDidHide()
    func onSelectItem(atIndex index: Int)
}

class DropDovnView: UIView, UITableViewDataSource, UITableViewDelegate {
    
    private var tableView: UITableView?
    private var titleLabel: UILabel?
    private var dropDovnImage: UIImageView?
    private var dropDovnButton: UIButton?
    private var cornerView: UIView?
    private var bgView: UIView?
    private var constraint: NSLayoutConstraint?
    private var originTableViewH: CGFloat = 0
    
    var tableDataArray = [String]()
    var maxTableViewH: CGFloat = 100
    var selectedString: String?
    
    weak var delegate: DropDovnViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.clipsToBounds = false
        
        layer.cornerRadius = 4
        
        backgroundColor = ColorConstants.switcherGrayColor
        cornerView = UIView(frame: CGRect(x: 1, y: 1, width: frame.size.width - 2, height: frame.size.height - 2))
        cornerView!.translatesAutoresizingMaskIntoConstraints = false
        cornerView!.backgroundColor = ColorConstants.switcherGrayColor
        cornerView!.layer.cornerRadius = 4
        
        addSubview(cornerView!)
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(NSLayoutConstraint(item: cornerView!, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: cornerView!, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: cornerView!, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0))
        constraint = NSLayoutConstraint(item: cornerView!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: frame.size.height)
        
        
        bgView = UIView(frame: CGRect(x: 1, y: 1, width: frame.size.width - 2, height: frame.size.height - 2))
        bgView!.translatesAutoresizingMaskIntoConstraints = false
        bgView!.backgroundColor = ColorConstants.whiteColor
        bgView!.layer.cornerRadius = 4
        
        cornerView!.addSubview(bgView!)
        
        constraints.append(NSLayoutConstraint(item: bgView!, attribute: .left, relatedBy: .equal, toItem: cornerView!, attribute: .left, multiplier: 1, constant: 1))
        constraints.append(NSLayoutConstraint(item: bgView!, attribute: .top, relatedBy: .equal, toItem: cornerView!, attribute: .top, multiplier: 1, constant: 1))
        constraints.append(NSLayoutConstraint(item: bgView!, attribute: .right, relatedBy: .equal, toItem: cornerView!, attribute: .right, multiplier: 1, constant: -1))
        constraints.append(NSLayoutConstraint(item: bgView!, attribute: .bottom, relatedBy: .equal, toItem: cornerView!, attribute: .bottom, multiplier: 1, constant: -1))
        
        
        titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: cornerView!.frame.size.width - 25, height: cornerView!.frame.size.height))
        titleLabel!.font = UIFont.TurkcellSaturaRegFont(size: 14)
        titleLabel!.textColor = ColorConstants.darkBlueColor
        titleLabel!.textAlignment = .left
        titleLabel!.backgroundColor = UIColor.clear
        titleLabel!.translatesAutoresizingMaskIntoConstraints = false
        titleLabel!.text = TextConstants.feedbackViewSelect
        
        bgView!.addSubview(titleLabel!)
        constraints.append(NSLayoutConstraint(item: titleLabel!, attribute: .left, relatedBy: .equal, toItem: bgView!, attribute: .left, multiplier: 1, constant: 12))
        constraints.append(NSLayoutConstraint(item: titleLabel!, attribute: .top, relatedBy: .equal, toItem: bgView!, attribute: .top, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: titleLabel!, attribute: .right, relatedBy: .equal, toItem: bgView!, attribute: .right, multiplier: 1, constant: -25))
        constraints.append(NSLayoutConstraint(item: titleLabel!, attribute: .bottom, relatedBy: .equal, toItem: bgView!, attribute: .bottom, multiplier: 1, constant: 0))
        
        dropDovnImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 8, height: 5))
        dropDovnImage!.image = UIImage(named: "dropDownArrow")
        dropDovnImage?.translatesAutoresizingMaskIntoConstraints = false
        bgView!.addSubview(dropDovnImage!)
        
        constraints.append(NSLayoutConstraint(item: dropDovnImage!, attribute: .right, relatedBy: .equal, toItem: bgView!, attribute: .right, multiplier: 1, constant: -13))
        constraints.append(NSLayoutConstraint(item: dropDovnImage!, attribute: .centerY, relatedBy: .equal, toItem: bgView!, attribute: .centerY, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: dropDovnImage!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 5))
        constraints.append(NSLayoutConstraint(item: dropDovnImage!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 8))
        
        
        dropDovnButton = UIButton(frame: CGRect(x: 0, y: 0, width: bgView!.frame.size.width, height: bgView!.frame.size.height))
        dropDovnButton!.addTarget(self, action: #selector(onDropDovnButton), for: .touchUpInside)
        dropDovnButton!.translatesAutoresizingMaskIntoConstraints = false
        bgView!.addSubview(dropDovnButton!)
        
        constraints.append(NSLayoutConstraint(item: dropDovnButton!, attribute: .left, relatedBy: .equal, toItem: bgView!, attribute: .left, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: dropDovnButton!, attribute: .top, relatedBy: .equal, toItem: bgView!, attribute: .top, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: dropDovnButton!, attribute: .right, relatedBy: .equal, toItem: bgView!, attribute: .right, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: dropDovnButton!, attribute: .bottom, relatedBy: .equal, toItem: bgView!, attribute: .bottom, multiplier: 1, constant: 0))
        
        let cornerFrame = CGRect(x: 1, y: 1, width: bgView!.frame.size.width - 2, height: cornerView!.frame.size.height - 1)
        tableView = UITableView(frame: cornerFrame, style: .plain)
        tableView!.layer.cornerRadius = 4
        tableView!.delegate = self
        tableView!.dataSource = self
        tableView!.translatesAutoresizingMaskIntoConstraints = false
        tableView!.separatorStyle = .none
        bgView!.addSubview(tableView!)
        
        constraints.append(NSLayoutConstraint(item: tableView!, attribute: .left, relatedBy: .equal, toItem: bgView!, attribute: .left, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: tableView!, attribute: .top, relatedBy: .equal, toItem: bgView!, attribute: .top, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: tableView!, attribute: .right, relatedBy: .equal, toItem: bgView!, attribute: .right, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: tableView!, attribute: .bottom, relatedBy: .equal, toItem: bgView!, attribute: .bottom, multiplier: 1, constant: 0))
        
        constraints.append(constraint!)
        
        let nib = UINib.init(nibName: CellsIdConstants.dropDovnCellID, bundle: nil)
        tableView!.register(nib, forCellReuseIdentifier: CellsIdConstants.dropDovnCellID)
        tableView!.isHidden = true
        tableView!.reloadData()
        
        NSLayoutConstraint.activate(constraints)
        
    }

    func setTableDataObjects(objects: [String], defaultObject: String?) {
        tableDataArray.removeAll()
        tableDataArray.append(contentsOf: objects)        
        if let defaultObject = defaultObject {
            titleLabel?.text = defaultObject
        }
        tableView?.reloadData()
    }
    
    @objc private func onDropDovnButton() {
        if let supView = superview {
            supView.bringSubview(toFront: self)
        }
        onShowTable(show: true)
    }
    
    func hideViewIfNeeded() {
        if let shown = tableView?.isHidden, !shown {
            onShowTable(show: false)
        }
    }
    
    private func onShowTable(show: Bool) {
        if (show) {
            originTableViewH = self.constraint!.constant
        }
        
        tableView!.isHidden = false
        let h = show ? self.maxTableViewH : self.originTableViewH
        
        if show {
            delegate?.onWillShow?()
        } else {
            delegate?.onWillHide?()
        }
        
        UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
            self.constraint!.constant = h
            self.cornerView!.setNeedsUpdateConstraints()
        }) { [weak self] flag in
            self?.tableView!.isHidden = !show
            if show {
                self?.delegate?.onDidShow?()
            } else {
                self?.delegate?.onDidHide?()
            }
        }
        
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        if clipsToBounds || isHidden || alpha == 0 {
            return nil
        }
        
        for subview in subviews.reversed() {
            let subPoint = subview.convert(point, from: self)
            if let result = subview.hitTest(subPoint, with: event) {
                return result
            }
        }
        
        return nil
    }
    
    
    // MARK: UITableView delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableDataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 32
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellsIdConstants.dropDovnCellID, for: indexPath)
        let string = tableDataArray[indexPath.row]
        guard let cell_ = cell as? DropDovnTableViewCell else {
            return cell
        }
        cell_.titleTextLabel!.text = string
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let string = tableDataArray[indexPath.row]
        titleLabel!.text = string
        selectedString = string
        tableView.deselectRow(at: indexPath, animated: false)
        onShowTable(show: false)
        
        delegate?.onSelectItem(atIndex: indexPath.row)
    }
    
}
