//
//  FileInfoPeopleView.swift
//  Depo
//
//  Created by Andrei Novikau on 11/13/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

protocol FileInfoPeopleViewProtocol: UIView {
    var collectionView: UICollectionView { get }
    var status: ItemStatus { get set }
    var fileType: FileType { get set }
    
    func reset()
    func reload(with items: [PeopleOnPhotoItemResponse])
    func delete(item: Item)
    func setHiddenPeoplePlaceholder(isHidden: Bool)
    func setHiddenPremiumStackView(isHidden: Bool)
}

protocol FileInfoPeopleViewDelegate: class {
    func onPeopleAlbumDidTap(item: PeopleOnPhotoItemResponse)
    func onEnableFaceRecognitionDidTap()
    func onBecomePremiumDidTap()
}

final class FileInfoPeopleView: UIView, NibInit, FileInfoPeopleViewProtocol {

    static func with(delegate: FileInfoPeopleViewDelegate?) -> FileInfoPeopleViewProtocol {
        let view = FileInfoPeopleView.initFromNib()
        view.delegate = delegate
        return view
    }
    
    @IBOutlet private weak var peopleStackView: UIStackView!
    
    @IBOutlet private weak var peopleTitleLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.myStreamPeopleTitle
            newValue.font = UIFont.TurkcellSaturaBolFont(size: 14)
            newValue.textColor = ColorConstants.marineTwo
        }
    }

    @IBOutlet private(set) weak var peopleCollectionView: UICollectionView!

    @IBOutlet private weak var enableFIRStackView: UIStackView!
    @IBOutlet private weak var enableFIRTextLabel: UILabel! {
        willSet {
            newValue.text = TextConstants.fileInfoPeople
            newValue.font = UIFont.TurkcellSaturaMedFont(size: 19)
            newValue.textColor = ColorConstants.closeIconButtonColor
        }
    }
    
    @IBOutlet private weak var enableFIRButton: RoundedInsetsButton! {
        willSet {
            newValue.setTitleColor(.white, for: UIControl.State())
            newValue.insets = UIEdgeInsets(topBottom: 0, rightLeft: 12)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 16)
            newValue.backgroundColor = ColorConstants.marineTwo
            newValue.setTitle(TextConstants.passcodeEnable, for: UIControl.State())
            newValue.adjustsFontSizeToFitWidth()
        }
    }
    
    @IBOutlet private weak var premiumStackView: UIStackView!
    
    @IBOutlet private weak var premiumTextLabel: UILabel! {
        willSet {
            newValue.font = UIFont.TurkcellSaturaMedFont(size: 19)
            newValue.textColor = ColorConstants.closeIconButtonColor
        }
    }
    
    @IBOutlet private weak var premiumButton: GradientPremiumButton! {
        willSet {
            newValue.titleEdgeInsets = UIEdgeInsetsMake(6, 14, 6, 14)
            newValue.setTitle(TextConstants.becomePremium, for: .normal)
            newValue.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 15)
        }
    }
    
    private weak var delegate: FileInfoPeopleViewDelegate?
    
    private lazy var dataSource = PeopleSliderDataSource(collectionView: peopleCollectionView, delegate: self)
    
    //MARK: - FileInfoPeopleViewProtocol
    
    var collectionView: UICollectionView {
        peopleCollectionView
    }
    
    var status: ItemStatus = .unknown
    var fileType: FileType = .application(.unknown)
    
    func reset() {
        dataSource.reset()
        peopleCollectionView.isHidden = true
    }
    
    func reload(with items: [PeopleOnPhotoItemResponse]) {
        let isHidden = peopleCollectionView.isHidden
        switch status {
        case .deleted, .trashed, .hidden:
            peopleCollectionView.isHidden = true
        default:
            peopleCollectionView.isHidden = items.isEmpty
        }
        premiumTextLabel.text = items.isEmpty
            ? TextConstants.noPeopleBecomePremiumText
            : TextConstants.allPeopleBecomePremiumText
        dataSource.reloadCollection(with: items)
        setHiddenPeopleLabel()
        isHidden != items.isEmpty ? layoutIfNeeded() : ()
    }
    
    func delete(item: Item) {
        guard let peopleItem = item as? PeopleItem,
            let index = dataSource.items.firstIndex(where: { $0.personInfoId == peopleItem.id })
        else {
            return
        }
            
        dataSource.deleteItem(at: index)
        reload(with: dataSource.items)
    }
    
    func setHiddenPeoplePlaceholder(isHidden: Bool) {
        enableFIRStackView.isHidden = isHidden
        peopleCollectionView.isHidden = !isHidden
    }
    
    func setHiddenPremiumStackView(isHidden: Bool) {
        var isPremiumHidden: Bool
        switch status {
        case .deleted, .trashed, .hidden:
            isPremiumHidden = true
        default:
            isPremiumHidden = fileType == .image ? isHidden : true
        }
        premiumStackView.isHidden = isPremiumHidden
        setHiddenPeopleLabel()
    }
    
    //MARK: - Private
    
    private func setHiddenPeopleLabel() {
        peopleTitleLabel.isHidden =
            premiumStackView.isHidden
            && peopleCollectionView.isHidden
            && enableFIRStackView.isHidden
    }
    
    // MARK: Actions
    
    @IBAction private func onEnableTapped(_ sender: Any) {
        delegate?.onEnableFaceRecognitionDidTap()
    }
    
    @IBAction private func onPremiumTapped(_ sender: Any) {
        delegate?.onBecomePremiumDidTap()
    }
}

//MARK: - PeopleSliderDataSourceDelegate

extension FileInfoPeopleView: PeopleSliderDataSourceDelegate {
    
    func didSelect(item: PeopleOnPhotoItemResponse) {
        delegate?.onPeopleAlbumDidTap(item: item)
    }
}
