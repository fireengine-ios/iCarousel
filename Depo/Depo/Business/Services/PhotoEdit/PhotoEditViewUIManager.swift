//
//  PhotoEditViewUIManager.swift
//  Depo
//
//  Created by Andrei Novikau on 8/3/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol PhotoEditViewUIManagerDelegate: class {
    func needShowAdjustmentView(for type: AdjustmentViewType)
    func filtersView() -> UIView
    func gifSelectorView() -> UIView
    func stickerSelectorView() -> UIView
    func didSwitchTabBarItem(_ item: PhotoEditTabbarItemType)
    func didRemoveAttachment()
}

final class PhotoEditViewUIManager: NSObject {
    
    @IBOutlet private weak var navBarContainer: UIView!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet weak var imageScrollView: PhotoEditImageScrollView! {
        willSet {
            newValue.imageView.stickersDelegate = self
        }
    }
    
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var filtersScrollView: UIScrollView! {
        willSet {
            newValue.superview?.backgroundColor = ColorConstants.photoEditBackgroundColor
            newValue.backgroundColor = ColorConstants.photoEditBackgroundColor
            newValue.showsVerticalScrollIndicator = false
            newValue.delaysContentTouches = false
        }
    }

    @IBOutlet private weak var filtersContainerView: UIView!
    @IBOutlet private weak var bottomSafeAreaView: UIView!
    @IBOutlet private weak var bottomBarContainer: UIView!
    
    private var adjustView: UIView?
    
    private(set) lazy var tabbar: PhotoEditTabbar = {
        let tabbar = PhotoEditTabbar.initFromNib()
        tabbar.setup(with: [.filters, .adjustments, .gif, .sticker])
        tabbar.delegate = self
        return tabbar
    }()
    
    private(set) lazy var navBarView = PhotoEditNavbar.initFromNib()
    
    private lazy var adjustmentCategoriesView = AdjustmentCategoriesView.with(delegate: self)
    private var changesBar: PhotoEditChangesBar?
    
    private lazy var animator = ContentAnimator()
    private(set) var currentPhotoEditViewType: PhotoEditViewType?
    
    weak var delegate: PhotoEditViewUIManagerDelegate?
    
    var image: UIImage? {
        didSet {
            DispatchQueue.main.async {
                self.imageScrollView.imageView.image = self.image
            }
        }
    }

    private var isFullScreen = false

    var hasStickers: Bool {
        return imageScrollView.imageView.hasStickers
    }
    
    //MARK: -
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageScrollView.imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1).activate()
        imageScrollView.imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 1).activate()
        
        contentView.backgroundColor = .black
        filtersScrollView.backgroundColor = ColorConstants.photoEditBackgroundColor
        bottomSafeAreaView.backgroundColor = ColorConstants.photoEditBackgroundColor
        bottomBarContainer.backgroundColor = ColorConstants.photoEditBackgroundColor

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        imageScrollView.imageView.addGestureRecognizer(tapGesture)
    }
    
    func showInitialState() {
        currentPhotoEditViewType = nil
        showTabBarItemView(tabbar.selectedType)
        hideAdjustView()
        animator.showTransition(to: navBarView, on: navBarContainer, animated: true)
        animator.showTransition(to: tabbar, on: bottomBarContainer, animated: true)
    }
    
    func setHiddenBottomViews(_ isHidden: Bool) {
        UIView.animate(withDuration: NumericConstants.animationDuration) { [weak self] in
            self?.tabbar.alpha = isHidden ? 0 : 1
            self?.filtersContainerView.alpha = isHidden ? 0 : 1
        }
    }

    func addAttachment(item: SmashStickerResponse, attachmentType: AttachedEntityType, completion: @escaping VoidHandler) {
        imageScrollView.imageView.addAttachment(item: item, attachmentType: attachmentType, completion: completion)
    }

    func removeAllAttachments() {
        imageScrollView.imageView.removeAll()
    }
    
    private func showTabBarItemView(_ item: PhotoEditTabbarItemType) {
        switch item {
        case .filters:
            if let filtersView = delegate?.filtersView() {
                animator.showTransition(to: filtersView, on: filtersContainerView, animated: true)
            }
        case .adjustments:
            animator.showTransition(to: adjustmentCategoriesView, on: filtersContainerView, animated: true)

        case .gif:
            if let gifView = delegate?.gifSelectorView() {
                animator.showTransition(to: gifView, on: filtersContainerView, animated: true)
            }

        case .sticker:
            if let stickerView = delegate?.stickerSelectorView() {
                animator.showTransition(to: stickerView, on: filtersContainerView, animated: true)
            }
        }
    }
    
    private func showAdjustView(_ view: UIView) {
        if adjustView == view {
            adjustView?.isHidden = false
            return
        }
        
        adjustView = view
        view.frame = contentView.bounds
        contentView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.pinToSuperviewEdges()
    }
    
    private func hideAdjustView() {
        adjustView?.isHidden = true
    }

    @objc private func imageTapped() {
        isFullScreen = !isFullScreen
        setTopAndBottomBarsHidden(isFullScreen)
    }

    private func setTopAndBottomBarsHidden(_ isHidden: Bool, animated: Bool = true) {
        UIView.animate(withDuration: NumericConstants.fastAnimationDuration) {
            let alpha: CGFloat = isHidden ? 0 : 1
            self.navBarContainer.alpha = alpha
            self.containerView.alpha = alpha
            self.bottomBarContainer.alpha = alpha
            self.bottomSafeAreaView.alpha = alpha
        }
    }
}

