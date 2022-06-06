//
//  BasicCollectionMultiFileCell.swift
//  Depo
//
//  Created by Aleksandr on 6/28/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

protocol BasicCollectionMultiFileCellActionDelegate: AnyObject {
    func morebuttonGotPressed(sender: Any, itemModel: Item?)
    func onSelectMoreAction(type: ActionType, itemModel: Item?, sender: Any?)
}

class BasicCollectionMultiFileCell: BaseCollectionViewCell {
    
    private var smallSelectionImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
    
    @IBOutlet weak var bottomSeparator: UIView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var cellContentView: UIView!
    @IBOutlet weak var barView: UIView!
    @IBOutlet weak var smallContentImageView: SelectionImageView!
    @IBOutlet weak var bigContentImageView: UIImageView!
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var moreView: UIView!
    @IBOutlet weak var moreButton: ExtendedTapAreaButton!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var gridselectionImageView: UIImageView! //grid selection
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var smallCellSelectionView: UIImageView!
    @IBOutlet weak var smallSelectonView: UIView!
    @IBOutlet weak var bigSelectionView: UIView!
    @IBOutlet weak var bottomFavoritesStar: UIImageView!
    @IBOutlet weak var sharedIcon: UIImageView!
    @IBOutlet weak var gridCellFavIcon: UIImageView!
    @IBOutlet weak var gridCellShareIcon: UIImageView!
    
    @IBOutlet weak var bottomViewH: NSLayoutConstraint!
    @IBOutlet weak var smallContentImageViewW: NSLayoutConstraint!
    @IBOutlet weak var smallContentImageViewH: NSLayoutConstraint!
    @IBOutlet weak var leftSpaceForSmallmage: NSLayoutConstraint!
    @IBOutlet weak var moreButtonTrailingConst: NSLayoutConstraint!
    
    @IBOutlet private weak var shadowView: UIView! {
        willSet {
            newValue.addRoundedShadows(cornerRadius: 12,
                                       shadowColor: AppColor.filesBigCellShadow.cgColor,
                                       opacity: 0.8, radius: 6.0)
        }
    }
    
    @IBOutlet private weak var gridCellInfoView: UIStackView! {
        willSet {
            newValue.spacing = 2
        }
    }
    
    @IBOutlet private weak var gridCellFileNameLabel: UILabel! {
        willSet {
            newValue.font = UIFont.appFont(.medium, size: 12)
            newValue.textColor = AppColor.filesLabel.color
        }
    }
    
    @IBOutlet private weak var gridCellDetailLabel: UILabel! {
        willSet {
            newValue.font = UIFont.appFont(.light, size: 14)
            newValue.textColor = AppColor.filesLabel.color
        }
    }
    
    override weak var delegate: LBCellsDelegate? {
        didSet {
            if let compatableValue = delegate as? BasicCollectionMultiFileCellActionDelegate {
                actionDelegate = compatableValue
            }
        }
    }
    
    weak var actionDelegate: BasicCollectionMultiFileCellActionDelegate?
    
    static let smallH: CGFloat = 37
    static let bigH: CGFloat = 65
    static let frameSize: CGFloat = 66
    
    static let smallContentImageViewWConst: CGFloat = 24
    static let smallContentImageViewHConst: CGFloat = 24
    static let smallContentImageViewBigSize: CGFloat = 42
    static let bigContentImageViewSize: CGFloat = 48
    
    static let leftSpaceBigCell: CGFloat = 6
    static let leftSpaceSmallCell: CGFloat = 14
    
    var itemModel: Item?
    var filesDataSource: FilesDataSource?
    private var cellImageManager: CellImageManager?
    private var uuid: String?
    private var detailsLabelText = ""
    
    var canShowSharedIcon = true

