import UIKit
import Reachability

protocol PhotoSelectionControllerDelegate: class {
    var selectionState: PhotoSelectionState { get }
    var selectedItems: [SearchItemResponse] { get set }
    func selectionController(_ controller: PhotoSelectionController, didSelectItem item: SearchItemResponse)
    func selectionController(_ controller: PhotoSelectionController, didDeselectItem item: SearchItemResponse)
}

enum PhotoSelectionState {
    case selecting
    case ended
}

// TODO: accessibility
final class PhotoSelectionController: UIViewController, ErrorPresenter {
    
    private weak var delegate: PhotoSelectionControllerDelegate?
    private let dataSource: PhotoSelectionDataSourceProtocol
    private var isLoadingMore = false
    private var isLoadingMoreFinished = false
    
    private var selectionState: PhotoSelectionState {
        return delegate?.selectionState ?? localSelectionState
    }
    
    private var localSelectionState = PhotoSelectionState.selecting
    private var selectingLimit = 0
    
    private let photosSectionIndex = 0
    private var photos = [SearchItemResponse]()
    private let cellId = String(describing: PhotoCell.self)
    private let footerId = String(describing: CollectionSpinnerFooter.self)
    
    private let reachabilityService = ReachabilityService.shared
    
    private lazy var noFilesView = PhotoSelectionNoFilesView()
    private var displayNoFilesView:Bool {
        get {
            return !noFilesView.isHidden
        }
        set {
            if newValue {
                noFilesView.text = dataSource.getNoFilesMessage()
            }
            noFilesView.isHidden = !newValue
        }
    }
    
    private lazy var collectionView: UICollectionView = {
        let isIpad = Device.isIpad
        let layout = UICollectionViewFlowLayout()
        
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
        
        if self.delegate != nil {
            let transparentGradientViewHeight = NumericConstants.instaPickSelectionSegmentedTransparentGradientViewHeight
            collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: transparentGradientViewHeight, right: 0)
        }
        
        collectionView.backgroundView = noFilesView
        
        return collectionView
    }()
    
    private lazy var loadingMoreFooterView: CollectionSpinnerFooter? = {
        return collectionView.supplementaryView(forElementKind: UICollectionElementKindSectionFooter, at: IndexPath(item: 0, section: photosSectionIndex)) as? CollectionSpinnerFooter
    }()
    
    init(title: String, selectingLimit: Int, delegate: PhotoSelectionControllerDelegate?, dataSource: PhotoSelectionDataSourceProtocol) {
        self.dataSource = dataSource
        self.selectingLimit = selectingLimit
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }
    
    /// will never be called
    required init?(coder aDecoder: NSCoder) {
        assertionFailure()
        /// set any PhotoSelectionDataSourceProtocol
        self.dataSource = AllPhotosSelectionDataSource(pageSize: 100)
        super.init(coder: aDecoder)
    }
    
    deinit {
        reachabilityService.delegates.remove(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(collectionView)
        
        /// will call loadMore() also in reachability.whenReachable
        loadMore()
        loadingMoreFooterView?.startSpinner()
        reachabilityService.delegates.add(self)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateItemSize()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    private func updateItemSize() {
        let viewWidth = collectionView.bounds.width
        let columns: CGFloat = Device.isIpad ? 8 : 4
        let padding: CGFloat = 1
        let itemWidth = floor((viewWidth - (columns - 1) * padding) / columns)
        let itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = itemSize
            layout.minimumInteritemSpacing = padding
            layout.minimumLineSpacing = padding
        }
    }
    
    private func loadMore() {
        if isLoadingMore || isLoadingMoreFinished {
            return
        }
        
        isLoadingMore = true
        /// to update footer spinner
        updateLoadingMoreFooterViewLayout()
        
        self.dataSource.getNext { [weak self] result in
            guard let `self` = self else {
                return
            }
            
            switch result {
            case .success(let newPhotos):
                
                /// call before "self.photos.append"
                let isFirstPageLoaded = self.photos.isEmpty
                
                let newItemsRange = self.photos.count ..< (self.photos.count + newPhotos.count)
                let indexPathsForNewItems = newItemsRange.map({ IndexPath(item: $0, section: self.photosSectionIndex) })
                self.photos.append(contentsOf: newPhotos)

                self.collectionView.performBatchUpdates({ [weak self] in
                    
                    self?.collectionView.insertItems(at: indexPathsForNewItems)
                }, completion: { [weak self] _ in
                    
                    if isFirstPageLoaded, !newPhotos.isEmpty {
                        self?.collectionView.backgroundView = nil
                    }
                    
                    /// call after "self.photos.append(contentsOf: newPhotos)"
                    /// and "self.collectionView.insertItems"
                    self?.updateSelectedCellsIfNeed(for: newPhotos)
                    
                    self?.isLoadingMore = false
                    
                    if let isLoadingMoreFinished = self?.dataSource.isPaginationFinished, isLoadingMoreFinished {
                        self?.isLoadingMoreFinished = true
                        self?.hideFooterSpinner()
                        
                        /// if we don't have any item in collection
                        self?.displayNoFilesView = self?.photos.isEmpty ?? false
                    }
                })
                
            case .failed(let error):
                self.isLoadingMore = false
                self.showErrorAlert(message: error.description)
                self.hideFooterSpinner()
                
                /// if we don't have any item in collection
                self.displayNoFilesView = self.photos.isEmpty
            }
        }
    }
    
    /// to update footer view by func referenceSizeForFooterInSection
    private func updateLoadingMoreFooterViewLayout() {
        self.collectionView.performBatchUpdates({
            self.collectionView.collectionViewLayout.invalidateLayout()
        }, completion: nil)
    }
    
    private func hideFooterSpinner() {
        updateLoadingMoreFooterViewLayout()
        
        /// just in case stop animation.
        /// don't forget to start animation if need (for pullToRefresh)
        self.loadingMoreFooterView?.stopSpinner()
    }
}

