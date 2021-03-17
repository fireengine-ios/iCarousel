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
    
    @IBOutlet weak var separartorView: UIView! {
        willSet {
            newValue.backgroundColor = ColorConstants.infoPageSeparator
        }
    }
    
    @IBOutlet private weak var stackView: UIStackView! {
        willSet {
            newValue.backgroundColor = .blue
            
            newValue.distribution = .fillEqually
        }
    }
    
    
    private var highlightView: UIView = {
       let view = UIView()
        view.backgroundColor = ColorConstants.confirmationPopupTitle
        view.isHidden = true
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private var buttons = [UIButton]()
    
    private var models = [TopBarCustomSegmentedViewButtonModel]()
    
    private var selectedIndex: Int = 0
    
//    private var highlightViewBotConstraint
    private var highlightViewLeaningConstraint: NSLayoutConstraint?
//    private var highlightViewTrailingConstraint: NSLayoutConstraint?
    
    func setup(models: [TopBarCustomSegmentedViewButtonModel], selectedIndex: Int) {
        guard
            !models.isEmpty,
            selectedIndex < models.count
        else {
            assertionFailure()
            return
        }
        self.selectedIndex = selectedIndex
        self.models = models
        buttons.removeAll()
        
        for (i, model) in models.enumerated() {
            let button = createButton(models: model, tag: i)
            buttons.append(button)
            stackView.addArrangedSubview(button)
        }
        
       
        
        setupHighlightView()
        updateHighlightView()
    }
    
    private func setupHighlightView() {
        
        addSubview(highlightView)
//        stackView.addSubview(highlightView)
        highlightView.isHidden =  false
        
        guard
            !buttons.isEmpty,
            selectedIndex < buttons.count,
            let selectedButton = buttons[safe: selectedIndex]
        else {
            assertionFailure()
            return
        }
        
        highlightView.translatesAutoresizingMaskIntoConstraints = false
        
        highlightView.heightAnchor.constraint(equalToConstant: 4).activate()
        
        highlightView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).activate()
        
        highlightView.widthAnchor.constraint(equalTo: selectedButton.widthAnchor, constant: 0).activate()
//        NSLayoutConstraint(item: highlightView, attribute: .width, relatedBy: .equal, toItem: selectedButton, attribute: .width, multiplier: 1, constant: 0).activate()
        
    }
    
    private func updateHighlightView(animated: Bool = false) {
        guard
            !buttons.isEmpty,
            selectedIndex < buttons.count,
            let selectedButton = buttons[safe: selectedIndex]
        else {
            assertionFailure()
            return
        }
        
        if let highlightViewLeaningConstraint = highlightViewLeaningConstraint {
//            stackView
            removeConstraint(highlightViewLeaningConstraint)
            self.highlightViewLeaningConstraint = nil
        }
        
        
        highlightViewLeaningConstraint = highlightView.leadingAnchor.constraint(equalTo: selectedButton.leadingAnchor, constant: 0)
        highlightViewLeaningConstraint?.activate()
        
        
        UIView.animate(withDuration: 0.1, animations: {
            self.layoutIfNeeded()
        })
        
    }
    
    private func createButton(models: TopBarCustomSegmentedViewButtonModel, tag: Int) -> UIButton {
        let button = UIButton(type: .custom)
        
        button.setTitle(models.title, for: .normal)
        button.titleLabel?.font = UIFont.GTAmericaStandardMediumFont(size: 14)
        button.setTitleColor(ColorConstants.confirmationPopupTitle, for: .normal)
        
        button.tag = tag
        
        button.backgroundColor = ColorConstants.topBarColor
        
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
        
        selectedIndex = button.tag
        
        updateHighlightView()
        
        models[safe: button.tag]?.callback()
    }
    
}
