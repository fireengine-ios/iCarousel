import UIKit

// TODO: localize
// TODO: error handling
// TODO: paginationSize + test for iPad
// TODO: refactor
// TODO: updaye cell layout UICollectionViewDelegateFlowLayout
final class PhotoSelectionController: UIViewController {
    
    enum SelectionState {
        case selecting
        case ended
    }
    
    private let photoService = PhotoService()
    private let paginationSize = 100
    private var paginationPage = 0
    private var isLoadingMore = false
    private var isLoadingMoreFinished = false
    
    private var selectingLimit = 0
    private var selectionState = SelectionState.selecting
    
    private var photos = [SearchItemResponse]()
    private let cellId = String(describing: PhotoCell.self)
    private let footerId = String(describing: CollectionSpinnerFooter.self)
    
    private lazy var collectionView: UICollectionView = {
        let isIpad = UI_USER_INTERFACE_IDIOM() == .pad
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = isIpad ? 10 : 1
        layout.minimumInteritemSpacing = isIpad ? 10 : 1
        layout.sectionInset = .init(top: 1, left: 1, bottom: 1, right: 1)
        
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(CollectionSpinnerFooter.self,
                                forSupplementaryViewOfKind: UICollectionElementKindSectionFooter,
                                withReuseIdentifier: footerId)
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
        collectionView.allowsMultipleSelection = true
        
        let transparentGradientViewHeight = NumericConstants.instaPickSelectionSegmentedTransparentGradientViewHeight
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: transparentGradientViewHeight, right: 0)
        
        collectionView.backgroundView = emptyMessageLabel
        emptyMessageLabel.frame = collectionView.bounds
        return collectionView
    }()
    
    private lazy var loadingMoreFooterView: CollectionSpinnerFooter? = {
        return collectionView.supplementaryView(forElementKind: UICollectionElementKindSectionFooter, at: IndexPath(item: 0, section: 0)) as? CollectionSpinnerFooter
    }()
    
    private let emptyMessageLabel: UILabel = {
        let label = UILabel()
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.textAlignment = .center
        label.numberOfLines = 0
        //label.textColor
        //label.font
        label.text = "Loading..."
        return label
    }()
    
    convenience init(title: String, selectingLimit: Int) {
        self.init(nibName: nil, bundle: nil)
        self.title = title
        self.selectingLimit = selectingLimit
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(collectionView)
        
        loadMore()
        collectionView.reloadData()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    private func loadMore() {
        if isLoadingMore, isLoadingMoreFinished {
            assertionFailure()
            return
        }
        
        isLoadingMore = true
        
        self.photoService.loadPhotos(page: paginationPage, size: paginationSize, handler: { result in
            
            switch result {
            case .success(let photos):
                
                let newItemsRange = self.photos.count ..< (self.photos.count + photos.count)
                let indexPathesForNewItems = newItemsRange.map({ IndexPath(item: $0, section: 0) })
                self.photos.append(contentsOf: photos)
                
                if !photos.isEmpty {
                    self.collectionView.backgroundView = nil
                }
                
                self.collectionView.performBatchUpdates({
                    self.collectionView.insertItems(at: indexPathesForNewItems)
                }, completion: { _ in
                    self.isLoadingMore = false
                    self.paginationPage += 1
                    let isLoadingMoreFinished = photos.count < self.paginationSize
                    
                    if isLoadingMoreFinished {
                        self.isLoadingMoreFinished = true
                        
                        /// to hide footer view by func referenceSizeForFooterInSection
                        self.collectionView.performBatchUpdates({
                            self.collectionView.collectionViewLayout.invalidateLayout()
                        }, completion: nil)
                        
                        /// just in case stop animation.
                        /// don't forget to start animation if need (for pullToRefresh)
                        self.loadingMoreFooterView?.stopSpinner()
                        
                        /// if we don't have any item in collection
                        if self.photos.isEmpty {
                            self.emptyMessageLabel.text = "There is no photos"
                        }
                    }
                })
                
            case .failed(let error):
                // TODO: error handling
                assertionFailure(error.localizedDescription)
            }
        })
    }
    
    /// need cancel last request if pullToRequest before end
    private func reloadData() {
        emptyMessageLabel.text = "Loading..."
        collectionView.backgroundView = emptyMessageLabel
        
        loadingMoreFooterView?.startSpinner()
        photos.removeAll()
        collectionView.reloadData()
        isLoadingMoreFinished = false
        paginationPage = 0
        
        /// call after resetting paginationPage
        loadMore()
    }
    
    func selectedItems() -> [SearchItemResponse]? {
        return collectionView.indexPathsForSelectedItems?.flatMap({ photos[$0.item] })
    }
}

// MARK: - UICollectionViewDataSource
extension PhotoSelectionController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionFooter {
            return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: footerId, for: indexPath)
        } else {
            assertionFailure("Unexpected element kind")
            return UICollectionReusableView()
        }
    }
}

// MARK: - UICollectionViewDelegate
extension PhotoSelectionController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? PhotoCell else {
            assertionFailure()
            return
        }
        
        let item = photos[indexPath.row]
        cell.update(for: selectionState)
        cell.setup(by: item)
        
        /// load more
        if !isLoadingMoreFinished, !isLoadingMore, indexPath.row == photos.count - 1 {
            loadMore()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //        guard let cell = cell as? PhotoCell else {
        //            assertionFailure()
        //            return
        //        }
        //photoLoadingManager.end(cell: cell, at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        switch selectionState {
        case .selecting:
            return true
        case .ended:
            return false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCount = collectionView.indexPathsForSelectedItems?.count ?? 0
        let isReachedLimit = (selectedCount == selectingLimit)
        
        if isReachedLimit {
            /// update all cells
            selectionState = .ended
            let cells = collectionView.indexPathsForVisibleItems.compactMap({ collectionView.cellForItem(at: $0) as? PhotoCell })
            cells.forEach({ $0.update(for: selectionState) })
            
        } else {
            /// update one cell
            selectionState = .selecting
            
            guard let cell = collectionView.cellForItem(at: indexPath) as? PhotoCell else {
                assertionFailure()
                return
            }
            cell.update(for: selectionState)
        }
        
        // TODO: refactor
        parent?.navigationItem.title = "Photos Selected (\(selectedCount))"
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        selectionState = .selecting
        let selectedCount = collectionView.indexPathsForSelectedItems?.count ?? 0
        let isDeselectFromLimit = (selectedCount == selectingLimit - 1)
        
        if isDeselectFromLimit {
            /// update all cells
            let cells = collectionView.indexPathsForVisibleItems.compactMap({ collectionView.cellForItem(at: $0) as? PhotoCell })
            cells.forEach({ $0.update(for: selectionState) })
            
        } else {
            /// update one cell
            guard let cell = collectionView.cellForItem(at: indexPath) as? PhotoCell else {
                assertionFailure()
                return
            }
            cell.update(for: selectionState)
        }
        
        // TODO: refactor
        parent?.navigationItem.title = "Photos Selected (\(selectedCount))"
    }
}

extension PhotoSelectionController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width / 4 - 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        
        if isLoadingMore {
            // TODO: need to check for all iOS
            //return CGSize(width: collectionView.contentSize.width, height: 50)
            return CGSize(width: 0, height: 50)
        } else {
            return .zero
        }
    }
}

extension PhotoSelectionController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //updateCachedAssetsFor
    }
}
