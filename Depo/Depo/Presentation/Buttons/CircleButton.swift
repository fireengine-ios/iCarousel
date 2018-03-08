//
//  CircleButton.swift
//  Depo
//
//  Created by Oleg on 22.06.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class CircleButton: UIButton {
    
    weak var bottomTitleLabel: UILabel?
    var titleString: String = ""

    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentMode = .scaleAspectFit
        let label = UILabel(frame: CGRect(x: 0.0, y: frame.size.height - 25.0, width: frame.size.width, height: 18.0))
        addSubview(label)
        bottomTitleLabel = label
        let topSpace = getSpaceBetwinImageAndLabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        var constraints = [NSLayoutConstraint]()
        constraints.append(NSLayoutConstraint(item: label, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: label, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: label, attribute: .top, relatedBy: .equal, toItem: imageView, attribute: .bottom, multiplier: 1, constant: topSpace))
        constraints.append(NSLayoutConstraint(item: label, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: label.frame.size.height))
        
        NSLayoutConstraint.activate(constraints)
        
        setTitle("", for: .normal)
        configurate()
    }
    
    func configurate() {
        bottomTitleLabel?.textAlignment = .center
        bottomTitleLabel?.textColor = ColorConstants.textGrayColor
        bottomTitleLabel?.minimumScaleFactor = 0.5
        bottomTitleLabel?.adjustsFontSizeToFitWidth = true
        bottomTitleLabel?.numberOfLines = 0
        var fontSize: CGFloat = 13.0
        if (Device.isIpad) {
            fontSize = 16.0
        }
        bottomTitleLabel?.font = UIFont.TurkcellSaturaRegFont(size: fontSize)
        bottomTitleLabel?.text = titleString
    }
    
    func setBottomTitleText(titleText: String) {
        titleString = titleText
        bottomTitleLabel?.text = titleString
    }
    
    func getSpaceBetwinImageAndLabel() -> CGFloat {
        var space: CGFloat = 7
        if (Device.isIpad) {
            space = 15
        }
        return space
    }

}
