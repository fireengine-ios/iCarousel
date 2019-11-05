//
//  PopUpSwipeCell.swift
//  Depo_LifeTech
//
//  Created by Oleg on 19.09.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

protocol PopUpSwipeCellDelegate {
    func onCellDeleted(cell: UITableViewCell)
}

class PopUpSwipeCell: UITableViewCell {

    private var startX: CGFloat = 0.0
    private var isTouch = false
    var isSwipeEnable = true
    
    var cellDelegate: PopUpSwipeCellDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        isMultipleTouchEnabled = false
        clipsToBounds = false
        
        configurateView()
    }
    
    func configurateView() {
        
    }
    
    func addViewOnCell(subView: UIView, withShadow: Bool) {
        for view in self.contentView.subviews {
            view.removeFromSuperview()
        }
        
        if let baseView = subView as? BaseView {
            isSwipeEnable = baseView.canSwipe
        }
        
        subView.frame = CGRect(x: ViewForPopUp.indent, y: ViewForPopUp.indent, width: frame.size.width - 2 * ViewForPopUp.indent, height: subView.frame.size.height)
        
        if (withShadow) {
            if (contentView.layer.sublayers != nil) {
                for l in contentView.layer.sublayers! {
                    l.removeFromSuperlayer()
                }
            }
            
            subView.layer.cornerRadius = BaseView.baseViewCornerRadius
            subView.clipsToBounds = true
            
            let layer = CALayer()
            layer.frame = CGRect(x: ViewForPopUp.indent, y: ViewForPopUp.indent, width: frame.size.width - 2 * ViewForPopUp.indent, height: subView.frame.size.height)
            
            layer.shadowColor = UIColor.lightGray.cgColor
            layer.shadowOpacity = 1
            layer.shadowOffset = CGSize.zero
            layer.shadowRadius = 3
            layer.shadowPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: layer.frame.size.width, height: layer.frame.size.height)).cgPath
            layer.shouldRasterize = true
            layer.cornerRadius = BaseView.baseViewCornerRadius
            
            contentView.layer.addSublayer(layer)
        }
        
        
        DispatchQueue.main.async {
            self.contentView.addSubview(subView)
        }
    }
    
    // MARK: update state to default
    func setStateToDefault() {
        contentView.frame = CGRect(x: 0.0, y: 0.0, width: frame.size.width, height: frame.size.height)
    }
    
    // MARK : touches
    private func getXforTouch(_ touches: Set<UITouch>) -> CGFloat {
        let touch = touches.first
        let location = touch!.location(in: self)
        superview?.bringSubview(toFront: self)
        return location.x
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if (!isSwipeEnable) {
            return
        }
        isTouch = true
        startX = getXforTouch(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        if (!isSwipeEnable) {
            return
        }
        let x = startX - getXforTouch(touches)
        
        contentView.frame = CGRect(x: -x, y: contentView.frame.origin.y, width: contentView.frame.size.width, height: contentView.frame.size.height)
    }
    
    private func calculateEnd(_ touches: Set<UITouch>) {
        let x = startX - getXforTouch(touches)
        var endX: CGFloat = 0
        var needDeleteCell = false
        if (abs(x) > frame.size.width * 0.3) {
            if (x < 0) {
                endX = frame.size.width
            } else {
                endX = -frame.size.width
            }
            needDeleteCell = true
        }
        
        UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
            self.contentView.frame = CGRect(x: endX, y: self.contentView.frame.origin.y, width: self.contentView.frame.size.width, height: self.contentView.frame.size.height)
        }) { animate in
            self.isTouch = false
            if (needDeleteCell) {
                for view in self.contentView.subviews {
                    if let baseView = view as? BaseView {
                        baseView.viewDeletedBySwipe()
                    }
                }
//                self.cellDelegate?.onCellDeleted(cell: self)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if (!isSwipeEnable) {
            return
        }
        calculateEnd(touches)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        if (!isSwipeEnable) {
            return
        }
        calculateEnd(touches)
    }
    
}
