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
    
    private lazy var smallPlayer: MediaPlayer = MediaPlayer()
    private var plaingCell: Int?

    var audioItemSelectedDelegate: AudioItemSelectedDelegate?
    
    private var itemsArray: [WrapData] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    @IBOutlet private var designer: CreateStoryAudioSelectionItemDesigner!
    @IBOutlet private weak var tableView: UITableView!
    
    init(forStory story: PhotoStory) {
        photoStory = story
        super.init(nibName: nil, bundle: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive), name: .UIApplicationWillResignActive, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
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
        onChangeSource(isYourUpload: sender.selectedSegmentIndex == 1)
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
        setMusicItemForPhotoStory { [weak self] story in
            self?.audioItemSelectedDelegate?.photoStoryWithSelectedAudioItem(story: story)
        }
        smallPlayer.stop()
        hideViewController()
    }
    
    private func setMusicItemForPhotoStory(completion: ((PhotoStory)-> Void)? = nil) {
        guard let item = selectedItem, let story = photoStory else {
            return
        }
        story.music = item
        completion?(story)
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
            assertionFailure("Failure with get getMusic request ")
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
                assertionFailure("Failure with getUpload music request")
                self.hideSpinner()
        })
    }
    
    private func showEmtyView<T>(array: [T]) {
        if array.isEmpty {
            DispatchQueue.main.async {
                self.designer.emtyListView.isHidden = false
            }
        } else {
            DispatchQueue.main.async {
                self.designer.emtyListView.isHidden = true
            }
        }
    }
}

extension CreateStoryAudioSelectionItemViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
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
        cell.isSelectedItem(selected: setSelected(index: indexPath.row))
        
        let item = itemsArray[indexPath.row].name
        
        if let name = item {
            cell.setTextForLabel(titleText: name, needShowSeparator: indexPath.row == itemsArray.count - 1)
        }
        cell.isPlaying(playing: setPlaing(index: indexPath.row))
        
        return cell
    }
    
    
    private func setSelected(index: Int) -> Bool {
        
        if designer.segmentedControl.selectedSegmentIndex == 1 {
            if selectedIndexForMusic == index {
                return true
            }
            return false
        } else {
            if selectedIndexForUploads == index {
                return true
            }
            return false
        }
    }
    
    private func setPlaing(index: Int) -> Bool {
        if plaingCell == index {
            return true
        }
        return false
    }
    
    private func setSelectedItem() {
        let index = designer.segmentedControl.selectedSegmentIndex == 1 ? selectedIndexForMusic : selectedIndexForUploads
        if itemsArray.count >= index {
            selectedItem = itemsArray[index]
        }
    }
    
}

extension CreateStoryAudioSelectionItemViewController: CreateStoryAudioItemCellDelegate {
    
    func playButtonPressed(cell index: Int) {
        if plaingCell == index {
            unselectPlayingCell {
                self.tableView.reloadData()
            }
        } else {
            unselectPlayingCell {
                self.plaingCell = index
                self.tableView.reloadData()
                self.playItem(playItem: index)
            }
        }
    }
    
    func selectButtonPressed(cell index: Int) {
        if designer.segmentedControl.selectedSegmentIndex == 1 {
            selectedIndexForMusic = index
        } else {
            selectedIndexForUploads = index
        }
        
        tableView.reloadData()
        if itemsArray.count >= index {
            selectedItem = itemsArray[index]
        }
    }
    
    private func unselectPlayingCell(completion: (() -> Void)? = nil) {
        smallPlayer.stop()
        plaingCell = nil
        completion?()
    }
}

extension CreateStoryAudioSelectionItemViewController {
    
    private func playItem(playItem index: Int) {
        guard !itemsArray.isEmpty else {
            return
        }
        smallPlayer.play(list: [itemsArray[index]], startAt: 0)
    }
    
}
