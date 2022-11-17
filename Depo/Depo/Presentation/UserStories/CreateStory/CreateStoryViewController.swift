//
//  CreateStoryViewController.swift
//  Depo
//
//  Created by Tsimafei Harhun on 6/27/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class CreateStoryViewController: BaseViewController {

    //MARK: IBOutlet
    @IBOutlet private weak var storyNameView: SnackBarHeaderTwoLineView! {
        willSet {
            newValue.titleLabel.text = TextConstants.createStoryNameTitle
            newValue.textField.returnKeyType = .done
            newValue.textField.delegate = self
        }
    }
    
    @IBOutlet private weak var musicSelectView: SnackBarHeaderTwoLineView! {
        willSet {
            newValue.titleLabel.text = TextConstants.music
            newValue.textField.isUserInteractionEnabled = false
            newValue.arrowImageView.isHidden = false
        }
    }
    
    @IBOutlet private weak var descriptionLabel: UILabel! {
        willSet {
            let text = String(format: TextConstants.createStoryPressAndHoldDescription, TextConstants.createStoryPressAndHold)
            let attributes: [NSAttributedString.Key : Any] = [
                .font : UIFont.appFont(.medium, size: 12),
                .foregroundColor : AppColor.label.color
            ]
            
            let attributedString = NSMutableAttributedString(string: text, attributes:  attributes)
            
            if let range = text.range(of: TextConstants.createStoryPressAndHold) {
                let rangeAttributes: [NSAttributedString.Key : Any] = [
                    .font : UIFont.appFont(.bold, size: 12),
                    .foregroundColor : AppColor.label.color
                ]
                
                let location = range.lowerBound.utf16Offset(in: TextConstants.createStoryPressAndHold)
                let len = range.upperBound.utf16Offset(in: TextConstants.createStoryPressAndHold) - location
                let nsRange = NSRange(location: location,
                                      length: len)
                attributedString.addAttributes(rangeAttributes, range: nsRange)
            }
            
            newValue.attributedText = attributedString
        }
    }
    
    @IBOutlet private weak var collectionView: UICollectionView! {
        willSet {
            newValue.delegate = self
            newValue.dataSource = self
            newValue.collectionViewLayout = UICollectionViewFlowLayout()
            
            newValue.register(PhotoCell.self, forCellWithReuseIdentifier: cellId)

            let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handlePhotoMove))
            newValue.addGestureRecognizer(gesture)
        }
    }
    
    @IBOutlet private weak var createButton: DarkBlueButton! {
        willSet {
            newValue.setTitle(TextConstants.createStoryPhotosOrderNextButton, for: .normal)
            newValue.titleLabel?.font = ApplicationPalette.mediumRoundButtonFont
            
            newValue.layer.shadowOffset = .zero
            newValue.layer.shadowOpacity = 0.5
            newValue.layer.shadowRadius = 4
            newValue.layer.shadowColor = ColorConstants.backgroundViewColor.cgColor
        }
    }
    
    //MARK: Vars
    private let cellId = String(describing: PhotoCell.self)

    private var story: PhotoStory?
    
    private var selectedImages: [Item]
    
    private lazy var createStoryService = CreateStoryService()
    private lazy var activityManager = ActivityIndicatorManager()
    private let dataSource = CreateStoryMusicService()


    //MARK: Lifecycle
    init(forStory story: PhotoStory) {
        self.story = story
        self.selectedImages = story.storyPhotos
        super.init(nibName: String(describing: CreateStoryViewController.self), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        selectedImages = []
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavigation()

        updateStoryIfNeeded(story?.music)
        
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.CreateStoryNameScreen())
        let analyticsService = AnalyticsService()
        analyticsService.logScreen(screen: .createStoryDetails)
        
        navigationController?.navigationBar.items?.forEach({ $0.title = "" })
        navigationController?.navigationBar.tintColor = AppColor.label.color
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateItemSize()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    //MARK: Utility Methods
    private func setup() {
        configureStory()
        
        activityManager.delegate = self
        
        musicSelectView.action = { [weak self] in
            self?.presentAudioController()
        }
    }
    
    private func setupNavigation() {
        
        setTitle(withString: TextConstants.createStory)
    }
    
    private func configureStory() {
        let currentDate = Date()
        let calendar = Calendar.current
        
        let year = calendar.component(.year, from: currentDate)
        let month = calendar.component(.month, from: currentDate)
        let day = calendar.component(.day, from: currentDate)

        let hour = calendar.component(.hour, from: currentDate)
        let minutes = calendar.component(.minute, from: currentDate)
        
        let defaultNameCarcass = "%d%02d%02d_%02d%02d"
        let name = String(format: defaultNameCarcass,
                          year,
                          month,
                          day,
                          hour,
                          minutes)
        
        storyNameView.textField.text = name
        
        story?.storyPhotos = selectedImages
        musicSelectView.textField.text = story?.music?.name ?? ""
        
        startActivityIndicator()
        dataSource.allItems(success: { [weak self] songs in
            self?.stopActivityIndicator()
            
            // it may applied according to flow
            //self?.updateStoryIfNeeded(songs.first)

        }, fail: { [weak self] in
            self?.stopActivityIndicator()
            let error = CustomErrors.text("An error has occured while getting music for story.")
            self?.showError(text: error.localizedDescription)
        })
    }
    
    private func updateStoryIfNeeded(_ song: Item?) {
        guard let music = song else {
            return
        }
        
        story?.storyName = storyNameView.textField.text ?? ""
        story?.music = music
        musicSelectView.textField.text = music.name ?? ""
    }
        
    private func updateItemSize() {
        let viewWidth = collectionView.bounds.width
        let columns: CGFloat = Device.isIpad ? 8 : 4
        let padding: CGFloat = 1
        let itemWidth = floor((viewWidth - (columns - 1) * padding) / columns)
        let itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = itemSize
            layout.minimumInteritemSpacing = padding
            layout.minimumLineSpacing = padding
        }
    }
    
    //MARK: Actions
    @objc func handlePhotoMove(_ gesture: UILongPressGestureRecognizer) {
        switch(gesture.state) {
            
        case .began:
            guard let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else {
                break
            }
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
            
        case .changed:
            let position = gesture.location(in: gesture.view)
            
            if collectionView.bounds.contains(position) {
                collectionView.updateInteractiveMovementTargetPosition(position)
            } else {
                collectionView.cancelInteractiveMovement()
            }
            
        case .ended:
            collectionView.endInteractiveMovement()
            
        case .possible, .cancelled, .failed:
            collectionView.cancelInteractiveMovement()
        @unknown default:
            break
        }
    }
    
    @IBAction func onCreateTap(_ sender: Any) {
        createStory()
    }
}

