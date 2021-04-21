//
//  EntityInfoHeader.swift
//  Depo
//
//  Created by Anton Ignatovich on 23.02.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import Foundation

final class EntityInfoHeader: UIView {
    private struct Constants {
        static let leadingTrailingOffset: CGFloat = 20
        static let topOffset: CGFloat = 20
        static let bottomOffset: CGFloat = 15
        static let separatorViewHeight: CGFloat = 1
    }

    var needsSeparatorViewOnTop: Bool = false {
        didSet {
            separatorView.backgroundColor = needsSeparatorViewOnTop ? ColorConstants.separator.color : .clear
        }
    }

    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.GTAmericaStandardRegularFont()
        label.textColor = ColorConstants.Text.labelTitle.color
        return label
    }()

    private lazy var separatorView: UIView = {
        let vview = UIView()
        vview.translatesAutoresizingMaskIntoConstraints = false
        vview.backgroundColor = UIColor.clear
        return vview
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        addSubview(label)
        addSubview(separatorView)

        separatorView.leadingAnchor.constraint(equalTo: leadingAnchor).activate()
        separatorView.trailingAnchor.constraint(equalTo: trailingAnchor).activate()
        separatorView.topAnchor.constraint(equalTo: topAnchor).activate()
        separatorView.heightAnchor.constraint(equalToConstant: Constants.separatorViewHeight).activate()

        label.pinToSuperviewEdges(offset: UIEdgeInsets(top: Constants.topOffset + Constants.separatorViewHeight,
                                                       left: Constants.leadingTrailingOffset,
                                                       bottom: Constants.bottomOffset,
                                                       right: Constants.leadingTrailingOffset))
    }

    func updateText(to string: String?) {
        label.text = string
    }
}
