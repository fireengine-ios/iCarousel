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
    
    @IBOutlet weak var selectionImageView: UIImageView!
    
    @IBOutlet weak var separatorView: UIView!
    
    @IBOutlet weak var smallCellSelectionView: UIImageView!
    
    @IBOutlet weak var bottomViewH: NSLayoutConstraint!
    @IBOutlet weak var smallContentImageViewW: NSLayoutConstraint!
    @IBOutlet weak var smallContentImageViewH: NSLayoutConstraint!
    @IBOutlet weak var leftSpaceForSmallmage: NSLayoutConstraint!
    
    @IBOutlet weak var smallSelectonView: UIView!
    @IBOutlet weak var bigSelectionView: UIView!
    @IBOutlet weak var topFavoritesStar: UIImageView!
    @IBOutlet weak var bottomFavoritesStar: UIImageView!
    @IBOutlet weak var sharedIcon: UIImageView!
    
    
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
    
    static let smallContentImageViewWConst: CGFloat = 20
    static let smallContentImageViewHConst: CGFloat = 24
    static let smallContentImageViewBigSize: CGFloat = 42
    
    static let leftSpaceBigCell: CGFloat = 6
    static let leftSpaceSmallCell: CGFloat = 14
    
    var itemModel: Item?
    var filesDataSource: FilesDataSource?
    private var cellImageManager: CellImageManager?
    private var uuid: String?
    
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
        
        if !isBigSize() {
            var detailsLabelText = ""
            
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
            detailsLabel.text = detailsLabelText
            detailsLabel.isHidden = detailsLabelText.isEmpty
        } else {
            detailsLabel.isHidden = true
        }

        bigContentImageView.image = nil
        bigContentImageView.image = WrapperedItemUtil.getPreviewImageForWrapperedObject(fileType: wrappered.fileType)
        if isBigSize() {
            smallContentImageView.image = WrapperedItemUtil.getSmallPreviewImageForWrapperedObject(fileType: wrappered.fileType)
            smallContentImageView.contentMode = .scaleAspectFit
        } else {
            if isCellSelectionEnabled {
                smallContentImageView.image = WrapperedItemUtil.getSmallPreviewImageForNotSelectedWrapperedObject(fileType: wrappered.fileType)
            } else {
                smallContentImageView.image = WrapperedItemUtil.getSmallPreviewImageForWrapperedObject(fileType: wrappered.fileType)
            }
            smallContentImageView.contentMode = .center
        }
        
        bigContentImageView.contentMode = .center

        separatorView.isHidden = isBigSize()
        barView.backgroundColor = isBigSize() ? ColorConstants.fileGreedCellColorSecondary : AppColor.primaryBackground.color
        
        //Big size (Grid)
        if isBigSize() && bottomViewH.constant != BasicCollectionMultiFileCell.smallH {
            bottomViewH.constant = BasicCollectionMultiFileCell.smallH
            
            smallContentImageViewW.constant = BasicCollectionMultiFileCell.smallContentImageViewWConst
            smallContentImageViewH.constant = BasicCollectionMultiFileCell.smallContentImageViewHConst
            
            leftSpaceForSmallmage.constant = BasicCollectionMultiFileCell.leftSpaceBigCell
            
            fileNameLabel.font = UIFont.TurkcellSaturaRegFont(size: 10)
            detailsLabel.font = UIFont.TurkcellSaturaRegFont(size: 10)
            
            layoutIfNeeded()
        }
        
        //Small size (list)
        if !isBigSize() && bottomViewH.constant != BasicCollectionMultiFileCell.bigH {
            bottomViewH.constant = BasicCollectionMultiFileCell.bigH
            
            smallContentImageViewW.constant = BasicCollectionMultiFileCell.smallContentImageViewBigSize
            smallContentImageViewH.constant = BasicCollectionMultiFileCell.smallContentImageViewBigSize
            
            leftSpaceForSmallmage.constant = BasicCollectionMultiFileCell.leftSpaceSmallCell
            
            fileNameLabel.font = UIFont.TurkcellSaturaRegFont(size: 18)
            detailsLabel.font = UIFont.TurkcellSaturaRegFont(size: 18)
            layoutIfNeeded()
        }
        
        topFavoritesStar.isHidden = !wrappered.favorites
        bottomFavoritesStar.isHidden = !wrappered.favorites
        if isBigSize() {
            bottomFavoritesStar.isHidden = true
            sharedIcon.isHidden = true
        } else {
            topFavoritesStar.isHidden = true
            sharedIcon.isHidden = !wrappered.isShared || !canShowSharedIcon
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
    
    override func setSelection(isSelectionActive: Bool, isSelected: Bool) {
        smallCellSelectionView.isHidden = true
        moreView.isHidden = isSelectionActive
        moreView.backgroundColor = isBigSize() ? AppColor.secondaryBackground.color : AppColor.primaryBackground.color
        smallContentImageView.isHidden = false
        
        if let isFavorite = itemModel?.favorites {
            if isBigSize() {
                topFavoritesStar.isHidden = !isFavorite
                bottomFavoritesStar.isHidden = true
            } else {
                topFavoritesStar.isHidden = true
                bottomFavoritesStar.isHidden = !isFavorite
            }
        } else {
            topFavoritesStar.isHidden = true
            bottomFavoritesStar.isHidden = true
        }
        
        isCellSelected = isSelected
        isCellSelectionEnabled = isSelectionActive
        selectionImageView.isHidden = !isSelectionActive
        var bgColor: UIColor = AppColor.secondaryBackground.color
        if isSelectionActive {
            selectionImageView.image = UIImage(named: isSelected ? "selected" : "notSelected")
            
            selectionImageView.accessibilityLabel = isSelected ? TextConstants.accessibilitySelected : TextConstants.accessibilityNotSelected
            if isBigSize() {
                UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
                    self.bigSelectionView.alpha = isSelected ? 1 : 0
                })
                smallContentImageView.setSelection(selection: false, showSelectonBorder: false)
                setSelectionSmallSelectionImageView(false, isHidden: true)
            } else {
                bigSelectionView.alpha = 0
                bgColor = AppColor.secondaryBackground.color
                if !smallContentImageView.configured {
                    smallContentImageView.image = WrapperedItemUtil.getSmallPreviewImageForNotSelectedWrapperedObject(fileType: itemModel?.fileType ?? .unknown)
                    smallCellSelectionView.isHidden = !isSelected
                    smallContentImageView.isHidden = isSelected
                }
                //because if we have image for object and object is not selected we should not show empty circle in top right corner of image
                smallContentImageView.setSelection(selection: isSelected, showSelectonBorder: isSelected)
                setSelectionSmallSelectionImageView(isSelected, isHidden: !isSelected)
            }
        } else {
            if isBigSize() {
                bgColor = ColorConstants.fileGreedCellColorSecondary
                if self.bigSelectionView.alpha != 0 {
                    UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
                        self.bigSelectionView.alpha = 0
                    })
                }
            } else {
                if !smallContentImageView.configured {
                    smallContentImageView.image = WrapperedItemUtil.getSmallPreviewImageForWrapperedObject(fileType: itemModel?.fileType ?? .unknown)
                }
                bgColor = AppColor.primaryBackground.color
            }
            smallContentImageView.setSelection(selection: false, showSelectonBorder: false)
            setSelectionSmallSelectionImageView(false, isHidden: true)
        }
        
        bgView.backgroundColor = bgColor
        
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
        
        bigContentImageView.clipsToBounds = true
        
        smallCellSelectionView.contentMode = .center
        
        smallSelectonView.layer.borderWidth = 3
        smallSelectonView.layer.borderColor = AppColor.darkBlueAndTealish.color.cgColor
        smallSelectonView.alpha = 0
        
        bigSelectionView.layer.borderWidth = 3
        bigSelectionView.layer.borderColor = AppColor.darkBlueAndTealish.color.cgColor
        bigSelectionView.alpha = 0
        
        fileNameLabel.font = UIFont.TurkcellSaturaRegFont(size: 10)
        fileNameLabel.textColor = ColorConstants.textGrayColor
        
        detailsLabel.font = UIFont.TurkcellSaturaRegFont(size: 10)
        
        moreButton.accessibilityLabel = TextConstants.accessibilityMore
        
        configureSmallSelectionImageView()
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
        smallSelectionImageView.image = UIImage(named: "selected")
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
