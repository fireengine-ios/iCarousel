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

private struct SwipeConfig {
    static let visiblePart: CGFloat = 0.3
    static let triggerPart: CGFloat = 0.5
    static let velocityXBeforeFastSwipe: CGFloat = 0.5
    
    private init() {}
}

private enum SwipeState: Equatable {
    case defaultView
    case infoView(full: Bool)
    case deleteView(full: Bool)
}

protocol MultifileCollectionViewCellActionDelegate: class {
    func onMenuPress(sender: Any, itemModel: Item?)
    func onSelectMenuAction(type: ActionType, itemModel: Item?, sender: Any?, indexPath: IndexPath?)
    func onRenameStarted(at indexPath: IndexPath)
    func rename(item: WrapData, name: String, completion: @escaping BoolHandler)
    func onLongPress(cell: UICollectionViewCell)
    func onCellSelected(indexPath: IndexPath)
}

//TODO: change font when it's available
//TODO: split in views

class MultifileCollectionViewCell: UICollectionViewCell {
    
    static let height: CGFloat = 60.0
    
    
    @IBOutlet private weak var selectIcon: UIImageView! {
       willSet {
           newValue.contentMode = .scaleAspectFill
       }
   }
    
    @IBOutlet private weak var selectIconWidth: NSLayoutConstraint! {
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
        button.setBackgroundColor(ColorConstants.multifileCellBackgroundColorSelected, for: .highlighted)
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
    @IBOutlet private weak var nameEditView: UIView! {
        willSet {
            newValue.backgroundColor = ColorConstants.multifileCellBackgroundColorSelectedSolid
            newValue.alpha = 0
        }
    }
    
    @IBOutlet private weak var renameField: UITextField! {
        willSet {
            newValue.delegate = self
            newValue.backgroundColor = .white
            newValue.addTarget(self, action: #selector(updateNameTextColor(textField:)), for: .editingChanged)
        }
    }
    
    @IBOutlet private weak var cancelRenamingButton: UIButton! {
        willSet {
            newValue.setTitle("", for: .normal)
            let cancelImage = UIImage(named: "cancelButton")
            newValue.setImage(cancelImage, for: .normal)
        }
    }
    
    @IBOutlet private weak var applyRenamingButton: UIButton! {
        willSet {
            newValue.setTitle("", for: .normal)
            let applyImage = UIImage(named: "applyButton")
            newValue.setImage(applyImage, for: .normal)
        }
    }
    
    
    //MARK: - scroll view
    @IBOutlet private weak var scrollableContent: UIScrollView! {
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
    
    @IBOutlet private weak var defaultView: UIView!
    
    @IBOutlet private weak var infoView: UIView! {
        willSet {
            newValue.backgroundColor = ColorConstants.multifileCellInfoView
        }
    }
    
    @IBOutlet private weak var deletionView: UIView! {
        willSet {
            newValue.backgroundColor = ColorConstants.multifileCellDeletionView
        }
    }
    //MARK: -
    
    @IBOutlet private weak var infoButton: UIButton! {
        willSet {
            newValue.tintColor = .white
            newValue.setTitle(TextConstants.actionInfo, for: .normal)
            newValue.titleLabel?.font = UIFont.GTAmericaStandardRegularFont(size: 10)
            newValue.setImage(UIImage(named: "info"), for: .normal)
            
        }
    }
    
    @IBOutlet private weak var deleteButton: UIButton! {
        willSet {
            newValue.tintColor = .white
            newValue.setTitle(TextConstants.actionDelete, for: .normal)
            newValue.titleLabel?.font = UIFont.GTAmericaStandardRegularFont(size: 10)
            newValue.setImage(UIImage(named: "trash"), for: .normal)
        }
    }
    
    weak var actionDelegate: MultifileCollectionViewCellActionDelegate?
    
    private var itemModel : Item?
    private var isAllowedToShowShared = false
    private var isAllowedToSwipe: Bool {
        var isNotATrashBinRelative = itemModel?.privateShareType != .trashBin
        if case .innerFolder = itemModel?.privateShareType, itemModel?.privateShareType.rootType == .trashBin  {
            isNotATrashBinRelative = false
        }
        return !(isSelectionInProgress || isRenamingInProgress) && isNotATrashBinRelative
    }
    private var isAllowedToSwipeDelete: Bool {
        var isNotATrashBinRelative = itemModel?.privateShareType != .trashBin
        if case .innerFolder = itemModel?.privateShareType, itemModel?.privateShareType.rootType == .trashBin  {
            isNotATrashBinRelative = false
        }
        return itemModel?.privateSharePermission?.granted?.contains(.delete) ?? false && isAllowedToSwipe && isNotATrashBinRelative
    }
    private(set) var isRenamingInProgress = false
    private var isSelectionInProgress = false
    private var pathExtensionLength = 0
    
    private var swipeState: SwipeState = .defaultView {
        didSet {
            setupMenuAvailability()
            switch swipeState {
                case .defaultView:
                    scrollableContent.scrollRectToVisible(defaultView.frame, animated: true)
                    
                case .infoView(full: true):
                    scrollableContent.scrollRectToVisible(infoView.frame, animated: true)
                    
                case .deleteView(full: true):
                    scrollableContent.scrollRectToVisible(deletionView.frame, animated: true)
                    
                case .infoView(full: false):
                    let offsetX = defaultView.frame.origin.x - infoView.bounds.size.width * SwipeConfig.visiblePart
                    scrollableContent.setContentOffset(CGPoint(x: offsetX, y: scrollableContent.contentOffset.y), animated: true)
                    
                case .deleteView(full: false):
                    let offsetX = defaultView.frame.origin.x + deletionView.bounds.size.width * SwipeConfig.visiblePart
                    scrollableContent.setContentOffset(CGPoint(x: offsetX, y: scrollableContent.contentOffset.y), animated: true)
            }
        }
    }
    
    //MARK: - Override
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        scrollableContent.scrollRectToVisible(defaultView.frame, animated: false)
        
        setupLongTapButtonMenu()
    }
    
    override func prepareForReuse() {
        itemModel = nil
        actionDelegate = nil
        isAllowedToShowShared = false
        isRenamingInProgress = false
        isSelectionInProgress = false

        name.text = ""
        lastModifiedDate.text = ""
        renameField.attributedText = NSAttributedString(string: "")
        pathExtensionLength = 0
        thumbnail.image = nil
        iconsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        selectIconWidth.constant = 0
        nameEditView.alpha = 0
        
        if #available(iOS 14, *) {
            setMenu(isAvailable: false)
        }

        menuButton.change(indexPath: nil)
        
        resetSwipe()
    }
    
    //MARK: - Setup
    
    func setup(with item: Item, at indexPath: IndexPath, isSharedIconAllowed: Bool, menuActionDelegate: MultifileCollectionViewCellActionDelegate?) {
        itemModel = item
        pathExtensionLength = (item.name as NSString?)?.pathExtension.count ?? 0
        isAllowedToShowShared = isSharedIconAllowed
        actionDelegate = menuActionDelegate
        
        setupMenu(indexPath: indexPath)
        
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
            
            self.resetSwipe()
        }
    }
    
