//
//  DocumentsAlbumCard.swift
//  Depo
//
//  Created by Maxim Soldatov on 4/20/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

final class DocumentsAlbumCard: BaseCardView {
    
    @IBOutlet private weak var contentStackView: UIStackView!
    @IBOutlet private weak var imagesStackView: UIStackView!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var viewDocumentButton: UIButton!
    
    private lazy var tapGestureRocognizer: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        return gesture
    }()
    
    private let imagesInStackView: CGFloat = 4
    private var viewAlreadySet = false
    
    private lazy var hideActionService: HideActionServiceProtocol = HideActionService()
    private lazy var albumService = PhotosAlbumService()
    private lazy var router = RouterVC()
    private var thingsItem: ThingsItem?
    private var albumItem: AlbumItem?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addTapGestureRecognizer()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addTapGestureRecognizer()
    }
    
    private func addTapGestureRecognizer() {
       addGestureRecognizer(tapGestureRocognizer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let height = contentStackView.frame.size.height
        if calculatedH != height {
            calculatedH = height
            layoutIfNeeded()
        }
    }
    
    override func set(object: HomeCardResponse?) {
        super.set(object: object)
        guard
            let details = object?.details,
            let model =  DocumentsAlbumCardResponce.init(json: details),
            let fileList = object?.fileList?.compactMap({WrapData(searchResponse: $0)})
        else {
            assertionFailure()
            return
        }
        
        thingsItem =  ThingsItem(response: model.thingsItem)
        albumItem = AlbumItem(uuid: model.albumUuid, name: thingsItem?.name, creationDate: model.creationDate, lastModifiDate: nil, fileType: .photoAlbum, syncStatus: .notSynced, isLocalItem: false)
        setupCardView(documentsAlbumResponse: model, fileList: fileList)
    }
    
    private func setupCardView(documentsAlbumResponse: DocumentsAlbumCardResponce, fileList: [WrapData]) {
        
        guard !viewAlreadySet else {
            return
        }
        viewAlreadySet = true
        
        descriptionLabel.text = String(format: TextConstants.documentsAlbumCardDescriptionLabel, documentsAlbumResponse.size)
        uppendImages(fileList: fileList, numberOfItems: documentsAlbumResponse.size)
    }
    
    private func uppendImages(fileList: [WrapData], numberOfItems: Int) {
        
        fileList.forEach({ [weak self] item in
            let imageView: LoadingImageView = LoadingImageView()
            imageView.loadImage(with: item)
            self?.imagesStackView.addArrangedSubview(imageView)
        })
        
        let countView = UIView()
        countView.layer.borderWidth = 1
        countView.layer.borderColor = ColorConstants.blueColor.cgColor
        
        let label = UILabel()
        label.font = UIFont.TurkcellSaturaBolFont(size: 30)
        label.text = "+ \(numberOfItems - fileList.count)"
        label.textColor = ColorConstants.blueColor
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        countView.addSubview(label)
        label.centerXAnchor.constraint(equalTo: countView.centerXAnchor).activate()
        label.centerYAnchor.constraint(equalTo: countView.centerYAnchor).activate()
        label.trailingAnchor.constraint(equalTo: countView.trailingAnchor, constant: 0).activate()
        label.leadingAnchor.constraint(equalTo: countView.leadingAnchor, constant: 0).activate()
        
        imagesStackView.addArrangedSubview(countView)
    }
    
    private func openAlbum() {
        
        guard let uuid = albumItem?.uuid else {
            return
        }
        
        albumService.getAlbum(for: uuid) { [weak self] albumResponse in
            
            self?.viewDocumentButton.isEnabled = true
            
            switch albumResponse {
            case .success(let data):
                
                guard let thingsItem = self?.thingsItem else {
                    assertionFailure()
                    return
                }
                
                guard let controller = self?.router.imageFacePhotosController(album: AlbumItem(remote: data), item: thingsItem, status: .active, moduleOutput: nil) as? FaceImagePhotosViewController else {
                    assertionFailure()
                    return
                }
                
                controller.delegate = self
                
                self?.router.pushViewController(viewController: controller)
            case .failed(let error):
                UIApplication.showErrorAlert(message: error.localizedDescription)
            }
        }
    }
    
    @IBAction private func closeButtonTapped(_ sender: UIButton) {
        deleteCard()
    }
    
    @IBAction private func hideDocumentsButton(_ sender: UIButton) {
        guard let albumItem = albumItem else {
            assertionFailure()
            return
        }
        homeCardsService.delegate?.showSpinner()
        hideActionService.startOperation(for: .albums([albumItem]), output: self, success: { [weak self] in
            self?.homeCardsService.delegate?.needUpdateHomeScreen()
            self?.homeCardsService.delegate?.albumHiddenSuccessfully(true)
            }, fail: {[weak self ] _ in
                self?.homeCardsService.delegate?.albumHiddenSuccessfully(false)
                self?.homeCardsService.delegate?.hideSpinner()
        })
    }
    
    @IBAction private func viewDocumentsAlbum(_ sender: UIButton) {
        viewDocumentButton.isEnabled = false
        openAlbum()
    }
    
    @objc private func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
        viewDocumentButton.isEnabled = false
        openAlbum()
    }
}

extension DocumentsAlbumCard: FaceImagePhotosViewControllerDelegate {
    func viewWillDisappear() {
        homeCardsService.delegate?.needUpdateHomeScreen()
    }
}

extension DocumentsAlbumCard: BaseAsyncOperationInteractorOutput {
    func outputView() -> Waiting? { return nil }
    func startAsyncOperation() {}
    func startAsyncOperationDisableScreen() {}
    func startCancelableAsync(cancel: @escaping VoidHandler) {}
    func startCancelableAsync(with text: String, cancel: @escaping VoidHandler) {}
    func completeAsyncOperationEnableScreen(errorMessage: String?) {}
    func completeAsyncOperationEnableScreen() {}
    func asyncOperationSuccess() {}
    func asyncOperationFail(errorMessage: String?) {}
    
    func confirmationPopUpCancelTapped() {
        homeCardsService.delegate?.hideSpinner()
    }
}
