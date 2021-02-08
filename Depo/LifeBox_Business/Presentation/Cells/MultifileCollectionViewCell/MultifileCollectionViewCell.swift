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
    
    
    @IBOutlet weak var nameEditView: UIView! {
        willSet {
            newValue.alpha = 0
        }
    }
    
    private var itemModel : Item?
    
    private var isAllowedToShowShared: Bool = false
    
    
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
        self.isSelected = isSelected
        
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
        if #available(iOS 14.0, *) {
            //use button + UIMenu instead
            return
            
        } else {
            actionDelegate?.onMenuPress(sender: sender, itemModel: itemModel)
        }
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
                UIView.animate(withDuration: NumericConstants.animationDuration, delay: 0, options: [.curveEaseInOut]) {
                    self?.nameEditView.alpha = 1
                } completion: { _ in }

            } else {
                self?.actionDelegate?.onSelectMenuAction(type: actionType, itemModel: self?.itemModel, sender: self?.menuButton)
            }
            
        }
        menuButton.menu = menu
    }
    
    @objc func onCellSelected(_ sender: Any) {
        guard let button = sender as? IndexPathButton, let indexPath = button.indexPath else {
            return
        }
        
        actionDelegate?.onCellSelected(indexPath: indexPath)
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
