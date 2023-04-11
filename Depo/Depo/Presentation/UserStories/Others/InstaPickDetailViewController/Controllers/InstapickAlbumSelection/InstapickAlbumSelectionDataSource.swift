import UIKit

protocol InstapickAlbumSelectionDataSourceDelegate: AnyObject {
    func onSelectAlbum(_ album: AlbumItem)
}

final class InstapickAlbumSelectionDataSource: NSObject {
    
    private var collectionView: UICollectionView?
    private var albums = [AlbumItem]()
    weak var delegate: InstapickAlbumSelectionDataSourceDelegate?
    
    // MARK: - Functions
    
    func setupCollectionView(collectionView: UICollectionView) {
        self.collectionView = collectionView
        
        collectionView.alwaysBounceVertical = true
        collectionView.register(nibCell: AlbumCollectionViewCell.self)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = AppColor.primaryBackground.color
        
        let transparentGradientViewHeight = NumericConstants.instaPickSelectionSegmentedTransparentGradientViewHeight
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: transparentGradientViewHeight, right: 0)
    }
    
    func reload(with albums: [AlbumItem]) {
        self.albums = albums
        collectionView?.reloadData()
    }
}

extension InstapickAlbumSelectionDataSource: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeue(cell: AlbumCollectionViewCell.self, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? AlbumCollectionViewCell else {
            return
        }
        
        cell.configureWithWrapper(wrappedObj: albums[indexPath.item])
    }
}

extension InstapickAlbumSelectionDataSource: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.onSelectAlbum(albums[indexPath.item])
    }
}

extension InstapickAlbumSelectionDataSource: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sizeCell: CGFloat = (Device.winSize.width - NumericConstants.amountInsetForAlbum) * 0.25
        return CGSize(width: sizeCell, height: sizeCell + NumericConstants.heightTextAlbumCell)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if Device.isIpad {
            return NumericConstants.iPadGreedHorizontalSpace
        } else {
            return NumericConstants.iPhoneGreedHorizontalSpace
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if Device.isIpad {
            return NumericConstants.iPadGreedHorizontalSpace
        } else {
            return NumericConstants.iPhoneGreedHorizontalSpace
        }
    }
}
