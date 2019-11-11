//
//  BaseCollectionViewCellWithSwipe.swift
//  Depo
//
//  Created by Oleg on 22.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

protocol BaseCollectionViewCellWithSwipeDelegate: class {
    func onCellDeleted(cell: UICollectionViewCell)
}

class BaseCollectionViewCellWithSwipe: UICollectionViewCell {
    
    private var startX: CGFloat = 0.0
    private var isTouch = false
    var isSwipeEnable = true
    
    weak var cellDelegate: BaseCollectionViewCellWithSwipeDelegate?
    

    override func awakeFromNib() {
        super.awakeFromNib()
        isMultipleTouchEnabled = false
        clipsToBounds = false
        
        configurateView()
    }
    
    func configurateView() {
        
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
                    if let baseView = view as? BaseCardView {
                        baseView.viewDeletedBySwipe()
                    }
                }
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
    
    // Base func
    func willDisplay() { }
    
    // Base func
    func didEndDisplay() { }

}
