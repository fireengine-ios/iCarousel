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
    
    @IBOutlet private weak var scrollView: DismissKeyboardScrollView! {
        willSet {
            newValue.keyboardDismissMode = .interactive
            newValue.delaysContentTouches = false
        }
    }
    
    @IBOutlet private weak var contentView: UIStackView!
    @IBOutlet private weak var searchSuggestionsContainer: UIView!
    @IBOutlet private weak var searchSuggestionsContainerBottomOffset: NSLayoutConstraint!
    
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
    private lazy var searchSuggestionController = PrivateShareLocalSuggestionsViewController.with(delegate: self)
    
    private let minSearchLength = 2
    
    private var items = [WrapData]()
    private var remoteSuggestions = [SuggestedApiContact]()
    private var hasAccess = false
    
    private lazy var shareApiService = PrivateShareApiServiceImpl()
    private lazy var localContactsService = ContactsSuggestionServiceImpl()
    private lazy var router = RouterVC()
    private lazy var analytics = PrivateShareAnalytics()
    
    override var keyboardHeight: CGFloat {
        didSet {
            let offset = max(0, keyboardHeight - bottomView.frame.height)
            searchSuggestionsContainerBottomOffset.constant = offset
            scrollView.contentInset.bottom = offset
        }
    }
    
    //MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = TextConstants.actionSheetShare
        navigationItem.leftBarButtonItem = closeButton
        needCheckModalPresentationStyle = false
        
        contentView.addArrangedSubview(selectPeopleView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationBarWithGradientStyle()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        selectPeopleView.layoutSubviews()
    }
    
    private func getRemoteSuggestions() {
        //load remote suggestion once
        if !remoteSuggestions.isEmpty {
            showRemoteSuggestions()
            return
        }
        
        let group = DispatchGroup()
        
        group.enter()
        group.enter()
        
        localContactsService.fetchAllContacts { [weak self] isAuthorized in
            self?.hasAccess = isAuthorized
            group.leave()
        }
            
        shareApiService.getSuggestions { [weak self] result in
            switch result {
            case .success(let contacts):
                self?.remoteSuggestions = contacts
            case .failed(let error):
                UIApplication.showErrorAlert(message: error.description)
            }
            group.leave()
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.showRemoteSuggestions()
        }
    }
    
    private func showRemoteSuggestions() {
        guard !remoteSuggestions.isEmpty else {
            return
        }
        
        let suggestedContacts = remoteSuggestions
            .filter { $0.isEmailUnhidden || $0.isUsernameUnhidden }
            .map { contact -> SuggestedContact in
            if hasAccess {
                let msisdnToSearch = contact.isUsernameUnhidden ? contact.username ?? "" : ""
                let emailToSearch = contact.isEmailUnhidden ? contact.email ?? "" : ""
                let names = self.localContactsService.getContactName(for: msisdnToSearch, email: emailToSearch)
                return SuggestedContact(with: contact, names: names)
            } else {
                return SuggestedContact(with: contact)
            }
        }
        
        if !contentView.arrangedSubviews.contains(where: { $0 is PrivateShareSuggestionsView }) {
            let view = PrivateShareSuggestionsView.with(contacts: suggestedContacts, delegate: self)
            contentView.insertArrangedSubview(view, at: 1)
        }
    }
    
    private func searchLocalSuggestions(query: String) {
        removeRemoteSuggestionsView()
        
        let preparedQuery = prepare(searchQuery: query)
        searchSuggestionController.update(with: preparedQuery)
    }
    
    private func removeRemoteSuggestionsView() {
        if let suggestionsView = contentView.arrangedSubviews.first(where: { $0 is PrivateShareSuggestionsView }) {
            suggestionsView.removeFromSuperview()
        }
    }
    
    private func removeLocalSuggestionsView() {
        if !searchSuggestionsContainer.isHidden {
            searchSuggestionController.update(with: "")
            searchSuggestionsContainer.isHidden = true
        }
    }
    
    //workaround to support search without +9 for turkish msisdn
    private func prepare(searchQuery: String) -> String {
        let prefixToCheck = "+90" //Turkey country code
        let numberOfCharsToSearch = searchQuery.count - prefixToCheck.count + 1
        
        guard
            numberOfCharsToSearch >= minSearchLength,
            searchQuery.hasPrefix(prefixToCheck)
        else {
            return searchQuery
        }
        
        return String(searchQuery.suffix(numberOfCharsToSearch))
    }
    
    private func updateShareButtonIfNeeded() {
        let needEnable = !shareWithView.contacts.isEmpty
        shareButton.isEnabled = needEnable
        shareButton.backgroundColor = needEnable ? ColorConstants.navy : .lightGray
    }
    
    private func showShareViews() {
        let orderedViews = [shareWithView, messageView, durationView]
        orderedViews.forEach { contentView.addArrangedSubview($0) }
    }
    
    private func hideShareViews() {
        let orderedViews = [shareWithView, messageView, durationView]
        orderedViews.forEach { $0.removeFromSuperview() }
    }
    
    private func showSearchLocalContactsViewIfNeeded() {
        guard searchSuggestionsContainer.isHidden else {
            return
        }
        
        scrollView.contentOffset = .zero
        if searchSuggestionController.contentView.superview == nil {
            searchSuggestionsContainer.addSubview(searchSuggestionController.contentView)
            searchSuggestionController.contentView.translatesAutoresizingMaskIntoConstraints = false
            searchSuggestionController.contentView.pinToSuperviewEdges()
        }
        searchSuggestionsContainer.isHidden = false
    }
    
    private func endSearchContacts() {
        removeRemoteSuggestionsView()
        removeLocalSuggestionsView()
    }

    //MARK: - Actions
    
    @objc private func onCancelTapped(_ sender: Any) {
        if shareWithView.contacts.isEmpty {
           dismiss(animated: true)
        } else {
            let popup = PopUpController.with(title: nil,
                                             message: TextConstants.privateShareStartPageClosePopupMessage,
                                             image: .question,
                                             firstButtonTitle: TextConstants.cancel,
                                             secondButtonTitle: TextConstants.ok,
                                             firstAction: { vc in
                                                vc.close()
                                             },
                                             secondAction: { [weak self] vc in
                                                vc.close { [weak self] in
                                                    self?.dismiss(animated: true)
                                                }
                                             })
            router.presentViewController(controller: popup)
        }
    }

    @IBAction private func onShareTapped(_ sender: Any) {
        guard let projectId = SingletonStorage.shared.accountInfo?.projectID else {
            return
        }
        
        remoteSuggestions = []
        let sharedItems = items.compactMap { PrivateShareObjectItem(projectId: projectId, uuid: $0.uuid) }
        let shareObject = PrivateShareObject(items: sharedItems,
                                             invitationMessage: messageView.message,
                                             invitees: shareWithView.contacts,
                                             type: .file,
                                             duration: durationView.duration)
   
        shareApiService.privateShare(object: shareObject) { [weak self] result in
            switch result {
            case .success:
                if let items = self?.items {
                    ItemOperationManager.default.didShare(items: items)
                    self?.analytics.successShare(items: items, duration: shareObject.duration, message: shareObject.invitationMessage)
                }
                SnackbarManager.shared.show(type: .nonCritical, message: TextConstants.privateShareStartPageSuccess)
                self?.dismiss(animated: true)
            case .failed(let error):
                let errorMessage = (error as? ServerMessageError)?.getPrivateShareError() ?? TextConstants.temporaryErrorOccurredTryAgainLater
                UIApplication.showErrorAlert(message: errorMessage)
            }
        }
    }
}

