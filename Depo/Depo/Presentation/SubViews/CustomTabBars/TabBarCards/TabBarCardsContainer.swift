//
//  TabBarCardsContainer.swift
//  Depo
//
//  Created by Hady on 6/2/22.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation
import UIKit

final class TabBarCardsContainer: UIView, CardsManagerViewProtocol {

    private let lock = NSLock()
    private let stackView = UIStackView()
    private let permittedOperationTypes: Set<OperationType> = [
        .prepareQuickScroll,
        .sync,
        .upload,
        .sharedWithMeUpload,
        .download,
        .itemSelection
    ]

    private var viewsByType: [OperationType: BaseTabBarCard] = [:]
    var isEnable = true

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }

    func configure() {
        backgroundColor = .clear
        stackView.spacing = -16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        addSubview(stackView)
        stackView.pinToSuperviewEdges()
    }

    func addCardView(_ cardView: BaseTabBarCard) {
        DispatchQueue.main.async {

            self.lock.lock()
            self.stackView.addArrangedSubview(cardView)
            self.updateBackgroundForCards()
            self.lock.unlock()
        }
    }

    func removeCardView(_ cardView: BaseTabBarCard) {
        DispatchQueue.main.async {
            if self.stackView.arrangedSubviews.contains(cardView) {
                self.lock.lock()
                self.stackView.removeArrangedSubview(cardView)
                cardView.removeFromSuperview()
                self.updateBackgroundForCards()
                self.lock.unlock()
            }
        }
    }

    private func updateBackgroundForCards() {
        for (index, subview) in stackView.arrangedSubviews.enumerated() {
            if let cardView = subview as? BaseTabBarCard {
                let backgroundColor: AppColor = index % 2 == 0 ? .tabBarCardBackground : .tabBarCardBackgroundAlternative
                cardView.backgroundColor = backgroundColor.color
            }
        }
    }

    // MARK: WrapItemOperationViewProtocol

    private func checkIsThisIsPermittedType(type: OperationType) -> Bool {
        return permittedOperationTypes.contains(type)
    }

    func getViewForOperation(operation: OperationType) -> BaseTabBarCard? {
        switch operation {
        case .prepareQuickScroll:
            return PrepareForQuickScrollTabBarCard.initFromNib()

        case .sync,
             .upload,
             .sharedWithMeUpload,
             .download:
            return ProgressTabBarCard.initFromNib()
        
        case .itemSelection:
            return SelectionTabBarCard.initFromNib()

        default:
            return nil
        }
    }

    func startOperationWith(type: OperationType, allOperations: Int?, completedOperations: Int?, itemCount: Int?) {
        startOperationWith(type: type, object: nil, allOperations: allOperations, completedOperations: completedOperations, itemCount: itemCount)
    }

    func startOperationWith(type: OperationType, object: WrapData?, allOperations: Int?, completedOperations: Int?, itemCount: Int?) {
        if !checkIsThisIsPermittedType(type: type) {
            return
        }

        guard viewsByType[type] == nil else {
            return
        }
        
//        let isShownPrepareQuickScroll: Bool = UserDefaults.standard.bool(forKey: "prepareQuickScrollProgressIsShown")
//        if type == .prepareQuickScroll && isShownPrepareQuickScroll {
//            return
//        }
//        UserDefaults.standard.set(true, forKey: "prepareQuickScrollProgressIsShown")
//
        let isShownSyncing: Bool = UserDefaults.standard.bool(forKey: "sycningProgressIsShown")
        if type == .sync && isShownSyncing {
            return
        }
        UserDefaults.standard.set(true, forKey: "sycningProgressIsShown")

        if let view = getViewForOperation(operation: type) {
            viewsByType[type] = view

            if let progressCard = view as? ProgressTabBarCard {
                progressCard.configure(with: type)
                progressCard.setProgress(allItems: allOperations, readyItems: completedOperations)
                if let item = object {
                    progressCard.setImageForUploadingItem(item: item)
                }
            }
            
            if let card = view as? SelectionTabBarCard {
                card.setCountLabel(count: itemCount ?? 0)
            }
            addCardView(view)
        }
    }

    func setProgressForOperationWith(type: OperationType, object: WrapData?, allOperations: Int, completedOperations: Int, itemCount: Int?) {
        guard let view = viewsByType[type] else {
            startOperationWith(type: type, allOperations: allOperations, completedOperations: completedOperations, itemCount: itemCount)
            return
        }

        if let progressCard = view as? ProgressTabBarCard {
            progressCard.setProgress(allItems: allOperations, readyItems: completedOperations)
            if let item = object {
                progressCard.setImageForUploadingItem(item: item)
            }
        }
        
        if let card = view as? SelectionTabBarCard {
            card.setCountLabel(count: itemCount ?? 0)
        }
    }

    func setProgress(ratio: Float, for operationType: OperationType, object: WrapData? ) {
        guard let progressCard = viewsByType[operationType] as? ProgressTabBarCard else {
            return
        }

        progressCard.setProgress(ratio: ratio)
        if let object = object {
            progressCard.setImageForUploadingItem(item: object)
        }
    }

    func stopOperationWithType(type: OperationType) {
        if let view = viewsByType[type] {
            viewsByType[type] = nil
            removeCardView(view)
        }
    }

    func stopOperationWithType(type: OperationType, serverObject: HomeCardResponse) {
        stopOperationWithType(type: type)
    }

    func isEqual(object: CardsManagerViewProtocol) -> Bool {
        if let compairedView = object as? CardsContainerView {
            return compairedView == self
        }
        return false
    }

    func startOperationsWith(serverObjects: [HomeCardResponse]) {}
    func addNotPermittedCardViewTypes(types: [OperationType]) {}
    func configureInstaPick(with analysisStatus: InstapickAnalyzesCount) {}
}
