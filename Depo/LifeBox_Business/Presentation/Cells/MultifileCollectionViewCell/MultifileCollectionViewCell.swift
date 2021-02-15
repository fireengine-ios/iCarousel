//
//  MultifileCollectionViewCell.swift
//  Depo
//
//  Created by Konstantin Studilin on 02.02.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

private enum HorizontalScrollDirection {
    case left
    case right
    case none
    
    init(velocityX: CGFloat) {
        if velocityX < 0 {
            self = .left
        } else if velocityX > 0 {
            self = .right
        } else {
            self = .none
        }
    }
}

protocol MultifileCollectionViewCellActionDelegate: class {
    func onMenuPress(sender: Any, itemModel: Item?)
    func onSelectMenuAction(type: ActionType, itemModel: Item?, sender: Any?)
    func rename(item: WrapData, name: String, completion: @escaping BoolHandler)
    func onLongPress(cell: UICollectionViewCell)
    
    @available(iOS 14, *)
    func onCellSelected(indexPath: IndexPath)
}

//TODO: change font when it's available

class MultifileCollectionViewCell: UICollectionViewCell {
    
    static let height: CGFloat = 60.0
    
    
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
            newValue.contentMode = .scaleAspectFit
        }
    }
    
    @IBOutlet private weak var name: UILabel! {
        willSet {
            newValue.font = UIFont.GTAmericaStandardRegularFont(size: 14.0)
            newValue.textColor = ColorConstants.multifileCellTitleText
        }
    }
    
    @IBOutlet private weak var lastModifiedDate: UILabel! {
        willSet {
            newValue.font = UIFont.GTAmericaStandardRegularFont(size: 10.0)
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
    
    private lazy var longTapGestureRecognizer: UILongPressGestureRecognizer = {
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(onLongTap(_:)))
        recognizer.minimumPressDuration = 0.5
        recognizer.delaysTouchesBegan = true
        return recognizer
    }()
    
    
    //MARK: Name editing
    @IBOutlet weak var nameEditView: UIView! {
        willSet {
            newValue.backgroundColor = ColorConstants.multifileCellBackgroundColorSelectedSolid
            newValue.alpha = 0
        }
    }
    
    @IBOutlet weak var renameField: UITextField! {
        willSet {
            newValue.delegate = self
            newValue.backgroundColor = .white
        }
    }
    
    @IBOutlet weak var cancelRenamingButton: UIButton! {
        willSet {
            newValue.setTitle("", for: .normal)
            let cancelImage = UIImage(named: "cancelButton")
            newValue.setImage(cancelImage, for: .normal)
        }
    }
    
    @IBOutlet weak var applyRenamingButton: UIButton! {
        willSet {
            newValue.setTitle("", for: .normal)
            let applyImage = UIImage(named: "applyButton")
            newValue.setImage(applyImage, for: .normal)
        }
    }
    
    
    //MARK: - scroll view
    @IBOutlet weak var scrollableContent: UIScrollView! {
        willSet {
            newValue.showsHorizontalScrollIndicator = false
            newValue.showsVerticalScrollIndicator = false
            newValue.alwaysBounceHorizontal = false
            newValue.alwaysBounceVertical = false
            newValue.bounces = false
            newValue.isPagingEnabled = false
            newValue.delegate = self
        }
    }
    
    @IBOutlet weak var defaultView: UIView!
    
    @IBOutlet weak var infoView: UIView! {
        willSet {
            newValue.backgroundColor = ColorConstants.multifileCellInfoView
        }
    }
    
    @IBOutlet weak var deletionView: UIView! {
        willSet {
            newValue.backgroundColor = ColorConstants.multifileCellDeletionView
        }
    }
    //MARK: -
    
    @IBOutlet weak var infoButton: UIButton! {
        willSet {
            newValue.tintColor = .white
            newValue.setTitle(TextConstants.actionInfo, for: .normal)
            newValue.titleLabel?.font = UIFont.GTAmericaStandardRegularFont(size: 10)
            newValue.setImage(UIImage(named: "info"), for: .normal)
            
        }
    }
    
    @IBOutlet weak var deleteButton: UIButton! {
        willSet {
            newValue.tintColor = .white
            newValue.setTitle(TextConstants.actionDelete, for: .normal)
            newValue.titleLabel?.font = UIFont.GTAmericaStandardRegularFont(size: 10)
            newValue.setImage(UIImage(named: "trash"), for: .normal)
        }
    }
    
    private let actionViewsVisiblePart: CGFloat = 0.35
    private let actionViewsTriggerPart: CGFloat = 0.2
    
    weak var actionDelegate: MultifileCollectionViewCellActionDelegate?
    
    private var itemModel : Item?
    private var isAllowedToShowShared = false
    private(set) var isRenamingInProgress = false
    private var isSelectionInProgress = false
    private var pathExtensionLength = 0
    
    //MARK: - Override
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
        isRenamingInProgress = false
        isSelectionInProgress = false
        
        name.text = ""
        lastModifiedDate.text = ""
        renameField.text = ""
        pathExtensionLength = 0
        thumbnail.image = nil
        iconsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        selectIconWidth.constant = 0
        nameEditView.alpha = 0
        scrollableContent.scrollRectToVisible(defaultView.frame, animated: false)
        
        if #available(iOS 14, *) {
            menuButton.menu = nil
            menuButton.change(indexPath: nil)
        }
        
        isSelected = false
    }
    
    //MARK: - Setup
    
    func setup(with item: Item, at indexPath: IndexPath, isSharedIconAllowed: Bool, menuActionDelegate: MultifileCollectionViewCellActionDelegate?) {
        itemModel = item
        pathExtensionLength = (item.name as NSString?)?.pathExtension.count ?? 0
        isAllowedToShowShared = isSharedIconAllowed
        actionDelegate = menuActionDelegate
        
        if #available(iOS 14, *) {
            setupMenu(indexPath: indexPath)
        }
        
        setupMenuAvailability()
        setupUI()
    }
    
    private func setupUI() {
        DispatchQueue.main.async {
            guard let item = self.itemModel else {
                return
            }
            
            self.infoButton.centerVertically(padding: 4)
            self.deleteButton.centerVertically(padding: 4)
            
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
            
            self.scrollableContent.scrollRectToVisible(self.defaultView.frame, animated: false)
        }
    }
    
    func setSelection(isSelectionActive: Bool, isSelected: Bool) {
        isSelectionInProgress = isSelectionActive
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
            self.setupMenuAvailability()
            self.layoutIfNeeded()
        }
    }
    
    //MARK: - Menu button actions
    
    //ios < 14
    private func setupLongGesture() {
        addGestureRecognizer(longTapGestureRecognizer)
    }
    
    @objc private func onLongTap(_ sender: Any) {
        if #available(iOS 14.0, *) {
            //use button + UIMenu
            return
        }
        
        actionDelegate?.onMenuPress(sender: sender, itemModel: itemModel)
    }
    
    
    //MARK: - Renaming
    
    func startRenaming() {
        isRenamingInProgress = true

        setupMenuAvailability()
        showRenamingView()
    }
    
    private func showRenamingView() {
        DispatchQueue.toMain {
            self.renameField.text = self.itemModel?.name
            self.renameField.becomeFirstResponder()
            
            UIView.animate(withDuration: NumericConstants.animationDuration, delay: 0, options: [.curveEaseInOut]) {
                self.nameEditView.alpha = 1
                self.backgroundColor = ColorConstants.multifileCellBackgroundColorSelected
            } completion: { _ in
                let offset = (self.renameField.text?.count ?? 0) - self.pathExtensionLength - 1
                if let position = self.renameField.position(from: self.renameField.beginningOfDocument, offset: offset) {
                    self.renameField.selectedTextRange = self.renameField.textRange(from: position, to: position)
                }
            }
        }
    }
    
    private func hideRenamignView() {
        endEditing(true)
        
        UIView.animate(withDuration: NumericConstants.animationDuration, delay: 0, options: [.curveEaseInOut]) {
            self.nameEditView.alpha = 0
            self.backgroundColor = ColorConstants.multifileCellBackgroundColor
        } completion: { _ in
            //
        }
    }
    
    @IBAction func stopRenaming(_ sender: Any) {
        isRenamingInProgress = false
        hideRenamignView()
        setupMenuAvailability()
    }
    
    
    @IBAction func applyRenaming(_ sender: Any) {
        isRenamingInProgress = false
        hideRenamignView()
        setupMenuAvailability()
        
        guard let name = renameField.text, name.count > pathExtensionLength else {
            return
        }
        
        if let item = itemModel {
            actionDelegate?.rename(item: item, name: name, completion: { [weak self] renamed in
                if renamed {
                    self?.itemModel?.name = name
                }
            })
        }
        
    }
    
    private func setupMenuAvailability() {
        if #available(iOS 14.0, *) {
            setMenu(isAvailable: !(isSelectionInProgress || isRenamingInProgress))
            setMenuButtonInteraction(isEnabled: !isRenamingInProgress)
        } else {
            longTapGestureRecognizer.isEnabled = !(isSelectionInProgress || isRenamingInProgress)
        }
    }
    
    @IBAction func onInfoButtonTapped(_ sender: Any) {
        scrollableContent.scrollRectToVisible(self.defaultView.frame, animated: true)
        actionDelegate?.onSelectMenuAction(type: .elementType(.info), itemModel: itemModel, sender: self)
    }
    
    @IBAction func onDeleteButtonTapped(_ sender: Any) {
        actionDelegate?.onSelectMenuAction(type: .elementType(.moveToTrash), itemModel: itemModel, sender: self)
    }
    
    
}