//MARK: - PrivateShareSelectPeopleViewDelegate

extension PrivateShareViewController: PrivateShareSelectPeopleViewDelegate {
    
    func startEditing(text: String) {
        if text.count < minSearchLength {
            getRemoteSuggestions()
            searchSuggestionsContainer.isHidden = true
        } else if hasAccess {
            showSearchLocalContactsViewIfNeeded()
            searchLocalSuggestions(query: text)
        } else {
            removeRemoteSuggestionsView()
        }
    }
    
    func searchTextDidChange(text: String) {
        if text.count < minSearchLength {
            removeLocalSuggestionsView()
        } else if hasAccess {
            
            //we need this trimming for prepare(), so our +90 logic would work with whitespaces
            let trimmedText = text.filter{ $0 != " " }
            showSearchLocalContactsViewIfNeeded()
            searchLocalSuggestions(query: trimmedText)
        } else {
            removeRemoteSuggestionsView()
        }
    }
    
    func hideKeyboard(text: String) {
        if text.count < minSearchLength {
            removeRemoteSuggestionsView()
        }
    }
    
    func addShareContact(_ contact: PrivateShareContact) {
        if let maxInviteeCount = SingletonStorage.shared.featuresInfo?.maxSharingInviteeCount,
            shareWithView.contacts.count >= maxInviteeCount {
            UIApplication.showErrorAlert(message: String(format: TextConstants.privateShareMaxNumberOfUsersMessageFormat, maxInviteeCount))
            return
        }
        
        guard isValidContact(text: contact.username) else {
            return
        }
        
        selectPeopleView.clear()
        shareWithView.add(contact: contact)
        if shareWithView.superview == nil {
            showShareViews()
        }
        endSearchContacts()
        updateShareButtonIfNeeded()
    }
    
    private func isValidContact(text: String) -> Bool {
        if text.contains("@") {
            if Validator.isValid(email: text) {
                return true
            } else {
                UIApplication.showErrorAlert(message: TextConstants.privateShareEmailValidationFailPopUpText)
                return false
            }
        }

        if !Validator.isValid(contactsPhone: text) {
            UIApplication.showErrorAlert(message: TextConstants.privateSharePhoneValidationFailPopUpText)
            return false
        }

        if !text.contains("+"), !Validator.isValid(turkcellPhone: text) {
            UIApplication.showErrorAlert(message: TextConstants.privateShareNonTurkishMsisdnPopUpText)
            return false
        }

        return true
    }

}

//MARK: - PrivateShareWithViewDelegate

extension PrivateShareViewController: PrivateShareWithViewDelegate {
    
    func shareListDidEmpty() {
        hideShareViews()
        updateShareButtonIfNeeded()
    }
    
    func onUserRoleTapped(contact: PrivateShareContact, sender: Any) {
        let userRoleController = PrivateShareUserRoleViewController.with(contact: contact, delegate: sender as? PrivateShareUserRoleViewControllerDelegate)
        present(userRoleController, animated: true)
    }
}

//MARK: - PrivateShareSelectSuggestionsDelegate

extension PrivateShareViewController: PrivateShareSelectSuggestionsDelegate {
    
    func didSelect(contactInfo: ContactInfo) {
        selectPeopleView.setContact(info: contactInfo)
        endSearchContacts()
    }
    
    func contactListDidUpdate(isEmpty: Bool) {
        //display container only if local suggestions count > 0
        searchSuggestionsContainer.isHidden = isEmpty
    }
}
