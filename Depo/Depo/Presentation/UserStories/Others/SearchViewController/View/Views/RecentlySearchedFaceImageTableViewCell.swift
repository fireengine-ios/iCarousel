//
//  RecentlySearchedFaceImageTableViewCell.swift
//  Depo
//
//  Created by Andrei Novikau on 21.02.2018.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

protocol RecentlySearchedFaceImageCellDelegate: AnyObject {
    func select(item: SuggestionObject)
    func tapArrow(category: SearchCategory)
}

final class RecentlySearchedFaceImageTableViewCell: UITableViewCell {

    private let itemSize: CGSize = CGSize(width: Device.winSize.size.width * 40 / 375, height: Device.winSize.size.width * 40 / 375)
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var arrowWidth: NSLayoutConstraint!

    weak var delegate: RecentlySearchedFaceImageCellDelegate?
    
    private var items = [SuggestionObject]()
    private var category: SearchCategory?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = .clear
        contentView.backgroundColor = .clear
        stackView.spacing = 3
        separatorInset.left = Device.winSize.width
        arrowWidth.constant = itemSize.width
    }
    
    func configure(withItems items: [SuggestionObject]?, category: SearchCategory?) {
        self.category = category
        guard let newItems = items else {
            removeSubviews()
            return
        }
        
        let oldFirstId = self.items.first?.info?.id
        let newFirstId = newItems.first?.info?.id
        
        if oldFirstId != newFirstId {
            self.items = newItems
            
            removeSubviews()
            
            for (index, item) in newItems.enumerated() {
                self.add(item: item, atIndex: index)
            }
        }
    }
    
    private func add(item: SuggestionObject, atIndex index: Int) {
        let frame = CGRect(origin: .zero, size: itemSize)
        
        let button = UIButton(frame: frame)
        button.widthAnchor.constraint(equalToConstant: itemSize.width).isActive = true
        button.heightAnchor.constraint(equalToConstant: itemSize.height).isActive = true
        button.contentMode = .scaleAspectFill
        button.clipsToBounds = true
        button.sd_setImage(with: item.info?.thumbnail, for: .normal, completed: nil)
        button.tag = index
        button.addTarget(self, action: #selector(selectItem(_:)), for: .touchUpInside)
        button.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        if let name = item.info?.name {
            let title = UILabel(frame: CGRect(x: 0, y: itemSize.height - 15, width: itemSize.width, height: 14))
            title.text = name
            title.textColor = .white
            title.textAlignment = .center
            title.font = UIFont.TurkcellSaturaBolFont(size: 12)
            button.addSubview(title)
        }
        
        stackView.addArrangedSubview(button)
    }
    
    private func removeSubviews() {
        for view in stackView.arrangedSubviews {
            view.removeFromSuperview()
        }
    }

    @IBAction func selectItem(_ sender: UIButton) {
        if items.count > sender.tag {
            delegate?.select(item: items[sender.tag])
        }
    }
    
    @IBAction func tapArrow(_ sender: UIButton) {
        if let category = category {
            delegate?.tapArrow(category: category)
        }
    }
    
    static func height() -> CGFloat {
        return Device.winSize.size.width * 40 / 375 + 14
    }
}
