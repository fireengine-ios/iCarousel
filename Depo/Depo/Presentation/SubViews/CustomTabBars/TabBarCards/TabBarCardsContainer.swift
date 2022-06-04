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
        .prepareQuickScroll
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
            self.stackView.insertArrangedSubview(cardView, at: 0)
            self.stackView.sendSubviewToBack(cardView)
            self.lock.unlock()
        }
    }

    func removeCardView(_ cardView: BaseTabBarCard) {
        DispatchQueue.main.async {
            if self.stackView.arrangedSubviews.contains(cardView) {
                self.lock.lock()
                self.stackView.removeArrangedSubview(cardView)
                cardView.removeFromSuperview()
                self.lock.unlock()
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
        default:
            return nil
        }
    }

    func startOperationWith(type: OperationType, allOperations: Int?, completedOperations: Int?) {
        startOperationWith(type: type, object: nil, allOperations: allOperations, completedOperations: completedOperations)
    }

    func startOperationWith(type: OperationType, object: WrapData?, allOperations: Int?, completedOperations: Int?) {
        if !checkIsThisIsPermittedType(type: type) {
            return
        }

        guard viewsByType[type] == nil else {
            return
        }

        if let view = getViewForOperation(operation: type) {
            viewsByType[type] = view
            // TODO: Facelift, progress?
//            if let popUp = view as? ProgressCard {
//                popUp.setProgress(allItems: allOperations, readyItems: completedOperations)
//                if let item = object {
//                    popUp.setImageForUploadingItem(item: item)
//                }
//            }
            addCardView(view)
        }
    }

    func setProgressForOperationWith(type: OperationType, object: WrapData?, allOperations: Int, completedOperations: Int ) {
        if let view = viewsByType[type] {
            // TODO: FAcelift
//            if let popUp = view as? ProgressCard {
//                popUp.setProgress(allItems: allOperations, readyItems: completedOperations)
//                if let item = object {
//                    popUp.setImageForUploadingItem(item: item)
//                }
//            }
        } else {
            startOperationWith(type: type, allOperations: allOperations, completedOperations: completedOperations)
        }
    }

    func setProgress(ratio: Float, for operationType: OperationType, object: WrapData? ) {
        // TODO: FAcelift
//        guard isActive else {
//            return
//        }
//        guard let popUp = viewsByType[operationType] as? ProgressCard else {
//            return
//        }
//
//        popUp.setProgressBar(ratio: ratio)
//        if let `object` = object {
//            popUp.setImageForUploadingItem(item: object)
//        }
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
