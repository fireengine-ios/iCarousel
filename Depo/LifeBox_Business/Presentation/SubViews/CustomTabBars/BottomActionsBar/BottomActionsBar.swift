//
//  BottomActionsBar.swift
//  Depo
//
//  Created by Konstantin Studilin on 11.03.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

enum BottomActionsBarStyle {
    case opaque
    case transparent
}

enum BottomBarActionType: Int {
    case share = 0
    case privateShare
    case info
    case delete
    case move
    case download
    case downloadDocument
    case restore
    case more
    
    var image: UIImage? {
        let imageName: String
        switch self {
            case .share: imageName = "moveBottom"
            case .privateShare: imageName = "shareBottom"
            case .info: imageName = "infoBottom"
            case .delete: imageName = "trashBottom"
            case .move: imageName = "moveBottom"
            case .download: imageName = "downloadBottom"
            case .downloadDocument: imageName = "downloadBottom"
            case .restore: imageName = "RestoreButtonIcon"
            case .more: imageName = "moreBottom"
        }
        
        return UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
    }
    
    var title: String {
        switch self {
            case .share: return TextConstants.tabBarShareLabel
            case .privateShare: return TextConstants.tabBarSharePrivatelyLabel
            case .info: return TextConstants.tabBarInfoLabel
            case .delete: return TextConstants.tabBarDeleteLabel
            case .move: return TextConstants.tabBarMoveLabel
            case .download: return TextConstants.tabBarDownloadLabel
            case .downloadDocument: return TextConstants.tabBarDownloadLabel
            case .restore: return TextConstants.actionSheetRestore
            case .more: return TextConstants.actionSheetMore
        }
    }
    
    static func from(type: ElementTypes) -> Self? {
        switch type {
            case .share:
                return .share
            case .privateShare:
                return .privateShare
            case .info:
                return .info
            case .delete, .moveToTrash, .moveToTrashShared:
                return .delete
            case .move:
                return .move
            case .download:
                return .download
            case .downloadDocument:
                return .downloadDocument
            case .restore:
                return .restore
            default:
                return nil
        }
    }
    
    var toElementType: ElementTypes {
        switch self {
            case .share:
                return .share
            case .privateShare:
                return .privateShare
            case .info:
                return .info
            case .delete:
                return .delete
            case .move:
                return .move
            case .download:
                return .download
            case .downloadDocument:
                return .downloadDocument
            case .restore:
                return .restore
            case .more:
                return .more
        }
    }
}

protocol BottomActionsBarDelegate: class {
    func onSelected(action: BottomBarActionType)
    func onMoreButton(actions: [BottomBarActionType], sender: UIButton)
}

final class BottomActionsBar: UIView {
    
    private let buttonsBeforeMoreButton = 5

    private lazy var actionButtonsStack: UIStackView = {
        let newValue = UIStackView()
        newValue.axis = .horizontal
        newValue.alignment = .fill
        newValue.distribution = .fillEqually
        newValue.translatesAutoresizingMaskIntoConstraints = false
        return newValue
    }()
    
    weak var delegate: BottomActionsBarDelegate?
    private lazy var animator = BottomActionsBarAnimator(barView: self)

    private(set) var style: BottomActionsBarStyle = .opaque
    private var actionsUnderMoreButton = [BottomBarActionType]()
    
    
    //MARK: Override
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupButonsStack()
        setupShadow()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupButonsStack()
        setupShadow()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateShadowLayer()
    }
    
    
    //MARK: Public
    
    func setup(style: BottomActionsBarStyle, elementTypes: [ElementTypes]) {
        self.style = style
        actionsUnderMoreButton = []
        
        DispatchQueue.main.async {
            switch style {
                case .opaque:
                    self.backgroundColor = .white
                    
                case .transparent:
                    self.backgroundColor = .clear
            }
            
            self.setupShadow()
            self.addButtons(for: elementTypes.compactMap { BottomBarActionType.from(type: $0) })
            
            self.layoutIfNeeded()
        }
    }
    
    func show(onSourceView: UIView, animated: Bool) {
        animator.show(onSourceView: onSourceView, animated: animated)
    }
    
    func hide(animated: Bool) {
        animator.hide( animated: animated)
    }
    
    //MARK: Shadow
    
    private func setupShadow() {
        updateShadowLayer()
        layer.shadowRadius = 4
        layer.shadowOpacity = (style == .opaque) ? 0.2 : 0
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 5.0)
    }
    
    private func updateShadowLayer() {
        let shadowPath = UIBezierPath(rect: bounds)
        layer.shadowPath = shadowPath.cgPath
    }
    
    //MARK: Buttons
    
    private func setupButonsStack() {
        addSubview(actionButtonsStack)
        actionButtonsStack.pinToSuperviewEdges()
    }
    
    private func addButtons(for actionTypes: [BottomBarActionType]) {
        guard !actionTypes.isEmpty else {
            return
        }
        
        actionButtonsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if actionTypes.count < buttonsBeforeMoreButton {
            actionTypes.forEach { actionType in
                let button = createButton(type: actionType)
                actionButtonsStack.addArrangedSubview(button)
            }
        } else {
            let mainTypes = Array(actionTypes.prefix(upTo: buttonsBeforeMoreButton - 2))
            let coveredTypes = Array(actionTypes.suffix(from: mainTypes.count))
            actionsUnderMoreButton = coveredTypes
            
            mainTypes.forEach { actionType in
                let button = createButton(type: actionType)
                actionButtonsStack.addArrangedSubview(button)
            }
            
            let menuButton = createMenuButton(actions: coveredTypes)
            actionButtonsStack.addArrangedSubview(menuButton)
        }
    }
    
    private func createButton(type: BottomBarActionType) -> UIButton {
        let tintColor = (style == .opaque) ? ColorConstants.Text.labelTitle : .white
        
        let button = UIButton()
        button.addTarget(self, action: #selector(onButtonTap(_:)), for: .touchUpInside)
        button.setImage(type.image, for: .normal)
        button.setTitle(type.title, for: .normal)
        button.setTitleColor(tintColor, for: .normal)
        button.tintColor = tintColor
        button.titleLabel?.font = .GTAmericaStandardRegularFont(size: 10)
        button.adjustsFontSizeToFitWidth()
        button.centerVertically(padding: 8)
        button.tag = type.rawValue
        return button
    }
    
    private func createMenuButton(actions: [BottomBarActionType]) -> UIButton {
        let button = createButton(type: .more)
        
        button.removeTarget(self, action: #selector(onButtonTap(_:)), for: .touchUpInside)
        
        if #available(iOS 14, *) {
            button.showsMenuAsPrimaryAction = true
            button.menu = MenuItemsFabric.createMenu(bottomBarActions: actions, actionHandler: { [weak self] actionType in
                self?.delegate?.onSelected(action: actionType)
            })
        } else {
            button.addTarget(self, action: #selector(onMenuButtonTap(_:)), for: .touchUpInside)
        }
        
        return button
    }
    
    @objc
    private func onButtonTap(_ sender: UIButton) {
        guard let actionType = BottomBarActionType.init(rawValue: sender.tag) else {
            return
        }
        
        delegate?.onSelected(action: actionType)
    }
    
    @objc
    private func onMenuButtonTap(_ sender: UIButton) {
        delegate?.onMoreButton(actions: actionsUnderMoreButton, sender: sender)
    }
}
