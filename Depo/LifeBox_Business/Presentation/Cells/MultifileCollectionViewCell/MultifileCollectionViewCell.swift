//
//  MultifileCollectionViewCell.swift
//  Depo
//
//  Created by Konstantin Studilin on 02.02.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

protocol MultifileCollectionViewCellActionDelegate: class {
    func onMenuPress(sender: Any, itemModel: Item?)
    func onSelectMenuAction(type: ActionType, itemModel: Item?, sender: Any?)
    
    @available(iOS 14, *)
    func onCellSelected(indexPath: IndexPath)
}


//TODO: change font when it's available

class MultifileCollectionViewCell: UICollectionViewCell {
    
    static let height: CGFloat = 60.0
    
    weak var actionDelegate: MultifileCollectionViewCellActionDelegate?
    
    @IBOutlet weak var selectIcon: UIImageView! {
       willSet {
           newValue.contentMode = .scaleAspectFill
       }
   }
    
    @IBOutlet weak var selectIconWidth: NSLayoutConstraint! {
        willSet {
            newValue.constant = 0
        }
    }
    
    @IBOutlet private weak var thumbnail: UIImageView! {
        willSet {
            newValue.contentMode = .scaleAspectFill
        }
    }
    
    @IBOutlet private weak var name: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaRegFont(size: 14.0)
            newValue.textColor = ColorConstants.multifileCellTitleText
        }
    }
    
    @IBOutlet private weak var lastModifiedDate: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaRegFont(size: 10.0)
            newValue.textColor = ColorConstants.multifileCellSubtitleText
        }
    }
    
    @IBOutlet private weak var iconsStack: UIStackView! {
        willSet {
            newValue.spacing = 8
            newValue.axis = .horizontal
            newValue.alignment = .center
            newValue.distribution = .fillEqually
        }
    }
    
    private lazy var menuButton: IndexPathButton = {
        let button = IndexPathButton(with: IndexPath(row: 0, section: 0))
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    //MARK: NAme editing
    @IBOutlet weak var nameEditView: UIView! {
        willSet {
            newValue.alpha = 0
        }
    }
    
    @IBOutlet weak var renameField: UITextField! {
        willSet {
            newValue.delegate = self
        }
    }
    
    @IBOutlet weak var cancelRenamingButton: UIButton! {
        willSet {
            newValue.titleLabel?.text = ""
            let cancelImage = UIImage(named: "cancelButton")
            newValue.setImage(cancelImage, for: .normal)
        }
    }
    
    @IBOutlet weak var applyRenamingButton: UIButton! {
        willSet {
            newValue.titleLabel?.text = ""
            let cancelImage = UIImage(named: "applyButton")
            newValue.setImage(cancelImage, for: .normal)
        }
    }
    
    private var itemModel : Item?
    private var isAllowedToShowShared: Bool = false
    private var pathExtensionLength: Int = 0
    
    override var isSelected: Bool {
        willSet {
            backgroundColor = newValue ? ColorConstants.multifileCellBackgroundColorSelected : ColorConstants.multifileCellBackgroundColor
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if #available(iOS 14, *) {
            setupLongTapButtonMenu()
        } else {
            setupLongGesture()
        }
    }
    
    override func prepareForReuse() {
        itemModel = nil
        actionDelegate = nil
        isAllowedToShowShared = false
        
        name.text = ""
        lastModifiedDate.text = ""
        renameField.text = ""
        pathExtensionLength = 0
        thumbnail.image = nil
        iconsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        selectIconWidth.constant = 0
        nameEditView.alpha = 0
        
        if #available(iOS 14, *) {
            menuButton.menu = nil
            menuButton.change(indexPath: nil)
        }
        
        isSelected = false
    }
    
    func setup(with item: Item, at indexPath: IndexPath, isSharedIconAllowed: Bool, menuActionDelegate: MultifileCollectionViewCellActionDelegate?) {
        itemModel = item
        pathExtensionLength = (item.name as NSString?)?.pathExtension.count ?? 0
        isAllowedToShowShared = isSharedIconAllowed
        actionDelegate = menuActionDelegate
        
        if #available(iOS 14, *) {
            setupMenu(indexPath: indexPath)
        }
        
        DispatchQueue.toMain {
            self.name.text = item.name
            self.lastModifiedDate.text = item.lastModifiDate?.getDateInFormat(format: "dd/MM/yyyy - HH:mm")
            self.thumbnail.image = WrapperedItemUtil.getSmallPreviewImageForWrapperedObject(fileType: item.fileType)
            
            self.iconsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
            
            if item.favorites {
                let isFavoriteIcon = UIImage(named: "favoriteIcon")
                let isFavoriteView = UIImageView(image: isFavoriteIcon)
                isFavoriteView.contentMode = .scaleAspectFit
                self.iconsStack.addArrangedSubview(isFavoriteView)
            }
            
            if item.isShared, self.isAllowedToShowShared {
                let isSharedIcon = UIImage(named: "sharedIcon")
                let isSharedView = UIImageView(image: isSharedIcon)
                isSharedView.contentMode = .scaleAspectFit
                self.iconsStack.addArrangedSubview(isSharedView)
            }
        }
    }
    
    func setSelection(isSelectionActive: Bool, isSelected: Bool) {
        self.isSelected = isSelectionActive && isSelected
        
        let widthConstant: CGFloat
        
        if isSelectionActive {
            let selectImage = isSelected ? UIImage(named: "selected-checked") : UIImage(named: "selected-unchecked")
            selectIcon.image = selectImage
            widthConstant = 22
        } else {
            widthConstant = 0
        }
        
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.selectIconWidth.constant = widthConstant
        } completion: { _ in
            self.layoutIfNeeded()
        }
        
        if #available(iOS 14.0, *) {
            setMenu(isAvailable: !isSelectionActive)
        }

    }
    
    //MARK: - Menu button actions
    
    //ios < 14
    private func setupLongGesture() {
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(onLongTap(_:)))
        gestureRecognizer.minimumPressDuration = 0.5
        gestureRecognizer.delaysTouchesBegan = true
        addGestureRecognizer(gestureRecognizer)
        
    }
    
    @objc private func onLongTap(_ sender: Any) {
        
        //TODO: handle renaming
        
        if #available(iOS 14.0, *) {
            //using button + UIMenu instead
            return
            
        } else {
            actionDelegate?.onMenuPress(sender: sender, itemModel: itemModel)
        }
    }
    
    private func showRenamingView() {
        if #available(iOS 14.0, *) {
            menuButton.isUserInteractionEnabled = false
        }
        
        renameField.text = self.itemModel?.name
        renameField.becomeFirstResponder()
        
        UIView.animate(withDuration: NumericConstants.animationDuration, delay: 0, options: [.curveEaseInOut]) {
            self.nameEditView.alpha = 1
            
        } completion: { _ in
            
            let offset = (self.renameField.text?.count ?? 0) - self.pathExtensionLength - 1
            if let position = self.renameField.position(from: self.renameField.beginningOfDocument, offset: offset) {
                self.renameField.selectedTextRange = self.renameField.textRange(from: position, to: position)
            }
        }
    }
    
    private func hideRenamignView() {
        
        if #available(iOS 14.0, *) {
            self.menuButton.isUserInteractionEnabled = true
        }
        
        UIView.animate(withDuration: NumericConstants.animationDuration, delay: 0, options: [.curveEaseInOut]) {
            self.nameEditView.alpha = 0
            
        } completion: { _ in
            //
        }
    }
    
    @IBAction func stopRenaming(_ sender: Any) {
        hideRenamignView()
        //
    }
    
    
    @IBAction func applyRenaming(_ sender: Any) {
        hideRenamignView()
        //
    }
    
}