    func setSelection(isSelectionActive: Bool, isSelected: Bool) {
        isSelectionInProgress = isSelectionActive
        
        let widthConstant: CGFloat
        
        if isSelectionActive {
            setupBackgroundColor(isSelected: isSelected)
            
            let selectImage = isSelected ? UIImage(named: "selected-checked") : UIImage(named: "selected-unchecked")
            selectIcon.image = selectImage
            widthConstant = 22
        } else {
            setupBackgroundColor(isSelected: false)
            widthConstant = 0
        }
        
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.selectIconWidth.constant = widthConstant
        } completion: { _ in
            self.setupMenuAvailability()
            self.layoutIfNeeded()
        }
    }
    
    func resetSwipe() {
        setupBackgroundColor(isSelected: false)
        scrollableContent.scrollRectToVisible(defaultView.frame, animated: false)
        swipeState = .defaultView
    }
    
    private func setupBackgroundColor(isSelected: Bool) {
        UIView.animate(withDuration: NumericConstants.setImageAnimationDuration) {
            self.defaultView.backgroundColor = isSelected ? ColorConstants.multifileCellBackgroundColorSelected : ColorConstants.multifileCellBackgroundColor
        }
    }
    
    //MARK: - Menu button actions
    
    @objc private func onLongTap(_ sender: Any) {
        if #available(iOS 14.0, *) {
            //use button + UIMenu
            return
        }
        
        onMenuTriggered()
        actionDelegate?.onMenuPress(sender: sender, itemModel: itemModel)
    }
    
    @objc private func onMenuTriggered() {
        let lightFeedback = UIImpactFeedbackGenerator(style: .light)
        lightFeedback.impactOccurred()
    }
    
    
    //MARK: - Renaming
    
    func startRenaming() {
        isRenamingInProgress = true

        setupMenuAvailability()
        showRenamingView()
    }
    
    private func showRenamingView() {
        DispatchQueue.toMain {
            self.renameField.attributedText = NSAttributedString(string: self.itemModel?.name ?? "")
            self.renameField.becomeFirstResponder()
            self.updateNameTextColor(textField: self.renameField)
            
            if let indexPath = self.menuButton.indexPath {
                self.actionDelegate?.onRenameStarted(at: indexPath)
            }
            
            UIView.animate(withDuration: NumericConstants.animationDuration, delay: 0, options: [.curveEaseInOut]) {
                self.nameEditView.alpha = 1
                self.defaultView.backgroundColor = ColorConstants.multifileCellBackgroundColorSelected
            } completion: { _ in
                //
            }
        }
    }
    
    private func hideRenamignView() {
        endEditing(true)
        
        UIView.animate(withDuration: NumericConstants.animationDuration, delay: 0, options: [.curveEaseInOut]) {
            self.nameEditView.alpha = 0
            self.defaultView.backgroundColor = ColorConstants.multifileCellBackgroundColor
        } completion: { _ in
            //
        }
    }
    
    @IBAction private func stopRenaming(_ sender: Any) {
        isRenamingInProgress = false
        hideRenamignView()
        setupMenuAvailability()
    }
    
    
    @IBAction private func applyRenaming(_ sender: Any) {
        isRenamingInProgress = false
        hideRenamignView()
        setupMenuAvailability()
        
        guard let name = renameField.attributedText?.string, name.count > pathExtensionLength else {
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
        setMenu(isAvailable: !(isSelectionInProgress || isRenamingInProgress) && swipeState == .defaultView)
        setMenuButtonInteraction(isEnabled: !isRenamingInProgress)
    }
    
    @objc
    private func updateNameTextColor(textField: UITextField) {
        guard pathExtensionLength > 0, let name = textField.attributedText?.string else {
            return
        }
        
        let attributes = [NSAttributedString.Key.foregroundColor: ColorConstants.multifileCellRenameFieldNameColor,
                          NSAttributedString.Key.font: UIFont.GTAmericaStandardRegularFont(size: 14.0)]
        
        let attributedString = NSMutableAttributedString(string: name, attributes: attributes)
        let extensionRange = NSMakeRange(name.count - pathExtensionLength, pathExtensionLength)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: ColorConstants.multifileCellRenameFieldExtensionColor, range: extensionRange)
        textField.attributedText = attributedString
        
        let offset = pathExtensionLength > 0 ? name.count - pathExtensionLength - 1 : name.count
        
        if let position = textField.position(from: textField.beginningOfDocument, offset: offset) {
            textField.selectedTextRange = textField.textRange(from: position, to: position)
        }
    }
    
    
    //MARK: - Sсroll view actions
    
    @IBAction private func onInfoButtonTapped(_ sender: Any) {
        scrollableContent.scrollRectToVisible(self.defaultView.frame, animated: true)
        actionDelegate?.onSelectMenuAction(type: .elementType(.info), itemModel: itemModel, sender: self, indexPath: nil)
    }
    
    @IBAction private func onDeleteButtonTapped(_ sender: Any) {
        actionDelegate?.onSelectMenuAction(type: .elementType(.moveToTrash), itemModel: itemModel, sender: self, indexPath: nil)
    }
}