//MARK: - PhotoEditTabbarDelegate

extension PhotoEditViewUIManager: PhotoEditTabbarDelegate {
    func didSelectItem(_ item: PhotoEditTabbarItemType) {
        showTabBarItemView(item)
        delegate?.didSwitchTabBarItem(item)
    }
}

//MARK: - FilterCategoriesViewDelegate

extension PhotoEditViewUIManager: AdjustmentCategoriesViewDelegate {
    func didSelectCategory(_ category: AdjustmentCategory) {
        let viewType: AdjustmentViewType
        
        switch category {
        case .adjust:
            viewType = .adjust
        case .color:
            viewType = .color
        case .effect:
            viewType = .effect
        case .light:
            viewType = .light
        }
        
        delegate?.needShowAdjustmentView(for: viewType)
    }
    
    func showView(type: PhotoEditViewType, view: UIView, changesBar: PhotoEditChangesBar) {
        currentPhotoEditViewType = type
        
        if case PhotoEditViewType.adjustmentView(let viewType) = type, viewType == .adjust {
            showAdjustView(view)
            let emptyView = UIView(frame: .zero)
            emptyView.heightAnchor.constraint(equalToConstant: 0).activate()
            animator.showTransition(to: emptyView, on: filtersContainerView, animated: true)
        } else {
            animator.showTransition(to: view, on: filtersContainerView, animated: true)
        }

        animator.showTransition(to: changesBar, on: bottomBarContainer, animated: true)
        navBarView.state = .empty
    }
}

extension PhotoEditViewUIManager: OverlayStickerImageViewDelegate {
    func makeTopAndBottomBarsIsHidden(isHidden: Bool) {
        guard !isFullScreen else { return }
        setTopAndBottomBarsHidden(isHidden)
    }

    func didDeleteAttachments(_ attachments: [SmashStickerResponse]) {
        delegate?.didRemoveAttachment()
    }
}

//MARK: - ContentAnimator

private final class ContentAnimator {
    
    func showTransition(to newView: UIView, on contentView: UIView, animated: Bool) {
        let currentView = contentView.subviews.first
        
        guard newView != currentView else {
            return
        }
        
        DispatchQueue.main.async {
            let updateContentConstaints: VoidHandler = {
                newView.translatesAutoresizingMaskIntoConstraints = false
                newView.pinToSuperviewEdges()
                contentView.layoutIfNeeded()
            }
            
            newView.frame.size.width = contentView.frame.width
            contentView.frame.origin.y += contentView.frame.height - newView.frame.height
            contentView.frame.size.height = newView.frame.height
            
            if let oldView = currentView {
                oldView.frame = newView.bounds
                let duration = 0.0//animated ? 0.25 : 0.0
                UIView.transition(from: oldView, to: newView, duration: duration, options: [.curveLinear], completion: { _ in
                    updateContentConstaints()
                })
            } else {
                contentView.addSubview(newView)
                updateContentConstaints()
            }
        }
    }
}
