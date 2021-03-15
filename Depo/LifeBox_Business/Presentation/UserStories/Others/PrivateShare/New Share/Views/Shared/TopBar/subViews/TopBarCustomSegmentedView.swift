//
//  TopBarCustomSegmentedView.swift
//  Depo
//
//  Created by Alex Developer on 15.03.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

struct TopBarCustomSegmentedViewButtonModel {
    let title: String
    let callback: VoidHandler
}

final class TopBarCustomSegmentedView: UIView, NibInit {
    
    
    @IBOutlet weak var stackView: UIStackView!
    
    
    @IBOutlet weak var highlightView: UIView!
    
    private var buttons = [UIButton]()
    
    private var models = [TopBarCustomSegmentedViewButtonModel]()
    
    func setup(models: [TopBarCustomSegmentedViewButtonModel]) {
        self.models = models
        buttons.removeAll()
        for (i, model) in models.enumerated() {
            let button = createButton(models: model, tag: i)
            buttons.append(button)
            stackView.addSubview(button)
        }
        backgroundColor = .black
        stackView.backgroundColor = .blue
    }
    
    private func setupHighlightView() {
        
    }
    
    private func createButton(models: TopBarCustomSegmentedViewButtonModel, tag: Int) -> UIButton {
        let button = UIButton(type: .custom)
        
        button.setTitle(models.title, for: .normal)
        button.titleLabel?.font = UIFont.GTAmericaStandardMediumFont(size: 14)
        button.setTitleColor(ColorConstants.confirmationPopupTitle, for: .normal)
        
        button.tag = tag
        
        button.backgroundColor = ColorConstants.blueGreen//topBarColor
        button.layer.masksToBounds = true
        
        button.addTarget(self, action: #selector(buttonAction),
                         for: UIControlEvents.touchUpInside)
        
        return button
    }
    
    @objc private func buttonAction(_ sender: UIButton?) {
        
        guard
            let button = sender,
            button.tag < models.count
        else {
            assertionFailure("button or tag is invalid")
            return
        }
        
        debugPrint("!!! button tag is \(button.tag)")
        
        models[button.tag].callback()
    }
    
}