//MARK: - ios 14 pull down and prior ios 14 long tap menu

extension MultifileCollectionViewCell {
    
    private func setupLongTapButtonMenu() {
        defaultView.addSubview(menuButton)
        menuButton.pinToSuperviewEdges()
    }
    
    private func setupMenu(indexPath: IndexPath) {
        guard let item = itemModel else {
            return
        }
        
        menuButton.change(indexPath: indexPath)
        
        menuButton.addTarget(self, action: #selector(onCellTapped(_:)), for: .touchUpInside)
        
        if #available(iOS 14, *) {
            menuButton.showsMenuAsPrimaryAction = false
            menuButton.addTarget(self, action: #selector(onMenuTriggered), for: .menuActionTriggered)
            
            let menu = MenuItemsFabric.generateMenu(for: item, status: item.status) { [weak self] actionType in
                
                if case .elementType(.rename) = actionType {
                    self?.startRenaming()
                } else {
                    self?.actionDelegate?.onSelectMenuAction(type: actionType, itemModel: self?.itemModel, sender: self?.menuButton, indexPath: indexPath)
                }
                
            }
            menuButton.menu = menu
            
        } else {
            menuButton.addGestureRecognizer(longTapGestureRecognizer)
        }
    }
    
    private func setMenu(isAvailable: Bool) {
        if isAvailable, let indexPath = menuButton.indexPath {
            setupMenu(indexPath: indexPath)
        } else {
            if #available(iOS 14, *) {
                menuButton.menu = nil
            } else {
                menuButton.removeGestureRecognizer(longTapGestureRecognizer)
            }
        }
    }
    
    private func setMenuButtonInteraction(isEnabled: Bool) {
        menuButton.isUserInteractionEnabled = isEnabled
    }
    
