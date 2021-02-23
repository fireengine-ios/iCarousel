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
    
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            newValue.textAlignment = .left
            newValue.font = .GTAmericaStandardMediumFont(size: 20)
            newValue.textColor = ColorConstants.Text.labelTitle
            newValue.text = TextConstants.PrivateShare.page_title
        }
    }
    
    
    @IBOutlet private weak var closeButton: UIButton! {
        willSet {
            newValue.setTitle("", for: .normal)
            newValue.setImage(UIImage(named: "close"), for: .normal)
        }
    }
    
    @IBOutlet private weak var scrollView: DismissKeyboardScrollView! {
        willSet {
            newValue.keyboardDismissMode = .interactive
            newValue.delaysContentTouches = false
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
    
    @IBOutlet private weak var shareButton: UIButton! {
        willSet {
            newValue.clipsToBounds = true
            newValue.layer.cornerRadius = 5.0
            
            newValue.setTitle(TextConstants.PrivateShare.start, for: .normal)
            
            newValue.setTitleColor(.white, for: .normal)
            newValue.setBackgroundColor(ColorConstants.PrivateShare.shareButtonBackgroundEnabled, for: .normal)
            
            newValue.titleLabel?.font = .GTAmericaStandardMediumFont(size: 14)
            newValue.isEnabled = false
        }
    }
    
    private lazy var selectPeopleView = PrivateShareSelectPeopleView.with(delegate: self)
    private lazy var shareWithView = PrivateShareWithView.with(contacts: [], delegate: self)
    private lazy var messageView = PrivateShareAddMessageView.initFromNib()
    private lazy var durationView = PrivateShareDurationView.initFromNib()
    private lazy var searchSuggestionController = PrivateShareLocalSuggestionsViewController.with(delegate: self)
    
    private let minSearchLength = 2
    
    private var items = [WrapData]()
    private var remoteSuggestions = [SuggestedApiContact]()
    private var hasAccess = false
    
    private var startThresholdDate: Date?
    
    private lazy var shareApiService = PrivateShareApiServiceImpl()
    
    private let suggestionsOperationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    private lazy var router = RouterVC()
    private lazy var analytics = PrivateShareAnalytics()
    
    override var keyboardHeight: CGFloat {
        didSet {
            let offset = max(0, keyboardHeight - bottomView.frame.height)
//            searchSuggestionsContainerBottomOffset.constant = offset
            scrollView.contentInset.bottom = offset
        }
    }
    
    //MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.addArrangedSubview(selectPeopleView)
        setupSuggestedSubjects(searchText: "")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        super.viewDidDisappear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        selectPeopleView.layoutSubviews()
    }
    
    private func setupSuggestedSubjects(searchText: String) {
        
        if let thresholdDate = startThresholdDate,
           Date().timeIntervalSince(thresholdDate) * 1000 < 50 {
            return
        }
        startThresholdDate = Date()
        
        suggestionsOperationQueue.cancelAllOperations()
        
        let fixed = searchText.precomposedStringWithCanonicalMapping
        let encodedText = fixed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? searchText
        
        let operation = PrivateShareSuggestionsOperation(searchText: encodedText) { [weak self] result in
            switch result {
            case .success(let contacts):
                self?.removeRemoteSuggestionsView()
                self?.remoteSuggestions = contacts
                self?.showRemoteSuggestions()
            case .failed(let error):
                if let customError = error as? OperationError,
                   case OperationError.cancelled = customError {
                    debugPrint("Private Share operation cancelled")
                } else {
                    UIApplication.showErrorAlert(message: error.description)
                }
                
            }
        }
        suggestionsOperationQueue.addOperation(operation)
    }
    
    private func showRemoteSuggestions() {
        guard !remoteSuggestions.isEmpty else {
            return
        }
        
        let suggestedContacts = remoteSuggestions.map { contact -> SuggestedContact in
                return SuggestedContact(with: contact)
        }
        
        if !contentView.arrangedSubviews.contains(where: { $0 is PrivateShareSuggestionsView }) {
            let view = PrivateShareSuggestionsView.with(contacts: suggestedContacts, delegate: self)
            contentView.insertArrangedSubview(view, at: 1)
        }
    }
    
    private func removeRemoteSuggestionsView() {
        if let suggestionsView = contentView.arrangedSubviews.first(where: { $0 is PrivateShareSuggestionsView }) {
            suggestionsView.removeFromSuperview()
        }
    }
    
    private func updateShareButtonIfNeeded() {
        let hasContacts = !shareWithView.contacts.isEmpty
        shareButton.isEnabled = hasContacts
    }
    
    private func showShareViews() {
        let orderedViews = [shareWithView, messageView, durationView]
        orderedViews.forEach { contentView.addArrangedSubview($0) }
    }
    
    private func hideShareViews() {
        let orderedViews = [shareWithView, messageView, durationView]
        orderedViews.forEach { $0.removeFromSuperview() }
    }
    
    private func endSearchContacts() {
        view.endEditing(true)
        removeRemoteSuggestionsView()
    }

    //MARK: - Actions
    
    @IBAction private func onCloseTapped(_ sender: Any) {
        if shareWithView.contacts.isEmpty {
           dismiss(animated: true)
        } else {
            let popup = PopUpController.with(title: nil,
                                             message: TextConstants.PrivateShare.close_page,
                                             image: .question,
                                             firstButtonTitle: TextConstants.PrivateShare.close_page_no,
                                             secondButtonTitle: TextConstants.PrivateShare.close_page_yes,
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
        
        remoteSuggestions = []
        let sharedItems = items.compactMap { PrivateShareObjectItem(accountUuid: $0.accountUuid, uuid: $0.uuid) }
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
//            searchSuggestionsContainer.isHidden = true
    }
    
    func searchTextDidChange(text: String) {
        setupSuggestedSubjects(searchText: text)
    }
    
    func hideKeyboard(text: String) {
//        if text.count < minSearchLength {
//            removeRemoteSuggestionsView()
//        }
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
//        searchSuggestionsContainer.isHidden = isEmpty
    }
}
