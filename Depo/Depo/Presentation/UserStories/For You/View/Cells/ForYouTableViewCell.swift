//
//  PeopleViewCell.swift
//  Depo
//
//  Created by Burak Donat on 22.07.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import UIKit
import MBProgressHUD

protocol ForYouTableViewCellDelegate: AnyObject {
    func onSeeAllButton(for view: ForYouViewEnum)
    func navigateToCreate(for view: ForYouViewEnum)
    func navigateToItemDetail(item: WrapData, faceImageType: FaceImageType?)
    func naviateToAlbumDetail(album: AlbumItem)
    func navigateToItemPreview(item: WrapData, items: [WrapData])
}

final class ForYouTableViewCell: UITableViewCell {

    @IBOutlet private weak var collectionView: UICollectionView! {
        willSet {
            newValue.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.medium, size: 14)
            newValue.textColor = AppColor.label.color
        }
    }
    
    @IBOutlet private weak var seeAllButton: UIButton! {
        willSet {
            newValue.setTitle("See All", for: .normal)
            newValue.titleLabel?.font = .appFont(.light, size: 14)
            newValue.setTitleColor(AppColor.label.color, for: .normal)
        }
    }
    
    weak var delegate: ForYouTableViewCellDelegate?
    private var hud: MBProgressHUD?
    private let emptyDataView = ForYouEmptyCellView.initFromNib()
    private var wrapData: [WrapData] = []
    private var albumsData: [AlbumItem] = []
    private var photopickData: [InstapickAnalyze] = []
    private var cardsData: [HomeCardResponse] = []
    private var currentView: ForYouViewEnum?

    override func awakeFromNib() {
        super.awakeFromNib()
        configureTableView()
        addSpinner()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        collectionView.delegate = self
    }
    
    func configure(with model: Any?, currentView: ForYouViewEnum) {
        guard let model = model else {
            return
        }
        
        self.currentView = currentView
        switch currentView {
        case .albumCards, .animationCards, .collageCards:
            collectionView.delegate = nil
            if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
                flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            }
        default:
            collectionView.delegate = self
        }

        titleLabel.text = currentView.title
        seeAllButton.isHidden = false
        hideSpinner()
        
        switch currentView {
        case .albums:
            self.albumsData = model as? [AlbumItem] ?? []
        case .photopick:
            self.photopickData = model as? [InstapickAnalyze] ?? []
        case .collageCards, .animationCards, .albumCards:
            self.cardsData = model as? [HomeCardResponse] ?? []
            seeAllButton.isHidden = true
        default:
            self.wrapData = model as? [WrapData] ?? []
        }
        
        collectionView.reloadData()
    }
    
    private func configureTableView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(nibCell: ForYouCollectionViewCell.self)
        collectionView.register(nibCell: PeopleCollectionViewCell.self)
        collectionView.register(nibCell: ForYouCardsCollectionViewCell.self)
    }
    
    private func addSpinner() {
        hud = MBProgressHUD.showAdded(to: self, animated: true)
        hud?.mode = .customView
        hud?.customView?.backgroundColor = .clear
        hud?.customView = UIImageView(image: Image.popupLoading.image)
        hud?.offset = CGPoint(x: 0.0, y: MBProgressMaxOffset)
    }
    
    private func showEmptyDataViewIfNeeded(isShow: Bool) {
        guard isShow else {
            emptyDataView.removeFromSuperview()
            return
        }
        
        collectionView.isHidden = isShow
        emptyDataView.translatesAutoresizingMaskIntoConstraints = false
        emptyDataView.configure(with: currentView ?? .photopick)
        emptyDataView.delegate = self
        
        guard emptyDataView.superview == nil else {
            return
        }
        self.addSubview(emptyDataView)
        NSLayoutConstraint.activate([
            emptyDataView.topAnchor.constraint(equalTo: collectionView.topAnchor),
            emptyDataView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            emptyDataView.widthAnchor.constraint(equalTo: self.widthAnchor)
        ])
    }

    @IBAction func seeAllButtonTapped(_ sender: UIButton) {
        if let currentView = currentView {
            delegate?.onSeeAllButton(for: currentView)
        }
    }
}

extension ForYouTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch currentView {
        case .albums:
            return albumsData.count
        case .photopick:
            return photopickData.count
        case .collageCards, .albumCards, .animationCards:
            return cardsData.count
        default:
            return wrapData.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(cell: ForYouCollectionViewCell.self, for: indexPath)
        switch currentView {
        case .people:
            let cell = collectionView.dequeue(cell: PeopleCollectionViewCell.self, for: indexPath)
            let item = wrapData[indexPath.row]
            cell.configure(with: item)
            return cell
        case .albums:
            let item = albumsData[indexPath.row]
            cell.configureAlbum(with: item)
            return cell
        case .photopick:
            let item = photopickData[indexPath.row]
            cell.configure(with: item)
            return cell
        case .collageCards, .animationCards, .albumCards:
            let cell = collectionView.dequeue(cell: ForYouCardsCollectionViewCell.self, for: indexPath)
            let item = cardsData[indexPath.row]
            cell.configure(with: item, currentView: currentView ?? .collageCards)
            return cell
        default:
            let item = wrapData[indexPath.row]
            cell.configure(with: item, currentView: currentView ?? .people)
            return cell
        }
    }
}

extension ForYouTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch currentView {
        case .people:
            return CGSize(width: 74, height: 106)
        default:
            return CGSize(width: 140, height: 140)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if currentView == .people {
            return 0
        }
        
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch currentView {
        case .people:
            let item = wrapData[indexPath.row]
            delegate?.navigateToItemDetail(item: item, faceImageType: .people)
        case .things:
            let item = wrapData[indexPath.row]
            delegate?.navigateToItemDetail(item: item, faceImageType: .things)
        case .places:
            let item = wrapData[indexPath.row]
            delegate?.navigateToItemDetail(item: item, faceImageType: .places)
        case .albums:
            let album = albumsData[indexPath.row]
            delegate?.naviateToAlbumDetail(album: album)
        case .story, .animations, .collages, .hidden:
            let item = wrapData[indexPath.row]
            delegate?.navigateToItemPreview(item: item, items: wrapData)
        default:
            return
        }
    }
}

extension ForYouTableViewCell: ForYouEmptyCellViewDelegate {
    func navigateTo(view: ForYouViewEnum) {
        delegate?.navigateToCreate(for: view)
    }
}
