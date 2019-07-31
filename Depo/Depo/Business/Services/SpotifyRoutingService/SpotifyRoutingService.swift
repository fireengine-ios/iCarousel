//
//  SpotifyRoutingService.swift
//  Depo
//
//  Created by Maxim Soldatov on 7/26/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import Foundation

final class SpotifyRoutingService {
    
    private lazy var spotifyService = SpotifyServiceImpl()
    private func checkSpotifySocialStatus(completion: @escaping (Bool) -> Void){
        
        spotifyService.socialStatus(success: { [weak self] response in
            
            guard let response = response as? SocialStatusResponse,
                  let isConnected: Bool = response.spotifyConnected else {
                    let error = CustomErrors.serverError("An error occurred while getting Spotify status.")
                    let errorResponse = ErrorResponse.error(error)
                    self?.showError(with: errorResponse)
                    return
            }
            completion(isConnected)
        }) { [weak self] error in
            self?.showError(with: error)
        }
    }
    
    func connectToSpotify(completion: @escaping (URL?, [SpotifyPlaylist]?) -> Void) {
        checkSpotifySocialStatus { isConnected in
            if isConnected {
                self.preparePlayListsController(completion: { playLists in
                    completion(nil, playLists)
                })
            } else {
                self.prepareAuthWebPage(completion: { url in
                    completion(url, nil)
                })
            }
        }
    }
    
    func terminationAuthProcess(code: String, completion: @escaping ([SpotifyPlaylist]?) -> Void ) {
        spotifyService.connect(code: code) { response in
            switch response {
                
            case .success:
                self.preparePlayListsController(completion: { playLists in
                    completion(playLists)
                })
            case .failed(_):
                let err = CustomErrors.serverError("An error occurred while getting PlayLists ")
                let errorResponse = ErrorResponse.error(err)
                self.showError(with: errorResponse)
            }
        }
        
    }
    
    private func prepareAuthWebPage(completion: @escaping (URL) -> Void) {
        spotifyService.getAuthUrl { (response) in
            switch response {
            case .success(let response):
                completion(response)
            case .failed(_):
                let error = CustomErrors.serverError("An error occurred while opening Spotify login page.")
                let errorResponse = ErrorResponse.error(error)
                self.showError(with: errorResponse)
            }
        }
    }
    
    private func preparePlayListsController(completion: @escaping ([SpotifyPlaylist]) -> Void) {
        spotifyService.getPlaylists(page: 0, size: 5) {  response in
            switch response {
            case .success(let response):
                completion(response)
            case .failed(_):
                let err = CustomErrors.serverError("An error occurred while getting PlayLists ")
                let errorResponse = ErrorResponse.error(err)
                self.showError(with: errorResponse)
            }
        }
    }
    
    private func showError(with error: ErrorResponse) {
        //TODO: Temporary logic for ErrorHandling
        UIApplication.showErrorAlert(message: error.localizedDescription)
    }
}