    override func setImage(image: UIImage?, animated: Bool) {
        isAlreadyConfigured = true

        if (isBigSize()) {
            bigContentImageView.contentMode = .scaleAspectFill
            bigContentImageView.image = image
        } else {
            smallContentImageView.contentMode = .scaleAspectFill
            smallContentImageView.clipsToBounds = true
            smallContentImageView.configured = true
            smallContentImageView.setImage(image: image)
            smallContentImageView.isHidden = false
            smallCellSelectionView.isHidden = true
        }
    }

    private func isBigSize() -> Bool {
        return frame.size.height > BasicCollectionMultiFileCell.frameSize
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        bigContentImageView.sd_cancelCurrentImageLoad()
        smallContentImageView.sd_cancelCurrentImageLoad()
        cellImageManager?.cancelImageLoading()
    }
    
    override func configureWithWrapper(wrappedObj: BaseDataSourceItem) {
        guard let wrappered = wrappedObj as? Item, !isAlreadyConfigured else {
            return
        }
        
        itemModel = wrappered
        
        fileNameLabel.text = wrappedObj.name
        fileNameLabel.isHidden = isBigSize()
        gridCellInfoView.isHidden = !isBigSize()
        gridCellFileNameLabel.text = wrappedObj.name
        moreButtonTrailingConst.constant =  isBigSize() ? 4 : 16
        shadowView.isHidden = !isBigSize()
        cellContentView.isHidden = !isBigSize()
        
        configureDetailLabel(with: wrappedObj)
        
        if !isBigSize() {
            detailsLabel.text = detailsLabelText
            detailsLabel.isHidden = detailsLabelText.isEmpty
        } else {
            detailsLabel.isHidden = true
            gridCellDetailLabel.text = detailsLabelText
        }

        bigContentImageView.image = nil
        bigContentImageView.image = WrapperedItemUtil.getSmallPreviewImageForWrapperedObject(fileType: wrappered.fileType)
        if isCellSelectionEnabled {
            smallContentImageView.image = Image.iconSelectEmpty.image
        } else {
            smallContentImageView.image = WrapperedItemUtil.getSmallPreviewImageForWrapperedObject(fileType: wrappered.fileType)
        }
        smallContentImageView.contentMode = .center
        
        bigContentImageView.contentMode = .center

        separatorView.isHidden = isBigSize()
        barView.backgroundColor = isBigSize() ? UIColor.white : AppColor.primaryBackground.color
        
        //Big size (Grid)
        if isBigSize() && bottomViewH.constant != BasicCollectionMultiFileCell.smallH {
            bottomViewH.constant = BasicCollectionMultiFileCell.smallH
            
            smallContentImageViewW.constant = BasicCollectionMultiFileCell.smallContentImageViewWConst
            smallContentImageViewH.constant = BasicCollectionMultiFileCell.smallContentImageViewHConst
            leftSpaceForSmallmage.constant = BasicCollectionMultiFileCell.leftSpaceBigCell
            
            layoutIfNeeded()
        }
        
        //Small size (list)
        if !isBigSize() && bottomViewH.constant != BasicCollectionMultiFileCell.bigH {
            bottomViewH.constant = BasicCollectionMultiFileCell.bigH
            
            smallContentImageViewW.constant = BasicCollectionMultiFileCell.smallContentImageViewBigSize
            smallContentImageViewH.constant = BasicCollectionMultiFileCell.smallContentImageViewBigSize
            leftSpaceForSmallmage.constant = BasicCollectionMultiFileCell.leftSpaceSmallCell
            
            fileNameLabel.font = UIFont.appFont(.regular, size: 14)
            detailsLabel.font = UIFont.appFont(.regular, size: 12)
            layoutIfNeeded()
        }
        
        gridCellFavIcon.isHidden = !wrappered.favorites
        bottomFavoritesStar.isHidden = !wrappered.favorites
        if isBigSize() {
            bottomFavoritesStar.isHidden = true
            sharedIcon.isHidden = true
            gridCellShareIcon.isHidden = !wrappered.isShared
        } else {
            gridCellFavIcon.isHidden = true
            sharedIcon.isHidden = !wrappered.isShared || !canShowSharedIcon
            gridCellShareIcon.isHidden = true
        }
    
        
        if isCellSelected, !isBigSize() {
            var isHidden = !isImageOrVideoType(wrappered.fileType)
            if wrappered.fileType == .audio, smallContentImageView.configured {
                isHidden = !isSelected
            }
            setSelectionSmallSelectionImageView(isSelected, isHidden: isHidden)
        }
        
        configureMoreActionButton()
    }
    
