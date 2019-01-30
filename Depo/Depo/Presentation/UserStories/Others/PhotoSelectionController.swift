import UIKit

protocol PhotoSelectionControllerDelegate: class {
    var selectionState: PhotoSelectionController.SelectionState { get }
    var selectedItems: [SearchItemResponse] { get set }
    func selectionController(_ controller: PhotoSelectionController, didSelectItem item: SearchItemResponse)
    func selectionController(_ controller: PhotoSelectionController, didDeselectItem item: SearchItemResponse)
}

// TODO: localize
// TODO: paginationSize + test for iPad
// TODO: refactor
// TODO: updaye cell layout UICollectionViewDelegateFlowLayout
final class PhotoSelectionController: UIViewController, ErrorPresenter {
    
    // TODO: refactor name
    enum SelectionState {
        case selecting
        case ended
    }
    
    private weak var delegate: PhotoSelectionControllerDelegate?
    
    private let dataSource: PhotoSelectionDataSourceProtocol
    private var isLoadingMore = false
    private var isLoadingMoreFinished = false
    
    private var selectionState: SelectionState {
        return delegate?.selectionState ?? localSelectionState
    }
    
    private var localSelectionState = SelectionState.selecting
    private var selectingLimit = 0
    
    private let photosSectionIndex = 0
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
        return collectionView.supplementaryView(forElementKind: UICollectionElementKindSectionFooter, at: IndexPath(item: 0, section: photosSectionIndex)) as? CollectionSpinnerFooter
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
    
    init(title: String, selectingLimit: Int, delegate: PhotoSelectionControllerDelegate?, dataSource: PhotoSelectionDataSourceProtocol) {
        self.dataSource = dataSource
        self.selectingLimit = selectingLimit
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }
    
    /// will never be called
    required init?(coder aDecoder: NSCoder) {
        /// set any PhotoSelectionDataSourceProtocol
        self.dataSource = AllPhotosSelectionDataSource(pageSize: 100)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(collectionView)
        loadMore()
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
        
        self.dataSource.getNext { [weak self] result in
            guard let `self` = self else {
                return
            }
            
            switch result {
            case .success(let newPhotos):
                
                /// call before "self.photos.append"
                let isFirstPageLoaded = self.photos.isEmpty
                
                let newItemsRange = self.photos.count ..< (self.photos.count + newPhotos.count)
                let indexPathesForNewItems = newItemsRange.map({ IndexPath(item: $0, section: self.photosSectionIndex) })
                self.photos.append(contentsOf: newPhotos)
                
                /// use performBatchUpdates if there will be problems,
                /// but will be delay for "updateSelectedCellsIfNeed"
                self.collectionView.insertItems(at: indexPathesForNewItems)
                
                if isFirstPageLoaded {
                    let isNewPhotosExist = !newPhotos.isEmpty
                    if isNewPhotosExist {
                        self.collectionView.backgroundView = nil
                    }
                }
                
                /// call after "self.photos.append(contentsOf: newPhotos)"
                /// and "self.collectionView.insertItems"
                self.updateSelectedCellsIfNeed(for: newPhotos)
                
                self.isLoadingMore = false
                
                let isLoadingMoreFinished = self.dataSource.isPaginationFinished
                
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
                
            case .failed(let error):
                self.showErrorAlert(message: error.localizedDescription)
            }
        }
    }
    
    // TODO: need cancel last request if needs pullToRequest before end
    private func reloadData() {
        emptyMessageLabel.text = "Loading..."
        collectionView.backgroundView = emptyMessageLabel
        
        loadingMoreFooterView?.startSpinner()
        photos.removeAll()
        collectionView.reloadData()
        isLoadingMoreFinished = false
        dataSource.reset()
        
        /// call after resetting paginationPage
        loadMore()
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
        let isLastCell = (indexPath.row == photos.count - 1)
        if !isLoadingMoreFinished, !isLoadingMore, isLastCell {
            loadMore()
        }
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
    
    func selectionStateDidChange(_ selectionState: PhotoSelectionController.SelectionState) {
        guard isViewLoaded else {
            return
        }
        updateVisibleCellsForSelectionState()
    }
}