//MARK: - Requests + ActivityIndicator
extension CreateStoryViewController: ActivityIndicator {
    
    func startActivityIndicator() {
        activityManager.start()
    }
    
    func stopActivityIndicator() {
        activityManager.stop()
    }
    
    private func createStory() {
        
        updateStoryIfNeeded(story?.music)
        
        if let parameter = story?.photoStoryRequestParameter() {
            let storyPreview = CreateStoryPreview(name: parameter.title,
                                                  imageuuid: parameter.imageUUids,
                                                  musicUUID: parameter.audioUuid,
                                                  musicId: parameter.musicId)
            
            startActivityIndicator()
            createStoryService.getPreview(preview: storyPreview, success: { [weak self] response in
                guard let `self` = self else {
                    return
                }
                
                self.stopActivityIndicator()
                
                DispatchQueue.main.async {
                    self.openPreview(response: response)
                }
                
                }, fail: { error in
                    DispatchQueue.main.async { [weak self] in
                        guard let `self` = self else {
                            return
                        }
                        
                        let errorText: String?
                        
                        if error.description == "VIDEO_SLIDESHOW_NAME_MISSING" {
                            errorText = TextConstants.createStoryEmptyNameError
                        } else {
                            errorText = error.errorDescription
                        }
                        
                        self.stopActivityIndicator()
                        self.showError(text: errorText)
                    }
            })
        }
    }
    
    private func showError(text: String?) {
        let errorAlert = PopUpController.with(title: TextConstants.errorAlert, message: text, image: .none, buttonTitle: TextConstants.ok)
        errorAlert.open()
    }
}

//MARK: - Routing
extension CreateStoryViewController {

    @objc private func presentAudioController() {
        guard let story = story else {
            let error = CustomErrors.text("An error has occured while composing story data.")
            showError(text: error.localizedDescription)
            return
        }
        
        let router = RouterVC()
        let controller = router.audioSelection(forStory: story)
        controller.audioItemSelectedDelegate = self
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func openPreview(response: CreateStoryResponse) {
        guard let story = story else {
            let error = CustomErrors.text("An error has occured while composing story data.")
            showError(text: error.localizedDescription)
            return
        }
        
        let router = RouterVC()
        let controller = router.storyPreview(forStory: story, response: response)
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

//MARK: - UICollectionViewDelegate
extension CreateStoryViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let element = selectedImages.remove(at: sourceIndexPath.row)
        selectedImages.insert(element, at: destinationIndexPath.row)
        story?.storyPhotos = selectedImages
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let item = selectedImages[indexPath.row]
        (cell as? PhotoCell)?.setup(by: item)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? PhotoCell)?.cancelImageLoading()
    }
}

//MARK: - UICollectionViewDataSource
extension CreateStoryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
    }
}

//MARK: - UITextFieldDelegate
extension CreateStoryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension CreateStoryViewController: AudioItemSelectedDelegate {
    func photoStoryWithSelectedAudioItem(story: PhotoStory) {
        self.story?.music = story.music
    }
}
