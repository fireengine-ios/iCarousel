//
//  CreateStorySelectionView.swift
//  Depo
//
//  Created by yilmaz edis on 5.11.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import UIKit

class CreateStorySelectionView: UIView {
    
    lazy var snackBarLabel: UILabel = {
       let view = UILabel()
        view.font = .appFont(.medium, size: 14)
        view.textColor = AppColor.label.color
        return view
    }()
    
    lazy var snackBarHeader: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 50).activate()
        view.backgroundColor = AppColor.background.color
        return view
    }()
    
    lazy var contentView: UIView = {
       let view = UIView()
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        snackBarHeader.addSubview(snackBarLabel)
        snackBarLabel.translatesAutoresizingMaskIntoConstraints = false
        snackBarLabel.pinToSuperviewEdges(offset: UIEdgeInsets(top: 13, left: 16, bottom: 13, right: 13))
        
        addSubview(snackBarHeader)
        snackBarHeader.translatesAutoresizingMaskIntoConstraints = false
        snackBarHeader.topAnchor.constraint(equalTo: topAnchor).activate()
        snackBarHeader.leadingAnchor.constraint(equalTo: leadingAnchor).activate()
        snackBarHeader.trailingAnchor.constraint(equalTo: trailingAnchor).activate()
        
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.topAnchor.constraint(equalTo: snackBarHeader.bottomAnchor).activate()
        contentView.leadingAnchor.constraint(equalTo: leadingAnchor).activate()
        contentView.trailingAnchor.constraint(equalTo: trailingAnchor).activate()
        contentView.bottomAnchor.constraint(equalTo: bottomAnchor).activate()
    }
}
