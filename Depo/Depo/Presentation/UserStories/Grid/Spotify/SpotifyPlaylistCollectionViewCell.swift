//
//  SpotifyPlaylistCollectionViewCell.swift
//  Depo
//
//  Created by Andrei Novikau on 7/29/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class SelectionButton: UIButton {
    
    override var isSelected: Bool {
        didSet {
            setImage(UIImage(named: isSelected ? "notSelected" : "selected"), for: .highlighted)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        setImage(UIImage(named: "notSelected"), for: .normal)
        setImage(UIImage(named: "selected"), for: .selected)
        setImage(UIImage(named: "selected"), for: .highlighted)
    }
}

protocol SpotifyPlaylistCellDelegate: LBCellsDelegate {
    func onSelect(cell: SpotifyPlaylistCollectionViewCell)
    func onDeselect(cell: SpotifyPlaylistCollectionViewCell)
}

final class SpotifyPlaylistCollectionViewCell: UICollectionViewCell {
    
    private enum Constants {
        enum imageLeftOffset {
            static let selectionMode: CGFloat = 50
            static let defaultMode: CGFloat = 18
        }
    }
    
    @IBOutlet private weak var selectionButton: SelectionButton! {
        willSet {
            newValue.addTarget(self, action: #selector(onSelectionButton(_:)), for: .touchUpInside)
        }
    }
    
    @IBOutlet private weak var imageView: UIImageView! {
        willSet {
            newValue.layer.masksToBounds = true
            newValue.layer.cornerRadius = 2
        }
    }
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.charcoalGrey
            newValue.font = UIFont.TurkcellSaturaDemFont(size: 18)
        }
    }
    @IBOutlet private weak var subtitleLabel: UILabel! {
        willSet {
            newValue.textColor = ColorConstants.charcoalGrey.withAlphaComponent(0.5)
            newValue.font = UIFont.TurkcellSaturaFont(size: 16)
        }
    }
    @IBOutlet private weak var arrowImageView: UIImageView!
    @IBOutlet private var imageLeftOffset: NSLayoutConstraint!
    
    weak var delegate: SpotifyPlaylistCellDelegate?
    private var cellImageManager: CellImageManager?
    private var uuid: String?
    
    // MARK: -
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cellImageManager?.cancelImageLoading()
        imageView.image = nil
        uuid = nil
    }
    
    func setup(with item: SpotifyObject, isSelected: Bool) {
        selectionButton.isSelected = isSelected
        
        if let playlist = item as? SpotifyPlaylist {
            titleLabel.text = playlist.name
            subtitleLabel.text = String(format: TextConstants.Spotify.Playlist.songsCount, playlist.count)
            arrowImageView.isHidden = playlist.count == 0
            setImage(with: playlist.image, placeholder: UIImage(named: "playlist"))
        } else if let track = item as? SpotifyTrack {
            titleLabel.text = track.name
            subtitleLabel.text = track.artistName
            arrowImageView.isHidden = true
            setImage(with: track.image, placeholder: UIImage(named: "playlist_track"))
        }
    }
    
    private func setImage(with image: SpotifyImage?, placeholder: UIImage?) {
        imageView.image = placeholder
        guard let url = image?.url else {
            return
        }
        
        let cacheKey = url.byTrimmingQuery
        cellImageManager = CellImageManager.instance(by: cacheKey)
        uuid = cellImageManager?.uniqueId
        let imageSetBlock: CellImageManagerOperationsFinished = { [weak self] image, cached, shouldBeBlurred, uniqueId in
            guard let self = self else {
                return
            }
            
            DispatchQueue.main.async {
                guard let image = image, let uuid = self.uuid, uuid == uniqueId else {
                    return
                }
                self.imageView.image = image
            }
        }
        
        cellImageManager?.loadImage(thumbnailUrl: nil, url: url, completionBlock: imageSetBlock)
    }
    
    func setSeletionMode(_ isActive: Bool, animation: Bool) {
        UIView.animate(withDuration: animation ? 0.1 : 0) {
            self.selectionButton.isHidden = !isActive
            self.imageLeftOffset.constant = isActive ? Constants.imageLeftOffset.selectionMode : Constants.imageLeftOffset.defaultMode
            self.layoutIfNeeded()
        }
    }
    
    // MARK: - Actions
    
    @objc private func onSelectionButton(_ sender: UIButton) {
        if sender.isSelected {
            delegate?.onDeselect(cell: self)
        } else {
            delegate?.onSelect(cell: self)
        }
        sender.isSelected.toggle()
    }
}
