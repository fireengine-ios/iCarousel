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
    @IBOutlet private weak var storyNameView: ProfileTextEnterView! {
        willSet {
            newValue.titleLabel.text = TextConstants.createStoryNameTitle
            newValue.titleLabel.textColor = ColorConstants.grayTabBarButtonsColor
            newValue.titleLabel.font = UIFont.TurkcellSaturaBolFont(size: 14)
            
            newValue.textField.textColor = ColorConstants.textGrayColor
            newValue.textField.font = UIFont.TurkcellSaturaBolFont(size: 21)
            
            newValue.textField.returnKeyType = .done
            newValue.textField.delegate = self
        }
    }
    
    @IBOutlet private weak var musicSelectView: CreateStoryMusicEnterView! {
        willSet {
            newValue.titleLabel.text = TextConstants.music
            newValue.titleLabel.textColor = ColorConstants.grayTabBarButtonsColor
            newValue.titleLabel.font = UIFont.TurkcellSaturaBolFont(size: 14)
            
            newValue.textField.textColor = ColorConstants.textGrayColor
            newValue.textField.font = UIFont.TurkcellSaturaBolFont(size: 21)
            
            newValue.textField.isUserInteractionEnabled = false
        }
    }
    
    @IBOutlet private weak var descriptionLabel: UILabel! {
        willSet {
            let text = String(format: TextConstants.createStoryPressAndHoldDescription, TextConstants.createStoryPressAndHold)
            let attributes: [NSAttributedStringKey : Any] = [
                .font : UIFont.TurkcellSaturaMedFont(size: 18),
                .foregroundColor : ColorConstants.blueGrey
            ]
            
            let attributedString = NSMutableAttributedString(string: text, attributes:  attributes)
            
            if let range = text.range(of: TextConstants.createStoryPressAndHold) {
                let rangeAttributes: [NSAttributedStringKey : Any] = [
                    .font : UIFont.TurkcellSaturaBolFont(size: 18),
                    .foregroundColor : ColorConstants.darkBlueColor
                ]
                let nsRange = NSRange(location: range.lowerBound.encodedOffset,
                                      length: range.upperBound.encodedOffset - range.lowerBound.encodedOffset)
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
    
    @IBOutlet private weak var createButton: RoundedInsetsButton! {
        willSet {
            newValue.setTitle(TextConstants.createStoryPhotosOrderNextButton, for: .normal)
            newValue.setTitleColor(.white, for: .normal)
            newValue.setBackgroundColor(ColorConstants.darkBlueColor, for: .normal)
            newValue.titleLabel?.font = ApplicationPalette.mediumRoundButtonFont
            
            newValue.layer.shadowOffset = .zero
            newValue.layer.shadowOpacity = 0.5
            newValue.layer.shadowRadius = 4
            newValue.layer.shadowColor = UIColor.black.withAlphaComponent(0.5).cgColor
        }
    }
    
    //MARK: Vars
    private let cellId = String(describing: PhotoCell.self)

    private var story: PhotoStory?
    
    private var selectedImages: [Item]
    private var musicUUID: String?
    private var musicID: Int64?
    
    private lazy var createStoryService = CreateStoryService(transIdLogging: true)
    private lazy var activityManager = ActivityIndicatorManager()
    private let dataSource = CreateStoryMusicService()


    //MARK: Lifecycle
    init(images: [Item]) {
        selectedImages = images
        
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

        updateMusicIfNeeded(story?.music)
        
        let analyticsService = AnalyticsService()
        analyticsService.logScreen(screen: .createStoryDetails)
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
        navigationBarWithGradientStyle()
        
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
        
        let defaultNameCarcass = "%d%d%d_%d%d"
        let name = String(format: defaultNameCarcass,
                          year,
                          month,
                          day,
                          hour,
                          minutes)
        
        storyNameView.textField.text = name
        
        story = PhotoStory(name: name)
        story?.storyPhotos = selectedImages
        
        startActivityIndicator()
        dataSource.allItems(success: { [weak self] songs in
            self?.stopActivityIndicator()
            self?.updateMusicIfNeeded(songs.first)

        }, fail: { [weak self] in
            self?.stopActivityIndicator()
            let error = CustomErrors.text("An error has occured while getting music for story.")
            self?.showError(text: error.localizedDescription)
        })
    }
    
    private func updateMusicIfNeeded(_ song: Item?) {
        guard let music = song else {
            return
        }
        
        story?.music = music
        musicSelectView.textField.text = music.name ?? ""
        musicUUID = music.uuid
        musicID = music.id
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
        let storyPreview = CreateStoryPreview(name: storyNameView.textField.text ?? "",
                                              imageuuid: selectedImages.compactMap { $0.uuid },
                                              musicUUID: musicUUID,
                                              musicId: musicID)
        
        startActivityIndicator()
        createStoryService.getPreview(preview: storyPreview, success: { [weak self] responce in
            guard let `self` = self else {
                return
            }
            
            self.stopActivityIndicator()

            DispatchQueue.main.async {
                self.openPreview(responce: responce)
            }
            
        }, fail: { error in
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else {
                    return
                }
                
                self.stopActivityIndicator()
                self.showError(text: error.errorDescription)
            }
        })
    }
    
    private func showError(text: String?) {
        let errorAlert = DarkPopUpController.with(title: TextConstants.errorAlert, message: text, buttonTitle: TextConstants.ok)
        present(errorAlert, animated: true, completion: nil)
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
    
    private func openPreview(responce: CreateStoryResponce) {
        guard let story = story else {
            let error = CustomErrors.text("An error has occured while composing story data.")
            showError(text: error.localizedDescription)
            return
        }
        
        let router = RouterVC()
        let controller = router.storyPreview(forStory: story, responce: responce)
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

//MARK: - UICollectionViewDelegate
extension CreateStoryViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        selectedImages.swapAt(sourceIndexPath.row, destinationIndexPath.row)
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
        self.story = story
    }
}
