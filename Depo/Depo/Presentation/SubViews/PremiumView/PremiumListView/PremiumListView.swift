//
//  PremiumListView.swift
//  Depo_LifeTech
//
//  Created by Timafei Harhun on 11/15/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

enum PremiumListType {
    case backup
    case removeDuplicate
    case faceRecognition
    case placeRecognition
    case objectRecognition
    case unlimitedPhotopick
    case additionalData
    
    case storeInHQ
    case fiveAnalysis
    case tenAnalysis
    case dataPackage
    case deleteDublicates
    
    static var allTypes: [PremiumListType] {
        ///FE-953 Deleting "Extra Data Package" icon and text
//        return [.backup, .removeDuplicate, .faceRecognition, .placeRecognition, .objectRecognition, .unlimitedPhotopick, .additionalData]
        return [.backup, .removeDuplicate, .faceRecognition, .placeRecognition, .objectRecognition, .unlimitedPhotopick]
    }
    
    static var standardTypes: [PremiumListType] {
        ///FE-953 Deleting "Extra Data Package" icon and text
//        return [.storeInHQ, .fiveAnalysis, .dataPackage]
        return [.storeInHQ, .fiveAnalysis]
    }
    
    static var midTypes: [PremiumListType] {
        ///FE-953 Deleting "Extra Data Package" icon and text
//        return [.storeInHQ, .deleteDublicates, .faceRecognition, .placeRecognition, .objectRecognition, .tenAnalysis, .additionalData]
        return [.storeInHQ, .deleteDublicates, .faceRecognition, .placeRecognition, .objectRecognition, .tenAnalysis]
    }
    
    var image: UIImage? {
        switch self {
        case .backup:
            return UIImage(named: "backupPremiumIcon")
        case .removeDuplicate:
            return UIImage(named: "removeDuplicatePremiumIcon")
        case .faceRecognition:
            return UIImage(named: "faceImagePremiumIcon")
        case .placeRecognition:
            return UIImage(named: "placeRecognitionPremiumIcon")
        case .objectRecognition:
            return UIImage(named: "objectRecognitionPremiumIcon")
        case .unlimitedPhotopick:
            return UIImage(named: "unlimitedPhotopickIcon")
        case .storeInHQ:
            return UIImage(named: "backupPremiumIcon")
        case .fiveAnalysis:
            return UIImage(named: "unlimitedPhotopickIcon")
        case .tenAnalysis:
            return UIImage(named: "unlimitedPhotopickIcon")
        case .dataPackage:
            return UIImage(named: "additionalDataIcon")
        case .deleteDublicates:
            return UIImage(named: "removeDuplicatePremiumIcon")
        case .additionalData:
            return UIImage(named: "additionalDataIcon")
        }
    }
    
    var message: String {
        switch self {
            case .backup:
                return TextConstants.backUpOriginalQuality
            case .removeDuplicate:
                return TextConstants.removeDuplicateContacts
            case .faceRecognition:
                return TextConstants.faceRecognitionToReach
            case .placeRecognition:
                return TextConstants.placeRecognitionToBeam
            case .objectRecognition:
                return TextConstants.objectRecognitionToRemember
            case .unlimitedPhotopick:
                return TextConstants.unlimitedPhotopickAnalysis
            case .storeInHQ:
                return TextConstants.storeInHighQuality
            case .fiveAnalysis:
                return TextConstants.fiveAnalysis
            case .tenAnalysis:
                return TextConstants.tenAnalysis
            case .dataPackage:
                return TextConstants.dataPackageForTurkcell
            case .deleteDublicates:
                return TextConstants.deleteDuplicatedContacts
            case .additionalData:
                return TextConstants.additionalDataAdvantage
        }
    }
}

final class PremiumListView: UIView {
    
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    
    @IBOutlet private var view: UIView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    // MARK: Utility methods(Public)
    func configure(with title: String, image: UIImage) {
        titleLabel.text = title
        iconImageView.image = image
    }
    
    // MARK: Utility methods(Private)
    private func setupView() {
        let nibNamed = String(describing: PremiumListView.self)
        Bundle(for: PremiumListView.self).loadNibNamed(nibNamed, owner: self, options: nil)
        guard let view = view else { return }
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true
        view.backgroundColor = AppColor.settingsBackground.color
        addSubview(view)
    }
    
    private func setup() {
        setupDesign()
    }
    
    private func setupDesign() {
        titleLabel.font = .appFont(.medium, size: 15)
        titleLabel.textColor = ColorConstants.darkText
    }

}