// MARK: - cell updates
extension PhotoSelectionController {
    
    private func updateSelectedCellsIfNeed(for newPhotos: [SearchItemResponse]) {
        guard let delegate = self.delegate else {
            assertionFailure()
            return
        }
        
        /// subtracting bcz newPhotos are appended in self.photos
        let startIndex = self.photos.count - newPhotos.count
        
        for item in delegate.selectedItems {
            for (index, photo) in newPhotos.enumerated() {
                
                if photo.uuid == item.uuid {
                    let indexPath = IndexPath(item: startIndex + index, section: photosSectionIndex)
                    collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
                    selectCell(at: indexPath)
                }
            }
        }
    }
    
    /// without sending notification to the delegate
    private func selectCell(at indexPath: IndexPath) {
        let selectedCount = collectionView.indexPathsForSelectedItems?.count ?? 0
        let isReachedLimit = (selectedCount == selectingLimit)
        
        if isReachedLimit {
            /// update all cells
            localSelectionState = .ended
            updateVisibleCellsForSelectionState()
            
        } else {
            /// update one cell
            localSelectionState = .selecting
            updateCellForSelectionState(at: indexPath)
        }
    }
    
    private func deselectCell(at indexPath: IndexPath) {
        localSelectionState = .selecting
        let selectedCount = collectionView.indexPathsForSelectedItems?.count ?? 0
        let isDeselectFromLimit = (selectedCount == selectingLimit - 1)
        
        if isDeselectFromLimit {
            /// update all cells
            updateVisibleCellsForSelectionState()
            
        } else {
            /// update one cell
            updateCellForSelectionState(at: indexPath)
        }
    }
    
    private func updateCellForSelectionState(at indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? PhotoCell else {
            return
        }
        cell.update(for: selectionState)
    }
    
    private func updateVisibleCellsForSelectionState() {
        let cells = collectionView.indexPathsForVisibleItems.compactMap({ collectionView.cellForItem(at: $0) as? PhotoCell })
        cells.forEach({ $0.update(for: selectionState) })
    }
}

// MARK: - UICollectionViewDataSource
extension PhotoSelectionController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        /// this code in willDisplay will cause empty cells
        let isLastCell = (indexPath.row == photos.count - 1)
        if !isLoadingMoreFinished, !isLoadingMore, isLastCell {
            DispatchQueue.toMain {
                self.loadMore()
            }
        }
        
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
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? PhotoCell else {
            assertionFailure()
            return
        }
        cell.cancelImageLoading()
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
        if let delegate = delegate {
            delegate.selectionController(self, didSelectItem: photos[indexPath.item])
        } else {
            selectCell(at: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let delegate = delegate {
            delegate.selectionController(self, didDeselectItem: photos[indexPath.item])
        } else {
            deselectCell(at: indexPath)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension PhotoSelectionController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        
        if isLoadingMore {
            return CGSize(width: 0, height: 50)
        } else {
            return .zero
        }
    }
}

// MARK: - InstaPickSelectionSegmentedControllerDelegate
extension PhotoSelectionController: InstaPickSelectionSegmentedControllerDelegate {
    
    func didSelectItem(_ selectedItem: SearchItemResponse) {
        /// controller can be created but not added as child so view will not be loaded yet
        guard isViewLoaded else {
            return
        }
        for (index, photo) in photos.enumerated() {
            if photo.uuid == selectedItem.uuid {
                let indexPath = IndexPath(item: index, section: photosSectionIndex)
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
                updateCellForSelectionState(at: indexPath)
                break
            }
        }
    }
    
    func didDeselectItem(_ deselectItem: SearchItemResponse) {
        guard isViewLoaded else {
            return
        }
        for (index, photo) in photos.enumerated() {
            if photo.uuid == deselectItem.uuid {
                let indexPath = IndexPath(item: index, section: photosSectionIndex)
                collectionView.deselectItem(at: indexPath, animated: false)
                updateCellForSelectionState(at: indexPath)
                break
            }
        }
    }
    
    func selectionStateDidChange(_ selectionState: PhotoSelectionState) {
        guard isViewLoaded else {
            return
        }
        updateVisibleCellsForSelectionState()
    }
}

//MARK: - ReachabilityServiceDelegate
extension PhotoSelectionController: ReachabilityServiceDelegate {
    func reachabilityDidChanged(_ service: ReachabilityService) {
        guard service.isReachable, !isLoadingMoreFinished else {
            return
        }
        loadMore()
        loadingMoreFooterView?.startSpinner()
        
        /// reload photos
        for indexPath in collectionView.indexPathsForVisibleItems {
            guard
                let cell = collectionView.cellForItem(at: indexPath) as? PhotoCell,
                cell.isNeedToUpdate else {
                    return
            }
            let item = self.photos[indexPath.row]
            //cell.update(for: selectionState)
            cell.setup(by: item)
        } 
    }
}
