import UIKit

protocol InstapickAlbumSelectionDelegate: AnyObject {
    func onSelectAlbum(_ album: AlbumItem)
}

final class InstapickAlbumSelectionViewController: UIViewController, ErrorPresenter {
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        collectionView.backgroundView = emptyMessageLabel
        emptyMessageLabel.frame = collectionView.bounds
        return collectionView
    }()
    
    private let emptyMessageLabel: InsetsLabel = {
        let label = InsetsLabel()
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = ColorConstants.textGrayColor
        label.font = UIFont.TurkcellSaturaRegFont(size: 14)
        label.text = TextConstants.loading
        label.insets = UIEdgeInsets(top: 5, left: 30, bottom: 5, right: 30)
        return label
    }()
    
    private let albumService = AlbumService(requestSize: 100)
    private let dataSource = InstapickAlbumSelectionDataSource()
    
    private let refresher = UIRefreshControl()
    
    private weak var delegate: InstapickAlbumSelectionDelegate?
    
    // MARK: - Life cycle
    
    init(title: String, delegate: InstapickAlbumSelectionDelegate?) {
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
        self.title = title
    }
    
    /// will never be called
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        loadAlbums()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    private func configure() {
        view.addSubview(collectionView)
        dataSource.setupCollectionView(collectionView: collectionView)
        dataSource.delegate = self
        
        refresher.tintColor = .clear
        refresher.addTarget(self, action: #selector(loadAlbums), for: .valueChanged)
        collectionView.addSubview(refresher)
    }
    
    // MARK: - Functions
    
    @objc private func loadAlbums() {
        if refresher.isRefreshing {
            refresher.endRefreshing()
        }
        
        emptyMessageLabel.text = TextConstants.loading
        collectionView.backgroundView = emptyMessageLabel
        
        albumService.allAlbums(sortBy: .date, sortOrder: .desc, success: { [weak self] albums in
            guard let `self` = self else { return }
            
            DispatchQueue.toMain {
                self.dataSource.reload(with: albums)
                
                if albums.isEmpty {
                    self.emptyMessageLabel.text = TextConstants.thereAreNoAlbums
                } else {
                    self.collectionView.backgroundView = nil
                }
            }
        }, fail: { [weak self] in
            DispatchQueue.toMain {
                self?.showErrorAlert(message: TextConstants.errorErrorToGetAlbums)
            }
        })
    }
}

extension InstapickAlbumSelectionViewController: InstapickAlbumSelectionDataSourceDelegate {
    func onSelectAlbum(_ album: AlbumItem) {
        delegate?.onSelectAlbum(album)
    }
}
