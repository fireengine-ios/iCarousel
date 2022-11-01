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
    func onSeeAllButton(for view: ForYouSections)
    func navigateToCreate(for view: ForYouSections)
    func navigateToItemDetail(item: WrapData, faceImageType: FaceImageType?, currentSection: ForYouSections)
    func naviateToAlbumDetail(album: AlbumItem)
    func navigateToItemPreview(item: WrapData, items: [WrapData], currentSection: ForYouSections)
    
    func displayAlbum(item: AlbumItem)
    func displayAnimation(item: WrapData)
    func displayCollage(item: WrapData)
    func onCloseCard(data: HomeCardResponse, section: ForYouSections)
    func showSavedCollage(item: WrapData)
    func showSavedAnimation(item: WrapData)
    func saveCard(data: HomeCardResponse, section: ForYouSections)
    func share(item: BaseDataSourceItem, type: CardShareType)
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
    private var currentView: ForYouSections?

    override func awakeFromNib() {
        super.awakeFromNib()
        configureTableView()
        addSpinner()
    }
    
    func configure(with model: Any?, currentView: ForYouSections) {
        guard let model = model else {
            return
        }
        
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
        
        self.currentView = currentView
        titleLabel.text = currentView.title
        seeAllButton.isHidden = false
        hideSpinner()
        
        switch currentView {
        case .albums:
            self.albumsData = model as? [AlbumItem] ?? []
            showEmptyDataViewIfNeeded(isShow: albumsData.isEmpty)
        case .photopick:
            self.photopickData = model as? [InstapickAnalyze] ?? []
            showEmptyDataViewIfNeeded(isShow: photopickData.isEmpty)
        case .collageCards, .animationCards, .albumCards:
            self.cardsData = model as? [HomeCardResponse] ?? []
            seeAllButton.isHidden = true
            showEmptyDataViewIfNeeded(isShow: false)
        default:
            self.wrapData = model as? [WrapData] ?? []
            showEmptyDataViewIfNeeded(isShow: wrapData.isEmpty)
        }
        
        collectionView.reloadData()
    }
    
    private func configureTableView() {
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(nibCell: ForYouCollectionViewCell.self)
        collectionView.register(nibCell: PeopleCollectionViewCell.self)
        collectionView.register(nibCell: ForYouCardsCollectionViewCell.self)
        collectionView.register(nibCell: ForYouGradientCollectionViewCell.self)
        collectionView.register(nibCell: ForYouBlurCollectionViewCell.self)
    }
    
    private func addSpinner() {
        hud = MBProgressHUD.showAdded(to: self, animated: true)
        hud?.mode = .customView
        hud?.customView?.backgroundColor = .clear
        hud?.customView = UIImageView(image: Image.popupLoading.image)
        hud?.offset = CGPoint(x: 0.0, y: MBProgressMaxOffset)
    }
    
    private func showEmptyDataViewIfNeeded(isShow: Bool) {
        if !isShow {
            emptyDataView.isHidden = true
            emptyDataView.removeFromSuperview()
            collectionView.isHidden = false
            return
        }
        
        emptyDataView.isHidden = !isShow
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
            let cell = collectionView.dequeue(cell: ForYouGradientCollectionViewCell.self, for: indexPath)
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
            cell.delegate = self
            return cell
        case .places, .things:
            let cell = collectionView.dequeue(cell: ForYouGradientCollectionViewCell.self, for: indexPath)
            let item = wrapData[indexPath.row]
            cell.configure(with: item)
            return cell
        case .hidden:
            let cell = collectionView.dequeue(cell: ForYouBlurCollectionViewCell.self, for: indexPath)
            let item = wrapData[indexPath.row]
            cell.configure(with: item)
            return cell
        default:
            let item = wrapData[indexPath.row]
            cell.configure(with: item, currentView: currentView ?? .people)
            return cell
        }
    }
}

extension ForYouTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if currentView == .people {
            return 0
        }
        
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let currentView = currentView else { return }

        switch currentView {
        case .people:
            let item = wrapData[indexPath.row]
            delegate?.navigateToItemDetail(item: item, faceImageType: .people, currentSection: currentView)
        case .things:
            let item = wrapData[indexPath.row]
            delegate?.navigateToItemDetail(item: item, faceImageType: .things, currentSection: currentView)
        case .places:
            let item = wrapData[indexPath.row]
            delegate?.navigateToItemDetail(item: item, faceImageType: .places, currentSection: currentView)
        case .albums:
            let album = albumsData[indexPath.row]
            delegate?.naviateToAlbumDetail(album: album)
        case .story, .animations, .collages, .hidden:
            let item = wrapData[indexPath.row]
            delegate?.navigateToItemPreview(item: item, items: wrapData, currentSection: currentView)
        default:
            return
        }
    }
}

extension ForYouTableViewCell: ForYouEmptyCellViewDelegate {
    func navigateTo(view: ForYouSections) {
        delegate?.navigateToCreate(for: view)
    }
}

extension ForYouTableViewCell: ForYouCardsCollectionViewCellDelegate {
    func displayAlbum(item: AlbumItem) {
        delegate?.displayAlbum(item: item)
    }
    
    func displayAnimation(item: WrapData) {
        delegate?.displayAnimation(item: item)
    }
    
    func displayCollage(item: WrapData) {
        delegate?.displayCollage(item: item)
    }
    
    func onCloseCard(data: HomeCardResponse, section: ForYouSections) {
        delegate?.onCloseCard(data: data, section: section)
        cardsData.remove(data)
        collectionView.reloadData()
    }
    
    func showSavedCollage(item: WrapData) {
        delegate?.showSavedCollage(item: item)
    }
    
    func showSavedAnimation(item: WrapData) {
        delegate?.showSavedAnimation(item: item)
    }
    
    func saveCard(data: HomeCardResponse, section: ForYouSections) {
        delegate?.saveCard(data: data, section: section)
    }
    
    func share(item: BaseDataSourceItem, type: CardShareType) {
        delegate?.share(item: item, type: type)
    }
}