    @objc private func onCellTapped(_ sender: Any) {
        guard let button = sender as? IndexPathButton, let indexPath = button.indexPath else {
            return
        }
        
        if swipeState == .defaultView {
            actionDelegate?.onCellSelected(indexPath: indexPath)
        } else {
            swipeState = .defaultView
        } 
    }
}


//MARK: - UIScrollViewDelegate
extension MultifileCollectionViewCell: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        updateOffset(scrollView: scrollView, velocityX: velocity.x, targetContentOffset: targetContentOffset)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        setupBackgroundColor(isSelected: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard isAllowedToSwipe else {
            scrollView.scrollRectToVisible(defaultView.frame, animated: false)
            setupBackgroundColor(isSelected: isRenamingInProgress)
            return
        }
        
        if scrollView.contentOffset.x > defaultView.frame.origin.x, !isAllowedToSwipeDelete {
            scrollView.scrollRectToVisible(defaultView.frame, animated: false)
            setupBackgroundColor(isSelected: false)
            return
        }
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        updateOffset(scrollView: scrollView, velocityX: 0, targetContentOffset: nil)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let defaultOffsetX = defaultView.frame.origin.x
        let currentOffset = scrollView.contentOffset.x
        
        guard currentOffset != defaultOffsetX else {
            setupBackgroundColor(isSelected: false)
            return
        }
        
        let infoOffsetX = infoView.frame.origin.x
        let deleteOffsetX = deletionView.frame.origin.x
        
        if currentOffset == infoOffsetX {
            swipeState = .defaultView
            actionDelegate?.onSelectMenuAction(type: .elementType(.info), itemModel: itemModel, sender: self, indexPath: nil)
            
        } else if currentOffset == deleteOffsetX {
            actionDelegate?.onSelectMenuAction(type: .elementType(.moveToTrash), itemModel: itemModel, sender: self, indexPath: nil)
        }
    }
    
    
    private func updateOffset(scrollView: UIScrollView, velocityX: CGFloat, targetContentOffset: UnsafeMutablePointer<CGPoint>?) {
        if  abs(velocityX) > SwipeConfig.velocityXBeforeFastSwipe {
            updateOffsetFast(scrollView: scrollView, direction: HorizontalScrollDirection(velocityX: velocityX), targetContentOffset: targetContentOffset)
        } else {
            updateOffsetSlow(scrollView: scrollView)
        }
    }
    
    private func updateOffsetFast(scrollView: UIScrollView, direction: HorizontalScrollDirection, targetContentOffset: UnsafeMutablePointer<CGPoint>?){
        
        let defaultViewOffsetX = defaultView.frame.origin.x
       
        let infoPauseTriggerOffsetX = defaultViewOffsetX - infoView.bounds.width * SwipeConfig.triggerPart
        let deletePauseTriggerOffsetX = defaultViewOffsetX + deletionView.bounds.width * SwipeConfig.triggerPart
        
        let currentOffsetX = scrollView.contentOffset.x
        
        //stop scrolling
        targetContentOffset?.pointee = scrollView.contentOffset
        
        switch direction {
            case .left:
                if currentOffsetX < defaultViewOffsetX {
                    let isFull = currentOffsetX < infoPauseTriggerOffsetX
                    swipeState = .infoView(full: isFull)
                } else {
                    swipeState = .defaultView
                }
                
            case .right:
                if currentOffsetX > defaultViewOffsetX, isAllowedToSwipeDelete {
                    let isFull = currentOffsetX > deletePauseTriggerOffsetX
                    swipeState = .deleteView(full: isFull)
                } else {
                    swipeState = .defaultView
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
        
        let infoPauseOffsetX = defaultOffsetX - infoView.bounds.width * SwipeConfig.visiblePart
        let deletePauseOffsetX = defaultOffsetX + deletionView.bounds.width  * SwipeConfig.visiblePart
        
        let infoFullTriggerOffsetX = defaultOffsetX - infoView.bounds.width * SwipeConfig.triggerPart
        let deleteFullTriggerOffsetX = defaultOffsetX + deletionView.bounds.width * SwipeConfig.triggerPart
       
        if scrollOffsetX > infoFullTriggerOffsetX, scrollOffsetX <= infoPauseOffsetX {
            swipeState = .infoView(full: false)
        } else if scrollOffsetX < infoFullTriggerOffsetX {
            swipeState = .infoView(full: true)
        } else if scrollOffsetX < deleteFullTriggerOffsetX, scrollOffsetX >= deletePauseOffsetX, isAllowedToSwipeDelete {
            swipeState = .deleteView(full: false)
        } else if scrollOffsetX > deleteFullTriggerOffsetX, isAllowedToSwipeDelete{
            swipeState = .deleteView(full: true)
        } else {
            swipeState = .defaultView
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
