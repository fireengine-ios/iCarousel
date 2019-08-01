//
//  SpotifyPlaylistCollectionViewCell.swift
//  Depo
//
//  Created by Andrei Novikau on 7/29/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit
import SDWebImage

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
    
    @IBOutlet private weak var selectionButton: UIButton! {
        willSet {
            newValue.setImage(UIImage(named: "notSelected"), for: .normal)
            newValue.setImage(UIImage(named: "selected"), for: .selected)
            newValue.setImage(UIImage(named: "selected"), for: .highlighted)
            newValue.setImage(UIImage(named: "notSelected"), for: [.highlighted, .selected])
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
    
    private var isSelectionStateActive = false
    
    // MARK: -
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.sd_cancelCurrentImageLoad()
        imageView.image = nil
        uuid = nil
    }
    
    func setup(with item: SpotifyObject, isSelected: Bool) {
        selectionButton.isSelected = isSelected
        
        if let playlist = item as? SpotifyPlaylist {
            titleLabel.text = playlist.name
            subtitleLabel.text = String(format: TextConstants.Spotify.Playlist.songsCount, playlist.count)
            arrowImageView.isHidden = !isSelectionStateActive || playlist.count == 0
            imageView.sd_setImage(with: playlist.image?.url, placeholderImage: UIImage(named: "playlist")!)
        } else if let track = item as? SpotifyTrack {
            titleLabel.text = track.name
            subtitleLabel.text = track.artistName
            arrowImageView.isHidden = true
            imageView.sd_setImage(with: track.image?.url, placeholderImage: UIImage(named: "playlist_track")!)
        }
    }
    
    func setSeletionMode(_ isActive: Bool, animation: Bool) {
        isSelectionStateActive = isActive
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
