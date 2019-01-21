import UIKit

final class PhotoCell: UICollectionViewCell {
    
    private enum Constants {
        static let favoriteImageViewSideSize: CGFloat = 24
        static let edgeInset: CGFloat = 6
        static let selectionBorderWidth: CGFloat = 3
        
        static let checkmarkFillImage = UIImage(named: "selected")
        static let checkmarkEmptyImage = UIImage(named: "notSelected")
    }
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        //imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        imageView.isOpaque = true
        return imageView
    }()
    
    private let selectionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let favoriteImageView: UIImageView = {
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
    
    //private var representedAssetIdentifier = ""
    
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
        addSubview(favoriteImageView)
        layer.borderColor = UIColor.red.cgColor
        
        layer.borderColor = ColorConstants.darcBlueColor.cgColor
        
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
        selectionImageView.frame = CGRect(x: bounds.width - Constants.favoriteImageViewSideSize - Constants.edgeInset,
                                          y: Constants.edgeInset,
                                          width: Constants.favoriteImageViewSideSize,
                                          height: Constants.favoriteImageViewSideSize)
        favoriteImageView.frame = CGRect(x: Constants.edgeInset,
                                         y: Constants.edgeInset,
                                         width: Constants.favoriteImageViewSideSize,
                                         height: Constants.favoriteImageViewSideSize)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        selectionImageView.image = nil
        favoriteImageView.isHidden = true
        cellImageManager = nil
    }
    
    func update(for selectionState: PhotoSelectionController.SelectionState) {
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
}

final class CollectionSpinnerFooter: UICollectionReusableView {
    
    private let activityIndicator: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activity.startAnimating()
        activity.hidesWhenStopped = true
        //activity.color = UIColor.red
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
        backgroundColor = .white
        addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        activityIndicator.center = center
    }
    
    func startSpinner() {
        activityIndicator.startAnimating()
        isHidden = false
    }
    
    func stopSpinner() {
        activityIndicator.stopAnimating()
    }
}


import Foundation

final class PhotoService {
    
    private var photos: [WebPhoto]?
    
    func loadPhotos(page: Int, size: Int, handler: @escaping ([WebPhoto]) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            
            if page == 3 {
                DispatchQueue.main.async {
                    handler([])
                }
                return
            }
            
            guard let photos = self.getPhotos() else {
                DispatchQueue.main.async {
                    handler([])
                }
                return
            }
            
            let result: [WebPhoto]
            let offset = page * size
            let photosLeft = photos.count - offset
            
            if photosLeft <= 0 {
                result = []
            } else {
                
                if photosLeft < size {
                    result = Array(photos[offset ..< offset + photosLeft])
                    self.photos = nil
                } else {
                    let pageLimit = (page + 1) * size
                    result = Array(photos[offset ..< pageLimit])
                }
            }
            
            DispatchQueue.main.async {
                handler(result)
            }
        }
    }
    
    private func getPhotos() -> [WebPhoto]? {
        if let photos = photos {
            return photos
        } else {
            guard
                let file = Bundle.main.url(forResource: "photos", withExtension: "json"),
                let data = try? Data(contentsOf: file),
                let photos = try? JSONDecoder().decode([WebPhoto].self, from: data)
                else {
//                    assertionFailure()
                    return nil
            }
            self.photos = photos
            return photos
        }
        
    }
}

struct WebPhoto: Decodable {
    let thumbnailUrl: URL
    let url: URL
}
extension WebPhoto: Equatable {
    static func == (lhs: WebPhoto, rhs: WebPhoto) -> Bool {
        return lhs.thumbnailUrl == rhs.thumbnailUrl && lhs.url == rhs.url
    }
}
extension WebPhoto: Hashable {
    var hashValue: Int {
        return thumbnailUrl.hashValue// + url.hashValue
    }
}
