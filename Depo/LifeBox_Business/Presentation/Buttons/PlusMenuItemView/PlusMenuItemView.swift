//
//  PlusMenuItemView.swift
//  Depo
//
//  Created by Aleksandr on 6/21/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

enum FloatingButtonsType {
    case upload(type: UploadType)
    case newFolder(type: UploadType)
    case uploadFromLifebox
    case uploadFiles(type: UploadType)
    
    var title: String {
        switch self {
        case .upload:
            return TextConstants.upload
        case .uploadFiles:
            return TextConstants.uploadFiles
        case .uploadFromLifebox:
            return TextConstants.uploadFromLifebox
        case .newFolder:
            return TextConstants.newFolder
        }
    }
    
    var image: UIImage? {
        switch self {
        case .upload,
             .uploadFiles,
             .uploadFromLifebox:
            return UIImage(named: "Upload")
        case .newFolder:
            return UIImage(named: "NewFolder")
        }
    }
    
    var action: TabBarViewController.Action {
        switch self {
            case .upload(type: let uploadType):
                return .upload(type: uploadType)
            case .uploadFiles(type: let uploadType):
                return .uploadFiles(type: uploadType)
            case .uploadFromLifebox:
                return .uploadFromApp
            case .newFolder(type: let uploadType):
                return .createFolder(type: uploadType)
        }
    }
}

protocol PlusMenuItemViewDelegate: class {
    func selectPlusMenuItem(action: TabBarViewController.Action)
}

final class PlusMenuItemView: UIView, NibInit {
    
    static func with(type: FloatingButtonsType, delegate: PlusMenuItemViewDelegate?) -> PlusMenuItemView {
        let view = PlusMenuItemView.initFromNib()
        view.setup(with: type)
        view.actionDelegate = delegate
        view.changeVisability(toHidden: true)
        return view
    }
    
    @IBOutlet weak var adjustedLabel: UILabel! {
        willSet {
            newValue.textColor = .white
            newValue.font = .TurkcellSaturaDemFont(size: 14)
        }
    }
    @IBOutlet weak var button: UIButton! {
        willSet {
            newValue.accessibilityTraits = UIAccessibilityTraitButton
        }
    }
    
    private let bottomConstraintOriginalConstant = -(UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0)
    private let height: CGFloat = 65
    private let width: CGFloat = 80
    
    private var type: FloatingButtonsType = .upload(type: .regular)
    weak var actionDelegate: PlusMenuItemViewDelegate?
    
    private var bottomConstraint: NSLayoutConstraint?
    private var centerXConstraint: NSLayoutConstraint?
    
    //MARK: -
    
    func setup(with type: FloatingButtonsType) {
        self.type = type
        adjustedLabel.text = type.title
        button.accessibilityLabel = type.title
        button.setImage(type.image, for: .normal)
    }
    
    func add(to contentView: UIView) {
        contentView.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        bottomConstraint = bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        centerXConstraint = centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        bottomConstraint?.activate()
        centerXConstraint?.activate()
        
        widthAnchor.constraint(equalToConstant: width).activate()
        heightAnchor.constraint(equalToConstant: height).activate()
    }
    
    func changeVisability(toHidden hidden: Bool) {
        button.isEnabled = !hidden
        alpha = hidden ? 0 : 1
        if hidden {
            updatePosition(x: 0, bottom: bottomConstraintOriginalConstant)
        }
    }
    
    func updatePosition(x: CGFloat, bottom: CGFloat) {
        centerXConstraint?.constant = x
        bottomConstraint?.constant = bottom
    }
    
    @IBAction private func buttonAction(_ sender: Any) {
        actionDelegate?.selectPlusMenuItem(action: type.action)
    }
    
}
