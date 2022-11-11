//
//  CreateStoryAudioSelectionItemViewController.swift
//  Depo_LifeTech
//
//  Created by Maxim Soldatov on 7/1/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

protocol AudioItemSelectedDelegate {
    func photoStoryWithSelectedAudioItem(story: PhotoStory)
}

final class CreateStoryAudioSelectionItemViewController: ViewController, NibInit {
    
    private var photoStory: PhotoStory?
    private var selectedItem: WrapData?
    private var musicSegmentedControlIndex = true
    
    private var selectedIndexForMusic: Int?
    private var selectedIndexForUploads: Int?
    
    private lazy var smallPlayer = MediaPlayer()
    private var plaingCellRowIndex: Int?
    
    var audioItemSelectedDelegate: AudioItemSelectedDelegate?
    
    private var itemsArray: [WrapData] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    @IBOutlet private var designer: CreateStoryAudioSelectionItemDesigner!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var emtyListView: UIView!
    
    @IBOutlet weak var firstSegmentButton: InsetsButton! {
        willSet {
            newValue.setTitle(TextConstants.createStoryAudioMusics, for: .normal)
            newValue.layer.cornerRadius = 12
            newValue.titleLabel?.font = .appFont(.medium, size: 16)
            newValue.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var secondSegmentButton: InsetsButton! {
        willSet {
            newValue.setTitle(TextConstants.createStoryAudioYourUploads, for: .normal)
            newValue.layer.cornerRadius = 12
            newValue.titleLabel?.font = .appFont(.medium, size: 16)
            newValue.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var firstSegmentShadowView: UIView!{
        willSet {
            newValue.addRoundedShadows(cornerRadius: 12, shadowColor: AppColor.drawerShadow.cgColor, opacity: 0.3, radius: 4)
        }
    }
    
    
    @IBOutlet weak var secondSegmentShadowView: UIView! {
        willSet {
            newValue.addRoundedShadows(cornerRadius: 12, shadowColor: AppColor.drawerShadow.cgColor, opacity: 0.3, radius: 4)
        }
    }
    
    var fromPhotoSelection: Bool = false
    
    init(forStory story: PhotoStory) {
        photoStory = story
        super.init(nibName: nil, bundle: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        assertionFailure()
        super.init(coder: aDecoder)
    }
    
    @objc private func applicationWillResignActive(_ notification: NSNotification) {
        smallPlayer.stop()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedIndexForMusic = 0
        showSpinner()
        getMusic()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavBarActions()
        
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.CreateStoryMusicSelectionScreen())
        let analyticsService = AnalyticsService()
        analyticsService.logScreen(screen: .createStoryMusicSelection)
        renderSegmentButtons()
    }
    
    override func viewDidLayoutSubviews() {
        renderSegmentButtons()
    }
    
    @IBAction func firstSegmentButtonAction(_ sender: Any) {
        
        guard !musicSegmentedControlIndex else { return }
        
        unselectPlayingCell()
        onChangeSource(isYourMusic: true)
        musicSegmentedControlIndex = true
        renderSegmentButtons()
    }
    
    @IBAction func SecondSegmentButtonAction(_ sender: Any) {
        
        guard musicSegmentedControlIndex else { return }
        
        unselectPlayingCell()
        onChangeSource(isYourMusic: false)
        musicSegmentedControlIndex = false
        renderSegmentButtons()
    }
    
    private func renderSegmentButtons() {
        if musicSegmentedControlIndex {
            firstSegmentButton.setBackgroundColor(AppColor.tint.color, for: .normal)
            firstSegmentButton.setTitleColor(.white, for: .normal)
            secondSegmentButton.setBackgroundColor(AppColor.tertiaryBackground.color, for: .normal)
            secondSegmentButton.setTitleColor(AppColor.label.color, for: .normal)
        } else {
            secondSegmentButton.setBackgroundColor(AppColor.tint.color, for: .normal)
            secondSegmentButton.setTitleColor(.white, for: .normal)
            firstSegmentButton.setBackgroundColor(AppColor.tertiaryBackground.color, for: .normal)
            firstSegmentButton.setTitleColor(AppColor.label.color, for: .normal)
        }
    }
    
    private func configureNavBarActions() {
        setTitle(withString: TextConstants.createStoryAudioSelected)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: TextConstants.actionAdd,
                                                            target: self,
                                                            selector: #selector(onAddButton))
        
        navigationController?.navigationBar.tintColor = AppColor.label.color
    }
    
    private func onChangeSource(isYourMusic: Bool) {
        itemsArray.removeAll()
        showSpinner()
        if isYourMusic {
            getMusic()
        } else {
            getUploads()
        }
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if parent == nil {
            smallPlayer.stop()
            hideViewController()
        }
    }
    
    @objc private func onAddButton() {
        setMusicItemForPhotoStory()
        smallPlayer.stop()
        
        if fromPhotoSelection {
            
            guard let item = selectedItem, let story = photoStory else {
                return
            }
            story.music = item
            
            let controller = CreateStoryViewController(forStory: story)
            navigationController?.pushViewController(controller, animated: true)
        } else {
            hideViewController()
        }
    }
    
    private func setMusicItemForPhotoStory() {
        guard let item = selectedItem, let story = photoStory else {
            return
        }
        story.music = item
        self.audioItemSelectedDelegate?.photoStoryWithSelectedAudioItem(story: story)
    }
    
    private func hideViewController() {
        navigationController?.popViewController(animated: true)
    }
}

extension CreateStoryAudioSelectionItemViewController {
    
    private func getMusic() {
        CreateStoryMusicService().allItems(success: { [weak self] items in
            self?.showEmtyView(array: items)
            self?.itemsArray = items
            self?.setSelectedItem()
            self?.hideSpinner()
        }) {
            self.hideSpinner()
        }
    }
    
    private func getUploads() {
        let remoteService  =  RemoteItemsService(requestSize: 100, fieldValue: .audio)
        remoteService.nextItems(sortBy: .date,
                                sortOrder: .asc,
                                success: { [weak self] items in
                                    self?.showEmtyView(array: items)
                                    DispatchQueue.main.async {
                                        self?.itemsArray = items
                                        self?.setSelectedItem()
                                        self?.hideSpinner()
                                    }
            }, fail: {
                self.hideSpinner()
        })
    }
    
    private func showEmtyView<T>(array: [T]) {
        if array.isEmpty {
            DispatchQueue.main.async {
                self.emtyListView.isHidden = false
            }
        } else {
            DispatchQueue.main.async {
                self.emtyListView.isHidden = true
            }
        }
    }
}

extension CreateStoryAudioSelectionItemViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
}

extension CreateStoryAudioSelectionItemViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let settingCell = tableView.dequeueReusableCell(withIdentifier: CellsIdConstants.createStoryAudioItemCell, for: indexPath)
        
        guard let cell = settingCell as? CreateStoryAudioItemCell else {
            assertionFailure("Unexpected cell type")
            return UITableViewCell()
        }
        cell.setCellIndexPath(index: indexPath.row)
        cell.createStoryAudioItemCellDelegate = self
        cell.selectionStyle = .none
        cell.setSelected(selected: isSelected(index: indexPath.row))
        cell.setPlaying(playing: isPlaying(index: indexPath.row))
        
        if let name = itemsArray[indexPath.row].name {
            cell.setTextForLabel(titleText: name)
        }
        
        return cell
    }
    
    private func isSelected(index: Int) -> Bool {
        if musicSegmentedControlIndex {
            return selectedIndexForMusic == index
        } else {
            return selectedIndexForUploads == index
        }
    }
    
    private func isPlaying(index: Int) -> Bool {
        return plaingCellRowIndex == index
    }
    
    private func setSelectedItem() {
        guard !itemsArray.isEmpty else {
            return
        }
        
        if musicSegmentedControlIndex {
            setItem(index: selectedIndexForMusic)
        } else {
            setItem(index: selectedIndexForUploads)
        }
    }
    
    private func setItem(index: Int?) {
       
        guard let index = index else {
            return
        }
        
        if itemsArray.count >= index {
            selectedItem = itemsArray[index]
            tableView.reloadData()
        }
    }
}

extension CreateStoryAudioSelectionItemViewController: CreateStoryAudioItemCellDelegate {
    
    func playButtonPressed(cell index: Int) {
        
        if plaingCellRowIndex == index {
            unselectPlayingCell()
            self.tableView.reloadData()
        } else {
            unselectPlayingCell()
            self.plaingCellRowIndex = index
            self.tableView.reloadData()
            self.playItem(at: index)
        }
    }
    
    func selectButtonPressed(cell index: Int) {
        if musicSegmentedControlIndex {
            selectedIndexForMusic = index
            selectedIndexForUploads = nil
        } else {
            selectedIndexForUploads = index
            selectedIndexForMusic = nil
        }
        
        tableView.reloadData()
        if itemsArray.count >= index {
            selectedItem = itemsArray[index]
            
        }
    }
    
    private func unselectPlayingCell() {
        smallPlayer.stop()
        plaingCellRowIndex = nil
    }
}

extension CreateStoryAudioSelectionItemViewController {
    
    private func playItem(at index: Int) {
        guard !itemsArray.isEmpty else {
            assertionFailure()
            return
        }
        smallPlayer.play(list: [itemsArray[index]], startAt: 0)
    }
    
}
