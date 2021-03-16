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
    
    var image: UIImage? {
        let imageName: String
        switch self {
            case .share: imageName = "share-copy"
            case .privateShare: imageName = "share-private"
            case .info: imageName = "InfoButtonIcon"
            case .delete: imageName = "DeleteShareButton"
            case .move: imageName = "MoveButtonIcon"
            case .download: imageName = "downloadTB"
            case .downloadDocument: imageName = "downloadTB"
            case .restore: imageName = "RestoreButtonIcon"
        }
        
        return UIImage(named: imageName)
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
}

protocol BottomActionsBarDelegate: class {
    func onSelected(action: BottomBarActionType)
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
            //TODO:
        }
    }
    
    private func createButton(type: BottomBarActionType) -> UIButton {
        let textColor = (style == .opaque) ? ColorConstants.Text.labelTitle : .white
        
        let button = UIButton()
        button.addTarget(self, action: #selector(onButtonTap(_:)), for: .touchUpInside)
        button.setImage(type.image, for: .normal)
        button.setTitle(type.title, for: .normal)
        button.setTitleColor(textColor, for: .normal)
        button.titleLabel?.font = .GTAmericaStandardRegularFont(size: 10)
        button.adjustsFontSizeToFitWidth()
        button.centerVertically(padding: 8)
        button.tag = type.rawValue
        return button
    }
    
    @objc
    private func onButtonTap(_ sender: UIButton) {
        guard let actionType = BottomBarActionType.init(rawValue: sender.tag) else {
            return
        }
        
        delegate?.onSelected(action: actionType)
    }
}
