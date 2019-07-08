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
    private var selectedIndexForMusic: Int = 0
    private var selectedIndexForUploads: Int = 0
    private let musicSegmentedControlIndex = 1
    
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
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    
    
    init(forStory story: PhotoStory) {
        photoStory = story
        super.init(nibName: nil, bundle: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive), name: .UIApplicationWillResignActive, object: nil)
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
        showSpinner()
        getMusics()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavBarActions()
    }
    
    @IBAction private func segmentedControlChanged(_ sender: UISegmentedControl) {
        unselectPlayingCell()
        onChangeSource(isYourUpload: sender.selectedSegmentIndex == musicSegmentedControlIndex)
    }
    
    private func configureNavBarActions() {
        navigationBarWithGradientStyle()
        setTitle(withString: TextConstants.createStoryAudioSelected)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: TextConstants.createStorySelectAudioButton,
                                                            target: self,
                                                            selector: #selector(onNextButton))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: TextConstants.selectFolderCancelButton,
                                                           target: self,
                                                           selector: #selector(onCancelButton))
    }
    
    private func onChangeSource(isYourUpload: Bool) {
        itemsArray.removeAll()
        showSpinner()
        if isYourUpload {
            getUploads()
        } else {
            getMusics()
        }
    }
    
    @objc private func onNextButton() {
        setMusicItemForPhotoStory()
        smallPlayer.stop()
        hideViewController()
    }
    
    private func setMusicItemForPhotoStory() {
        guard let item = selectedItem, let story = photoStory else {
            return
        }
        story.music = item
        self.audioItemSelectedDelegate?.photoStoryWithSelectedAudioItem(story: story)
    }
    
    @objc private func onCancelButton() {
        smallPlayer.stop()
        hideViewController()
    }
    
    private func hideViewController() {
        navigationController?.popViewController(animated: true)
    }
}

extension CreateStoryAudioSelectionItemViewController {
    
    private func getMusics() {
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
        if segmentedControl.selectedSegmentIndex == musicSegmentedControlIndex {
            return selectedIndexForMusic == index
        } else {
            return selectedIndexForUploads == index
        }
    }
    
    private func isPlaying(index: Int) -> Bool {
        return plaingCellRowIndex == index
    }
    
    private func setSelectedItem() {
        
        if segmentedControl.selectedSegmentIndex == musicSegmentedControlIndex {
            if itemsArray.count >= selectedIndexForMusic {
                selectedItem = itemsArray[musicSegmentedControlIndex]
            }
        } else {
            if itemsArray.count >= selectedIndexForUploads {
                selectedItem = itemsArray[selectedIndexForUploads]
            }
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
        if segmentedControl.selectedSegmentIndex == musicSegmentedControlIndex {
            selectedIndexForMusic = index
        } else {
            selectedIndexForUploads = index
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