//MARK: - ios 14 pull down menu
@available(iOS 14, *)
extension MultifileCollectionViewCell {
    
    private func setupLongTapButtonMenu() {
        menuButton.showsMenuAsPrimaryAction = false
        defaultView.addSubview(menuButton)
        menuButton.trailingAnchor.constraint(equalTo: defaultView.trailingAnchor).activate()
        menuButton.centerYAnchor.constraint(equalTo: defaultView.centerYAnchor).activate()
        menuButton.heightAnchor.constraint(equalToConstant: 1).activate()
        menuButton.widthAnchor.constraint(equalToConstant: 1).activate()
    }
    
    private func setupMenu(indexPath: IndexPath) {
        guard let item = itemModel else {
            return
        }
        
        menuButton.change(indexPath: indexPath)
        
        menuButton.addTarget(self, action: #selector(onCellSelected(_:)), for: .touchUpInside)
        
        let menu = MenuItemsFabric.generateMenu(for: item, status: item.status) { [weak self] actionType in
            if case .elementType(.rename) = actionType {
                self?.startRenaming()
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
    
    private func setMenuButtonInteraction(isEnabled: Bool) {
        menuButton.isUserInteractionEnabled = isEnabled
    }
    
    @objc private func onCellSelected(_ sender: Any) {
        guard let button = sender as? IndexPathButton, let indexPath = button.indexPath else {
            return
        }
        
        actionDelegate?.onCellSelected(indexPath: indexPath)
    }
}


extension MultifileCollectionViewCell: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        updateOffset(scrollView: scrollView, velocityX: velocity.x, targetContentOffset: targetContentOffset)
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        updateOffset(scrollView: scrollView, velocityX: 0, targetContentOffset: nil)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let defaultOffsetX = defaultView.frame.origin.x
        let currentOffset = scrollView.contentOffset.x
        
        guard currentOffset != defaultOffsetX else {
            return
        }
        
        let infoPauseOffsetX = defaultOffsetX - infoView.bounds.width * actionViewsVisiblePart
        let deletePauseOffsetX = defaultOffsetX + deletionView.bounds.width  * actionViewsVisiblePart
        let infoOffsetX = infoView.frame.origin.x
        let deleteOffsetX = deletionView.frame.origin.x
        
        let lightFeedback = UIImpactFeedbackGenerator(style: .light)
        let mediumFeedback = UIImpactFeedbackGenerator(style: .medium)
    
        if currentOffset == infoPauseOffsetX || currentOffset == deletePauseOffsetX {
            lightFeedback.impactOccurred()
            
        } else if currentOffset == infoOffsetX {
            mediumFeedback.impactOccurred()
            scrollableContent.scrollRectToVisible(self.defaultView.frame, animated: true)
            actionDelegate?.onSelectMenuAction(type: .elementType(.info), itemModel: itemModel, sender: self)
            
        } else if currentOffset == deleteOffsetX {
            mediumFeedback.impactOccurred()
            scrollableContent.scrollRectToVisible(self.defaultView.frame, animated: true)
            actionDelegate?.onSelectMenuAction(type: .elementType(.moveToTrash), itemModel: itemModel, sender: self)
        }
    }
    
    private func updateOffset(scrollView: UIScrollView, velocityX: CGFloat, targetContentOffset: UnsafeMutablePointer<CGPoint>?) {
        if  abs(velocityX) > 0.5 {
            updateOffsetFast(scrollView: scrollView, direction: HorizontalScrollDirection(velocityX: velocityX), targetContentOffset: targetContentOffset)
        } else {
            updateOffsetSlow(scrollView: scrollView)
        }
    }
    
    private func updateOffsetFast(scrollView: UIScrollView, direction: HorizontalScrollDirection, targetContentOffset: UnsafeMutablePointer<CGPoint>?){
        
        let defaultViewOffsetX = defaultView.frame.origin.x
        
        //stop scrolling
        targetContentOffset?.pointee = scrollView.contentOffset
        
        switch direction {
            case .left:
                if scrollView.contentOffset.x > defaultViewOffsetX {
                    scrollView.scrollRectToVisible(defaultView.frame, animated: true)
                } else {
                    scrollView.scrollRectToVisible(infoView.frame, animated: true)
                }
            case .right:
                if scrollView.contentOffset.x < defaultViewOffsetX {
                    scrollView.scrollRectToVisible(defaultView.frame, animated: true)
                } else {
                    scrollView.scrollRectToVisible(deletionView.frame, animated: true)
                }
            case .none:
                assertionFailure()
        }
        
    }
    
    private func updateOffsetSlow(scrollView: UIScrollView) {
        
        let scrollOffsetX = scrollView.contentOffset.x
        
        guard scrollOffsetX != infoView.frame.origin.x else {
            onInfoButtonTapped(self)
            return
        }
        
        guard scrollOffsetX != deletionView.frame.origin.x else {
            onDeleteButtonTapped(self)
            return
        }
        
        let defaultOffsetX = defaultView.frame.origin.x
        
        let infoPauseOffsetX = defaultOffsetX - infoView.bounds.width * actionViewsVisiblePart
        let deletePauseOffsetX = defaultOffsetX + deletionView.bounds.width  * actionViewsVisiblePart
        
        let infoPauseTriggerOffsetX = defaultOffsetX - infoView.bounds.width * actionViewsTriggerPart
        let deletePauseTriggerOffsetX = defaultOffsetX + deletionView.bounds.width * actionViewsTriggerPart
        
        if scrollOffsetX < infoPauseTriggerOffsetX {
            if scrollOffsetX >= infoPauseOffsetX {
                scrollView.setContentOffset(CGPoint(x: infoPauseOffsetX, y: 0), animated: true)
            } else {
                scrollView.scrollRectToVisible(infoView.frame, animated: true)
            }
        } else if scrollOffsetX > deletePauseTriggerOffsetX {
            if scrollOffsetX <= deletePauseOffsetX {
                scrollView.setContentOffset(CGPoint(x: deletePauseOffsetX, y: 0), animated: true)
            } else {
                scrollView.scrollRectToVisible(deletionView.frame, animated: true)
            }
        } else {
            scrollView.scrollRectToVisible(defaultView.frame, animated: true)
        }
    }
}


//MARK: - UITextFieldDelegate
extension MultifileCollectionViewCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textLength = textField.text?.count, pathExtensionLength > 0 else {
            return true
        }
        return range.upperBound < textLength - pathExtensionLength
    }
}


//MARK: - IndexPathButton
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
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return superview?.point(inside: convert(point, to: superview), with: event) ?? false
    }
}
