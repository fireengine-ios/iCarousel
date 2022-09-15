//
//  AcceptedInvitationViewController.swift
//  Depo
//
//  Created by Alper Kırdök on 17.05.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

import UIKit

enum InvitationType {
    case reference
    case paycell
}

class AcceptedInvitationViewController: BaseViewController {

    @IBOutlet weak var acceptedCollectionView: UICollectionView!

    private let pageSize = 100
    private var pageNumber = 0
    var isFetchingAcceptedList = false
    var hasMore = true

    private var acceptedList: [InvitationRegisteredAccount] = []
    private var accountBGColors: [UIColor] = []
    private var invitationType: InvitationType = .reference
    
    convenience init(invitationType: InvitationType) {
        self.init()
        self.invitationType = invitationType
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setTitle(withString: TextConstants.invitationFriends)
        setupCollectionView()

        if invitationType == .reference {
            fetchInvitationAcceptedList(pageNumber: self.pageNumber)
        } else {
            fetchPaycellAcceptedList(pageNumber: pageNumber)
        }
    }

    private func setupCollectionView() {
        acceptedCollectionView.register(nibCell: AcceptedPeopleCollectionViewCell.self)
    }

    func fetchInvitationAcceptedList(pageNumber: Int) {
        self.showSpinner()
        isFetchingAcceptedList = true
        InvitationApiService().getInvitationList(pageNumber: pageNumber, pageSize: pageSize) { [weak self] result in
            defer {
                self?.isFetchingAcceptedList = false
                self?.hideSpinner()
            }
            switch result {
            case .success(let response):
                self?.hasMore = response.hasMore
                self?.acceptedList.append(contentsOf: response.accounts)
                self?.accountBGColors = AccountConstants.shared.generateBGColors(numberOfItems: self?.acceptedList.count ?? 0)
                self?.acceptedCollectionView.reloadData()
            case .failed(let error):
                print("invitation Accepted response error = \(error.description)")
            }
        }
    }
    
    func fetchPaycellAcceptedList(pageNumber: Int) {
        self.showSpinner()
        isFetchingAcceptedList = true
        PaycellCampaignService().paycellAcceptedList(pageNumber: pageNumber, pageSize: pageSize) { [weak self] result in
            defer {
                self?.isFetchingAcceptedList = false
                self?.hideSpinner()
            }
            switch result {
            case .success(let response):
                self?.hasMore = response.hasMore
                self?.acceptedList.append(contentsOf: response.accounts)
                self?.accountBGColors = AccountConstants.shared.generateBGColors(numberOfItems: self?.acceptedList.count ?? 0)
                self?.acceptedCollectionView.reloadData()
            case .failed(let error):
                print("Paycell Accepted response error = \(error.description)")
            }
        }
    }

}

extension AcceptedInvitationViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 45);
    }
}

extension AcceptedInvitationViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return acceptedList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let acceptedPeople = self.acceptedList[indexPath.item]
        let bgColor = self.accountBGColors[indexPath.item]
        let cell = collectionView.dequeue(cell: AcceptedPeopleCollectionViewCell.self, for: indexPath)
        cell.configureCell(invitationRegisteredAccount: acceptedPeople, bgColor: bgColor)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard indexPath.item == self.acceptedList.count - 1,
              self.isFetchingAcceptedList == false, self.hasMore == true
        else {
            return
        }

        self.pageNumber += 1
        
        if invitationType == .reference {
            fetchInvitationAcceptedList(pageNumber: self.pageNumber)
        } else {
            fetchPaycellAcceptedList(pageNumber: self.pageNumber)
        }
    }
}
