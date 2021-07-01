//
//  OverlayStickerSelectorViewController.swift
//  Depo
//
//  Created by Hady on 6/28/21.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

protocol OverlayStickerSelectorDelegate: class {
    func didSelectItem(item: SmashStickerResponse, attachmentType: AttachedEntityType)
}

final class OverlayStickerSelectorViewController: UIViewController {
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private lazy var dataSource = OverlayStickerSelectorDataSource(collectionView: collectionView, delegate: nil)

    var overlayType: AttachedEntityType = .gif {
        didSet {
            dataSource.setStateForSelectedType(type: overlayType)
        }
    }

    weak var delegate: OverlayStickerSelectorDelegate? {
        didSet {
            dataSource.delegate = delegate
        }
    }

    override func loadView() {
        self.view = collectionView
    }
}
