//
//  RecentlySearchedFaceImageTableViewCell.swift
//  Depo
//
//  Created by Andrei Novikau on 21.02.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

protocol RecentlySearchedFaceImageCellDelegate: class {
    func select(item: SuggestionObject)
    func tapArrow(category: SearchCategory)
}

final class RecentlySearchedFaceImageTableViewCell: UITableViewCell {

    private let itemSize: CGSize = CGSize(width: Device.winSize.size.width * 40/375, height: Device.winSize.size.width * 40/375)
    
    @IBOutlet weak var stackView: UIStackView!
    
    weak var delegate: RecentlySearchedFaceImageCellDelegate?
    
    private var items = [SuggestionObject]()
    private var category: SearchCategory?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    func configure(withItems items:[SuggestionObject]?, category: SearchCategory?) {
        if let items = items {
            if stackView.arrangedSubviews.isEmpty {
                for (index, item) in items.enumerated() {
                    self.add(item: item, atIndex: index)
                }
            }
        }
    }
    
    private func add(item: SuggestionObject, atIndex index: Int) {
        let frame = CGRect(origin: .zero, size: itemSize)
        let thumbnailImageView = LoadingImageView(frame: frame)
        thumbnailImageView.widthAnchor.constraint(equalToConstant: itemSize.width).isActive = true
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.loadImageByURL(url: item.info?.thumbnail)
        
        if let type = item.type, type == .thing,
           let name = item.info?.name {
            let title = UILabel(frame: CGRect(x: 0, y: itemSize.height - 15, width: itemSize.width, height: 14))
            title.text = name
            title.textColor = .white
            title.font = UIFont.TurkcellSaturaBolFont(size: 12)
            thumbnailImageView.addSubview(title)
        }
        
        let button = UIButton(frame: frame)
        button.tag = index
        button.addTarget(self, action: #selector(selectItem(_:)), for: .touchUpInside)
        thumbnailImageView.addSubview(button)
        
        stackView.addArrangedSubview(thumbnailImageView)
    }

    @objc func selectItem(_ sender: UIButton) {
        if items.count <= sender.tag {
            delegate?.select(item: items[sender.tag])
        }
    }
    
    @IBAction func tapArrow(_ sender: UIButton) {
        if let category = category {
            delegate?.tapArrow(category: category)
        }
    }
    
    static func height() -> CGFloat {
        return Device.winSize.size.width * 40/375
    }
}
