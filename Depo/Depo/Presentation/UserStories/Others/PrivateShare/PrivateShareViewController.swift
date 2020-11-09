//
//  PrivateShareViewController.swift
//  Depo
//
//  Created by Andrei Novikau on 11/5/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class PrivateShareViewController: BaseViewController, NibInit {

    static func with(items: [WrapData]) -> PrivateShareViewController {
        let controller = PrivateShareViewController.initFromNib()
        controller.items = items
        return controller
    }
    
    @IBOutlet private weak var scrollView: UIScrollView! {
        willSet {
            newValue.keyboardDismissMode = .interactive
        }
    }
    
    @IBOutlet private weak var contentView: UIStackView!
    
    @IBOutlet private weak var bottomView: UIView! {
        willSet {
            newValue.layer.shadowColor = UIColor.black.cgColor
            newValue.layer.shadowOpacity = 0.1
            newValue.layer.shadowOffset = .zero
            newValue.layer.shadowRadius = 5
        }
    }
    @IBOutlet private weak var shareButton: RoundedButton! {
        willSet {
            newValue.setTitle(TextConstants.privateShareStartPageShareButton, for: .normal)
            newValue.setTitleColor(.white, for: .normal)
            newValue.backgroundColor = .lightGray
            newValue.titleLabel?.font = .TurkcellSaturaDemFont(size: 16)
            newValue.isEnabled = false
        }
    }
    
    private lazy var closeButton = UIBarButtonItem(title: TextConstants.privateShareStartPageCloseButton,
                                                   font: UIFont.TurkcellSaturaDemFont(size: 19),
                                                   tintColor: UIColor.white,
                                                   accessibilityLabel: TextConstants.cancel,
                                                   style: .plain,
                                                   target: self,
                                                   selector: #selector(onCancelTapped))
    
    private lazy var selectPeopleView = PrivateShareSelectPeopleView.with(delegate: self)
    private lazy var shareWithView = PrivateShareWithView.with(contacts: [], delegate: self)
    private lazy var messageView = PrivateShareAddMessageView.initFromNib()
    private lazy var durationView = PrivateShareDurationView.initFromNib()
    
    private let minSearchLength = 2
    
    private var items = [WrapData]()
    
    private lazy var shareApiService = PrivateShareApiServiceImpl()
    private lazy var localContactsService = ContactsSuggestionServiceImpl()
    
    //MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = TextConstants.actionSheetShare
        navigationItem.leftBarButtonItem = closeButton
        
        contentView.addArrangedSubview(selectPeopleView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationBarWithGradientStyle()
    }
    
    private func getSuggestions() {
        let group = DispatchGroup()
        
        group.enter()
        group.enter()
        
        var hasAccess = false
        var apiContacts = [SuggestedApiContact]()
        
        localContactsService.fetchAllContacts { isAuthorized in
            hasAccess = isAuthorized
            group.leave()
        }
            
        shareApiService.getSuggestions { result in
            switch result {
            case .success(let contacts):
                apiContacts = contacts
            case .failed(let error):
                UIApplication.showErrorAlert(message: error.description)
            }
            group.leave()
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.showApiSuggestions(contacts: apiContacts, hasAccess: hasAccess)
        }
    }
    
    private func showApiSuggestions(contacts: [SuggestedApiContact], hasAccess: Bool) {
        guard !contacts.isEmpty else {
            return
        }
        
        let suggestedContacts = contacts.map { contact -> SuggestedContact in
            if hasAccess {
                let names = self.localContactsService.getContactName(for: contact.username ?? "", email: contact.email ?? "")
                return SuggestedContact(with: contact, names: names)
            } else {
                return SuggestedContact(with: contact)
            }
        }
        
        let view = PrivateShareSuggestionsView.with(contacts: suggestedContacts, delegate: self)
        contentView.addArrangedSubview(view)
    }
    
    private func searchSuggestions(query: String) {
        //TODO: implement search controller and needed logic
    }
    
    private func updateShareButtonIfNeeded() {
        let needEnable = true //TODO: need to implement check logic
        shareButton.isEnabled = needEnable
        shareButton.backgroundColor = needEnable ? ColorConstants.navy : .lightGray
    }
    
    private func showShareViews() {
        contentView.insertArrangedSubview(shareWithView, at: 1)
        contentView.insertArrangedSubview(messageView, at: 2)
        contentView.insertArrangedSubview(durationView, at: 3)
    }
    
    private func hideShareViews() {
        contentView.arrangedSubviews.dropFirst().forEach { $0.removeFromSuperview() }
    }

    //MARK: - Actions
    
    @objc private func onCancelTapped(_ sender: Any) {
        dismiss(animated: true)
    }

    @IBAction private func onShareTapped(_ sender: Any) {
        //TODO: continue sharing
    }
}

//MARK: - PrivateShareSelectPeopleViewDelegate

extension PrivateShareViewController: PrivateShareSelectPeopleViewDelegate {
    
    func startEditing(text: String) {
        if text.count < minSearchLength {
            getSuggestions()
        } else {
            searchSuggestions(query: text)
        }
        hideShareViews()
    }
    
    func addShareContact(_ contact: PrivateShareContact) {
        shareWithView.add(contact: contact)
        if shareWithView.superview == nil {
            showShareViews()
        }
    }
    
    func onUserRoleTapped() {
        //TODO: open user roles controller
    }
}

//MARK: - PrivateShareSuggestionsViewDelegate

extension PrivateShareViewController: PrivateShareSuggestionsViewDelegate {
    func selectContact(displayName: String, username: String) {
        selectPeopleView.setContact(displayName: displayName, username: username)
        
        if let suggestionsView = contentView.arrangedSubviews.first(where: { $0 is PrivateShareSuggestionsView }) {
            suggestionsView.removeFromSuperview()
        }
        
        view.endEditing(true)
        
        //TODO: close search suggestions controller
    }
}

//MARK: - PrivateShareWithViewDelegate

extension PrivateShareViewController: PrivateShareWithViewDelegate {
    
    func shareListDidEmpty() {
        hideShareViews()
    }
    
    func onUserRoleTapped(contact: PrivateShareContact, sender: Any) {
        //TODO: open user roles controller and observe selections
    }
}
