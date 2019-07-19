//
//  DropDownView.swift
//  Depo
//
//  Created by Oleg on 04.09.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

@objc protocol DropDownViewDelegate {
    @objc optional func onWillShow()
    @objc optional func onDidShow()
    @objc optional func onWillHide()
    @objc optional func onDidHide()
    func onSelectItem(atIndex index: Int)
}

class DropDownView: UIView {
    
    private var tableView: UITableView?
    private var titleLabel: UILabel?
    private var dropDownImage: UIImageView?
    private var dropDownButton: UIButton?
    private var cornerView: UIView?
    private var bgView: UIView?
    private var constraint: NSLayoutConstraint?
    private var originTableViewH: CGFloat = 0
    
    var tableDataArray = [String]()
    var maxTableViewH: CGFloat = 100
    var selectedString: String?
    
    weak var delegate: DropDownViewDelegate?
    
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
        
        dropDownImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 8, height: 5))
        dropDownImage!.image = UIImage(named: "dropDownArrow")
        dropDownImage?.translatesAutoresizingMaskIntoConstraints = false
        bgView!.addSubview(dropDownImage!)
        
        constraints.append(NSLayoutConstraint(item: dropDownImage!, attribute: .right, relatedBy: .equal, toItem: bgView!, attribute: .right, multiplier: 1, constant: -13))
        constraints.append(NSLayoutConstraint(item: dropDownImage!, attribute: .centerY, relatedBy: .equal, toItem: bgView!, attribute: .centerY, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: dropDownImage!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 5))
        constraints.append(NSLayoutConstraint(item: dropDownImage!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 8))
        
        
        dropDownButton = UIButton(frame: CGRect(x: 0, y: 0, width: bgView!.frame.size.width, height: bgView!.frame.size.height))
        dropDownButton!.addTarget(self, action: #selector(onDropDownButton), for: .touchUpInside)
        dropDownButton!.translatesAutoresizingMaskIntoConstraints = false
        bgView!.addSubview(dropDownButton!)
        
        constraints.append(NSLayoutConstraint(item: dropDownButton!, attribute: .left, relatedBy: .equal, toItem: bgView!, attribute: .left, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: dropDownButton!, attribute: .top, relatedBy: .equal, toItem: bgView!, attribute: .top, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: dropDownButton!, attribute: .right, relatedBy: .equal, toItem: bgView!, attribute: .right, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: dropDownButton!, attribute: .bottom, relatedBy: .equal, toItem: bgView!, attribute: .bottom, multiplier: 1, constant: 0))
        
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
        
        let nib = UINib.init(nibName: CellsIdConstants.dropDownCellID, bundle: nil)
        tableView!.register(nib, forCellReuseIdentifier: CellsIdConstants.dropDownCellID)
        tableView!.isHidden = true
        tableView!.reloadData()
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func updateConstraintsForDropDownView() {
        var constraint = [NSLayoutConstraint]()
        constraint.append(NSLayoutConstraint(item: cornerView!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: cornerView!.frame.width))
        NSLayoutConstraint.activate(constraint)
    }

    func setTableDataObjects(objects: [String], defaultObject: String?) {
        tableDataArray.removeAll()
        tableDataArray.append(contentsOf: objects)        
        if let defaultObject = defaultObject {
            titleLabel?.text = defaultObject
        }
        tableView?.reloadData()
    }
    
    @objc private func onDropDownButton() {
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
    
    func containsPoint(_ point: CGPoint) -> Bool {
        return tableView?.frame.contains(point) == true
    }
}

// MARK: UITableViewDelegate

extension DropDownView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 32
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

// MARK: UITableViewDataSource

extension DropDownView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellsIdConstants.dropDownCellID, for: indexPath)
        
        guard indexPath.row < tableDataArray.count else { 
            return cell
        }
        let string = tableDataArray[indexPath.row]
        
        guard let cell_ = cell as? DropDownTableViewCell else {
            return cell
        }
        cell_.titleTextLabel!.text = string
        return cell
    }
}
