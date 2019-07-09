import UIKit

final class PhotoCell: UICollectionViewCell {
    
    private enum Constants {
        static let selectionImageViewSideSize: CGFloat = 24
        static let favoriteImageViewSideSize: CGFloat = 13
        static let edgeInset: CGFloat = 6
        static let selectionBorderWidth: CGFloat = 3
        
        static let checkmarkFillImage = UIImage(named: "selected")
        static let checkmarkEmptyImage = UIImage(named: "notSelected")
    }
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.backgroundColor = ColorConstants.photoCell
        imageView.isOpaque = true
        return imageView
    }()
    
    private let selectionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let favouriteImageView: UIImageView = {
        let rect = CGRect(x: 0, y: 0,
                          width: Constants.favoriteImageViewSideSize,
                          height: Constants.favoriteImageViewSideSize)
        let imageView = UIImageView(frame: rect)
        imageView.isHidden = true
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "favoriteStar")
        return imageView
    }()
    
    private var cellImageManager: CellImageManager?
    private var uuid: String?
    
    
    var isNeedToUpdate: Bool {
        return imageView.image == nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        addSubview(imageView)
        addSubview(selectionImageView)
        addSubview(favouriteImageView)
        
        layer.borderColor = ColorConstants.darkBlueColor.cgColor
        
        // TODO: setup accessibility
        //favoriteImageView.accessibilityLabel = TextConstants.accessibilityFavorite
        isAccessibilityElement = true
        accessibilityTraits = UIAccessibilityTraitImage
        //accessibilityLabel = wrappered.name
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateFrames()
    }
    
    private func updateFrames() {
        imageView.frame = bounds
        selectionImageView.frame = CGRect(x: bounds.width - Constants.selectionImageViewSideSize - Constants.edgeInset,
                                          y: Constants.edgeInset,
                                          width: Constants.selectionImageViewSideSize,
                                          height: Constants.selectionImageViewSideSize)
        favouriteImageView.frame = CGRect(x: Constants.edgeInset,
                                         y: Constants.edgeInset,
                                         width: Constants.favoriteImageViewSideSize,
                                         height: Constants.favoriteImageViewSideSize)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        selectionImageView.image = nil
        favouriteImageView.isHidden = true
        cellImageManager = nil
    }
    
    func update(for selectionState: PhotoSelectionState) {
        if self.isSelected {
            selectionImageView.image = Constants.checkmarkFillImage
            setViewBorder(isSelected: true)
        } else {
            setViewBorder(isSelected: false)
            switch selectionState {
            case .selecting:
                selectionImageView.image = Constants.checkmarkEmptyImage
                break
            case .ended:
                selectionImageView.image = nil
            }
        }
    }
    
    private func setViewBorder(isSelected: Bool) {
        if isSelected {
            layer.borderWidth = Constants.selectionBorderWidth
        } else {
            layer.borderWidth = 0
        }
    }
    
    func setup(by item: SearchItemResponse) {
        guard let metadata = item.metadata else {
            return
        }
        
        if let isFavourite = metadata.favourite {
            favouriteImageView.isHidden = !isFavourite
        }
        
        // image
        let cacheKey = metadata.mediumUrl?.byTrimmingQuery
        cellImageManager = CellImageManager.instance(by: cacheKey)
        uuid = cellImageManager?.uniqueId
        
        let imageSetBlock: CellImageManagerOperationsFinished = { [weak self] image, cached, shouldBeBlurred, uniqueId in
            DispatchQueue.toMain {
                guard let image = image, let uuid = self?.uuid, uuid == uniqueId else {
                    return
                }
                
                let needAnimate = !cached && (self?.imageView.image == nil)
                self?.setImage(image: image, animated: needAnimate)
            }
        }
        
        cellImageManager?.loadImage(thumbnailUrl: metadata.smalURl, url: metadata.mediumUrl, completionBlock: imageSetBlock)
    }
    
    func setup(by item: Item) {
        guard let metadata = item.metaData else {
            return
        }
        
        if let isFavourite = metadata.favourite {
            favouriteImageView.isHidden = !isFavourite
        }
        
        ///in case server after syncing didn’t had time to create thumbnail
        FilesDataSource().getImage(for: item, isOriginal: false, completeImage: { image in
            if let image = image {
                DispatchQueue.toMain {
                    self.setImage(image: image, animated: false)
                }
            }
        })
    }
    
    private func setImage(image: UIImage?, animated: Bool) {
        if animated {
            imageView.layer.opacity = NumericConstants.numberCellDefaultOpacity
            imageView.image = image
            UIView.animate(withDuration: 0.2, animations: {
                self.imageView.layer.opacity = NumericConstants.numberCellAnimateOpacity
            })
        } else {
            imageView.image = image
        }
    }
    
    func cancelImageLoading() {
        cellImageManager?.cancelImageLoading()
    }
}

final class CollectionSpinnerFooter: UICollectionReusableView {
    
    private let activityIndicator: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activity.hidesWhenStopped = true
        activity.startAnimating()
        return activity
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        addSubview(activityIndicator)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        activityIndicator.center = center
    }
    
    func startSpinner() {
        activityIndicator.startAnimating()
    }
    
    func stopSpinner() {
        activityIndicator.stopAnimating()
    }
}
