//
//  PeopleViewCell.swift
//  Depo
//
//  Created by Burak Donat on 22.07.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import UIKit

enum ForYouViewEnum: CaseIterable {
    case faceImage
    case people
    case things
    case places
    case albums
    case throwback
    case collage
    
    var title: String {
        switch self {
        case .faceImage: return ""
        case .people: return "People"
        case .things: return "Things"
        case .places: return "Places"
        case .throwback: return "Throwback"
        case .collage: return "Collage"
        case .albums: return "Albums"
        }
    }
}

protocol ForYouTableViewCellDelegate: AnyObject {
    func onSeeAllButton(for view: ForYouViewEnum)
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
    
    private var thingsData: [WrapData] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private var placesData: [WrapData] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private var peopleData: [WrapData] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private var albumsData: [AlbumItem] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureTableView()
    }
    
    func configure(with type: ForYouViewEnum) {
        currentView = type
        titleLabel.text = type.title
        seeAllButton.isHidden = type == .people || type == .faceImage
        
        switch type {
        case .faceImage:
            break
        case .people:
            getPeople { data in
                self.peopleData = data
            } fail: {
                print("PEOPLE ERROR")
            }
        case .things:
            getThings { data in
                self.thingsData = data
            } fail: {
                print("THINGS ERROR")
            }
        case .places:
            getPlaces { data in
                self.placesData = data
            } fail: {
                print("PLACES ERROR")
            }
        case .throwback:
            break
        case .collage:
            break
        case .albums:
            getAlbums { data in
                self.albumsData = data
            } fail: {
                print("ALBUMS ERROR")
            }

        }
    }
    
    func getCellHeightFor(cell: ForYouViewEnum) -> CGFloat {
        return 140
    }
    
    private func configureTableView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(nibCell: ForYouCollectionViewCell.self)
        collectionView.register(nibCell: PeopleCollectionViewCell.self)
    }
    
    private func getThings(success: ListRemoteItems?, fail: FailRemoteItems?) {
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
        debugLog("AlbumService nextItems")

        let serchParam = AlbumParameters(fieldName: .album,
                                         sortBy: .date,
                                         sortOrder: .asc,
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
}