@available(iOS 14, *)
extension MultifileCollectionViewCell {
    
    private func setupLongTapButtonMenu() {
        menuButton.showsMenuAsPrimaryAction = false
        contentView.addSubview(menuButton)
        menuButton.pinToSuperviewEdges()
    }
    
    private func setupMenu(indexPath: IndexPath) {
        guard let item = itemModel else {
            return
        }
        
        menuButton.change(indexPath: indexPath)
        
        menuButton.addTarget(self, action: #selector(onCellSelected(_:)), for: .touchUpInside)
        
        let menu = MenuItemsFabric.generateMenu(for: item, status: item.status) { [weak self] actionType in
            if case .elementType(.rename) = actionType {
                self?.showRenamingView()
            } else {
                self?.actionDelegate?.onSelectMenuAction(type: actionType, itemModel: self?.itemModel, sender: self?.menuButton)
            }
            
        }
        menuButton.menu = menu
    }
    
    private func setMenu(isAvailable: Bool) {
        if isAvailable, let indexPath = menuButton.indexPath {
            setupMenu(indexPath: indexPath)
        } else {
            menuButton.menu = nil
        }
    }
    
    @objc private func onCellSelected(_ sender: Any) {
        guard let button = sender as? IndexPathButton, let indexPath = button.indexPath else {
            return
        }
        
        actionDelegate?.onCellSelected(indexPath: indexPath)
    }
}


extension MultifileCollectionViewCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textLength = textField.text?.count, pathExtensionLength > 0 else {
            return true
        }
        return range.upperBound < textLength - pathExtensionLength
    }
}


final class IndexPathButton: UIButton {
    private(set) var indexPath: IndexPath?
    
    convenience init(with indexPath: IndexPath) {
        self.init()
        self.indexPath = indexPath
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
    }
    
    func change(indexPath: IndexPath?) {
        self.indexPath = indexPath
    }
}