    private func configureDetailLabel(with wrappedObj: BaseDataSourceItem) {
        guard let wrappered = wrappedObj as? Item, !isAlreadyConfigured else {
            return
        }
        
        switch wrappered.fileType {
        case .folder:
            if let itemCount = wrappered.childCount {
                detailsLabelText = String(format: TextConstants.folderItemsText, itemCount)
            } else {
                detailsLabelText = String(format: TextConstants.folderItemsText, 0)
            }
        case .audio, .video:
            if let duration = wrappered.duration {
                detailsLabelText = duration
            }
        default:
            break
        }
    }
    
    override func setSelection(isSelectionActive: Bool, isSelected: Bool) {
        smallCellSelectionView.isHidden = true
        moreView.isHidden = isSelectionActive
        moreView.backgroundColor = isBigSize() ? AppColor.secondaryBackground.color : AppColor.primaryBackground.color
        smallContentImageView.isHidden = false
        
        if let isFavorite = itemModel?.favorites {
            if isBigSize() {
                gridCellFavIcon.isHidden = !isFavorite
                bottomFavoritesStar.isHidden = true
            } else {
                gridCellFavIcon.isHidden = true
                bottomFavoritesStar.isHidden = !isFavorite
            }
        } else {
            gridCellFavIcon.isHidden = true
            bottomFavoritesStar.isHidden = true
        }
        
        isCellSelected = isSelected
        isCellSelectionEnabled = isSelectionActive
        gridselectionImageView.isHidden = !isSelectionActive

        if isSelectionActive {
            if !smallContentImageView.configured {
                smallContentImageView.image = Image.iconSelectEmpty.image
                smallCellSelectionView.isHidden = !isSelected
                smallContentImageView.isHidden = isSelected
            }
            //because if we have image for object and object is not selected we should not show empty circle in top right corner of image
            smallContentImageView.setSelection(selection: isSelected, showSelectonBorder: isSelected)
            setSelectionSmallSelectionImageView(isSelected, isHidden: !isSelected)
        } else {
            if !smallContentImageView.configured {
                smallContentImageView.image = WrapperedItemUtil.getSmallPreviewImageForWrapperedObject(fileType: itemModel?.fileType ?? .unknown)
            }
            smallContentImageView.setSelection(selection: false, showSelectonBorder: false)
            setSelectionSmallSelectionImageView(false, isHidden: true)
        }
                
        if let item = itemModel, isCellSelected, !isBigSize() {
            var isHidden = !isImageOrVideoType(item.fileType)
            if item.fileType == .audio, smallContentImageView.configured {
                //we need show small selection icon for audio items if load image
                isHidden = !isSelected
            }
            setSelectionSmallSelectionImageView(isSelected, isHidden: isHidden)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bgView.layer.cornerRadius = 8
        bigContentImageView.clipsToBounds = true
        
        smallCellSelectionView.contentMode = .center
        
//        smallSelectonView.layer.borderWidth = 3
//        smallSelectonView.layer.borderColor = AppColor.darkBlueAndTealish.color.cgColor
//        smallSelectonView.alpha = 0
        
        bigSelectionView.layer.borderWidth = 3
        bigSelectionView.layer.borderColor = AppColor.darkBlueAndTealish.color.cgColor
        bigSelectionView.alpha = 0
        
        fileNameLabel.font = UIFont.appFont(.regular, size: 14)
        fileNameLabel.textColor = AppColor.filesLabel.color
        
        detailsLabel.font = UIFont.appFont(.regular, size: 12)
        detailsLabel.textColor = AppColor.filesLabel.color
        
        moreButton.accessibilityLabel = TextConstants.accessibilityMore
        
//        configureSmallSelectionImageView()
        setSelectionSmallSelectionImageView(false, isHidden: true)
        
        sharedIcon.isHidden = true
    }
    
    override func updating() {
        super.updating()
        smallContentImageView.configured = false
        smallContentImageView.setSelection(selection: false, showSelectonBorder: false)
        setSelectionSmallSelectionImageView(false, isHidden: true)
    }
    
    override func set(name: String?) {
        super.set(name: name)
        DispatchQueue.toMain {
            self.fileNameLabel.text = name
        }
    }
    
    @IBAction func moreButtonAction(_ sender: Any) {
        actionDelegate?.morebuttonGotPressed(sender: sender, itemModel: itemModel)
    }
    
    // MARK: - Utility methods
    
    private func setSelectionSmallSelectionImageView(_ isSelected: Bool, isHidden: Bool) {
        smallSelectionImageView.isHidden = isHidden
        smallSelectionImageView.image = Image.iconSelectCheck.image
    }
    
    private func configureSmallSelectionImageView() {
        addSubview(smallSelectionImageView)
        smallSelectionImageView.translatesAutoresizingMaskIntoConstraints = false
        
        smallSelectionImageView.rightAnchor.constraint(equalTo: smallContentImageView.rightAnchor, constant: smallSelectionImageView.bounds.width /  2).isActive = true
        smallSelectionImageView.topAnchor.constraint(equalTo: smallContentImageView.topAnchor, constant: -(smallContentImageView.bounds.height / 4)).isActive = true
    }
    
    private func isImageOrVideoType(_ type: FileType) -> Bool {
        switch type {
        case .image:
            return true
        case .video:
            return true
        default:
            return false
        }
    }

    
    func loadImage(item: Item, indexPath: IndexPath) {
        switch item.patchToPreview {
        case .localMediaContent(let local):
            setAssetId(local.asset.localIdentifier)
            filesDataSource?.getAssetThumbnail(asset: local.asset, indexPath: indexPath, completion: { [weak self] image, path in
                guard let self = self else {
                    return
                }
                
                DispatchQueue.main.async {
                    if self.getAssetId() == local.asset.localIdentifier, let image = image {
                        self.setImage(image: image, animated:  false)
                    } else {
                        self.setPlaceholderImage(fileType: item.fileType)
                    }
                }
            })
            
        case .remoteUrl(let url) :
            if let url = url {
                setImage(with: url)
            } else {
                setPlaceholderImage(fileType: item.fileType)
            }
        }
    }
    
    override func setImage(with url: URL) {
        guard let item = itemModel else {
            return
        }
        
        let cacheKey = url.byTrimmingQuery
        cellImageManager = CellImageManager.instance(by: cacheKey)
        uuid = cellImageManager?.uniqueId
        let imageSetBlock: CellImageManagerOperationsFinished = { [weak self] image, cached, shouldBeBlurred, uniqueId in
            DispatchQueue.main.async {
                guard let image = image, let uuid = self?.uuid, uuid == uniqueId else {
                    return
                }
                
                self?.setImage(image: image, animated: false)
            }
        }
        
        cellImageManager?.loadImage(item: item, thumbnailUrl: nil, url: url, completionBlock: imageSetBlock)
        
        isAlreadyConfigured = true
    }
    
    override func cleanCell() {
        cellImageManager?.cancelImageLoading()
    }
    
    private func configureMoreActionButton() {
        if #available(iOS 14.0, *) {
            moreButton.showsMenuAsPrimaryAction = true

            guard let item = itemModel else {
                return
            }
            
            let menu = MenuItemsFabric.generateMenu(for: item, status: item.status) { [weak self] actionType in
                self?.actionDelegate?.onSelectMoreAction(type: actionType, itemModel: self?.itemModel, sender: self?.moreButton)
            }
            moreButton.menu = menu
        } else {
            moreButton.addTarget(self, action: #selector(moreButtonAction(_:)), for: .touchUpInside)
        }
    }
}
