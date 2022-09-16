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
}

class ForYouTableViewCell: UITableViewCell {

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
            newValue.setTitleColor(AppColor.label.color, for: .highlighted)
        }
    }
    
    weak var delegate: ForYouTableViewCellDelegate?
    private var currentView: ForYouViewEnum?
    private let thingsService = ThingsService()
    private let placesService = PlacesService()
    private let peopleService = PeopleService()
    private let albumServie = SearchService()
    private let instapickService = InstapickServiceImpl()
    private var hud: MBProgressHUD?
    private let emptyDataView = ForYouEmptyCellView.initFromNib()
    
    private var thingsData: [WrapData] = []
    private var placesData: [WrapData] = []
    private var peopleData: [WrapData] = []
    private var albumsData: [AlbumItem] = []
    private var photopickData: [InstapickAnalyze] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureTableView()
    }
    
    func configure(with type: ForYouViewEnum) {
        currentView = type
        titleLabel.text = type.title
        addSpinner()
        
        switch type {
        case .faceImage:
            break
        case .people:
            getPeople { data in
                self.showEmptyDataViewIfNeeded(isShow: data.isEmpty)
                self.peopleData = data
                self.handleSuccessResponse()
            } fail: {
                print("PEOPLE ERROR")
            }
        case .things:
            getThings { data in
                self.showEmptyDataViewIfNeeded(isShow: data.isEmpty)
                self.thingsData = data
                self.handleSuccessResponse()
            } fail: {
                print("THINGS ERROR")
            }
        case .places:
            getPlaces { data in
                self.showEmptyDataViewIfNeeded(isShow: data.isEmpty)
                self.placesData = data
                self.handleSuccessResponse()
            } fail: {
                print("PLACES ERROR")
            }
        case .photopick:
            getInstapickThumbnails { data in
                self.showEmptyDataViewIfNeeded(isShow: data.isEmpty)
                self.photopickData = data
                self.handleSuccessResponse()
            } fail: {
                print("PHOTOPICK ERROR")
            }
        case .albums:
            getAlbums { data in
                self.albumsData = data
                self.handleSuccessResponse()
            } fail: {
                print("ALBUMS ERROR")
            }

        }
    }
    
    private func handleSuccessResponse() {
        hud?.hide(animated: true)
        collectionView.reloadData()
    }
    
    private func configureTableView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(nibCell: ForYouCollectionViewCell.self)
        collectionView.register(nibCell: PeopleCollectionViewCell.self)
    }
    
    private func getThings(success: ListRemoteItems?, fail: FailRemoteItems?) {
        debugLog("ForYou getThings")
        let param = ThingsPageParameters(pageSize: 10, pageNumber: 0)
        
        thingsService.getThingsPage(param: param, success: { response in
            guard let response = response as? ThingsPageResponse else {
                fail?()
                return
            }
            
            success?(response.list.map({ ThingsItem(response: $0) }))
        }, fail: { error in
            error.showInternetErrorGlobal()
            fail?()
        })
    }
    
    private func getPlaces(success: ListRemoteItems?, fail: FailRemoteItems?) {
        debugLog("ForYou getPlaces")
        let param = PlacesPageParameters(pageSize: 10, pageNumber: 0)

        placesService.getPlacesPage(param: param, success: { response in
            guard let response = response as? PlacesPageResponse else {
                fail?()
                return
            }

            success?(response.list.map({ PlacesItem(response: $0) }))
        }, fail: { error in
            error.showInternetErrorGlobal()
            fail?()
        })
    }
    
    private func getPeople(success: ListRemoteItems?, fail: FailRemoteItems?) {
        debugLog("ForYou getPeople")
        let param = PeoplePageParameters(pageSize: 10, pageNumber: 0)
        
        peopleService.getPeoplePage(param: param, success: { response in
            guard let response = response as? PeoplePageResponse else {
                fail?()
                return
            }
            
            success?(response.list.map({ PeopleItem(response: $0) }))
        }, fail: { error in
            error.showInternetErrorGlobal()
            fail?()
        })
    }
    
    private func getAlbums(success: @escaping ListRemoteAlbums, fail: @escaping FailRemoteItems ) {
        debugLog("ForYou getAlbums")
        let serchParam = AlbumParameters(fieldName: .album,
                                         sortBy: .date,
                                         sortOrder: .desc,
                                         page: 0,
                                         size: 10)
        
        albumServie.searchAlbums(param: serchParam, success: { response in
            guard let resultResponse = response as? AlbumResponse else {
                return fail()
            }
            
            let list = resultResponse.list.compactMap { AlbumItem(remote: $0) }
            success(list)

        }, fail: { errorResponse in
            errorResponse.showInternetErrorGlobal()
            fail()
        })
    }
    
    private func getInstapickThumbnails(success: @escaping ([InstapickAnalyze]) -> Void, fail: @escaping FailRemoteItems) {
        instapickService.getAnalyzeHistory(offset: 0, limit: 10) { result in
            switch result {
            case .success(let history):
                success(history)
            case .failed(_):
                fail()
            }
        }
    }
    
    private func addSpinner() {
        hud = MBProgressHUD.showAdded(to: self, animated: true)
        hud?.mode = .customView
        hud?.customView?.backgroundColor = .clear
        hud?.customView = UIImageView(image: Image.popupLoading.image)
        hud?.offset = CGPoint(x: 0.0, y: MBProgressMaxOffset)
    }
    
    func showEmptyDataViewIfNeeded(isShow: Bool) {
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
        case .people:
            return peopleData.count
        case .things:
            return thingsData.count
        case .places:
            return placesData.count
        case .albums:
            return albumsData.count
        case .photopick:
            return photopickData.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(cell: ForYouCollectionViewCell.self, for: indexPath)
        switch currentView {
        case .people:
            let cell = collectionView.dequeue(cell: PeopleCollectionViewCell.self, for: indexPath)
            let item = peopleData[indexPath.row]
            cell.configure(with: item)
            return cell
        case .things:
            let item = thingsData[indexPath.row]
            cell.configure(with: item)
            return cell
        case .places:
            let item = placesData[indexPath.row]
            cell.configure(with: item)
            return cell
        case .albums:
            let item = albumsData[indexPath.row]
            cell.configureAlbum(with: item)
            return cell
        case .photopick:
            let url = photopickData[indexPath.row]
            cell.configure(with: url)
            return cell
        default:
            return cell
        }
    }
}

extension ForYouTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if currentView == .people {
            return CGSize(width: 74, height: 106)
        }
        
        return CGSize(width: 140, height: 140)
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
            let item = peopleData[indexPath.row]
            delegate?.navigateToItemDetail(item: item, faceImageType: .people)
        case .things:
            let item = thingsData[indexPath.row]
            delegate?.navigateToItemDetail(item: item, faceImageType: .things)
        case .places:
            let item = placesData[indexPath.row]
            delegate?.navigateToItemDetail(item: item, faceImageType: .places)
        case .albums:
            let album = albumsData[indexPath.row]
            delegate?.naviateToAlbumDetail(album: album)
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
