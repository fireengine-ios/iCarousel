//
//  AppSession.h
//  Depo
//
//  Created by Mahir on 9/18/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "AppConstants.h"
#import <AVFoundation/AVFoundation.h>
#import "NSMutableArray_Shuffling.h"
#import "MetaFile.h"
#import "Usage.h"
#import "ContactSyncResult.h"
#import <MediaPlayer/MediaPlayer.h>

@interface AppSession : NSObject

@property (nonatomic, strong) User *user;
@property (nonatomic, strong) NSString *authToken;
@property (nonatomic, strong) NSString *baseUrl;
@property (nonatomic, strong) NSString *baseUrlConstant;
@property (nonatomic) SortType sortType;

@property (nonatomic, strong) NSArray *playerItemFilesRef;
@property (nonatomic, strong) NSMutableArray *playerItems;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayer *audioPlayer;
@property (nonatomic) int currentAudioItemIndex;

@property (nonatomic) BOOL newUserFlag;
@property (nonatomic) BOOL migrationUserFlag;

@property (nonatomic, strong) Usage *usage;
@property (nonatomic, strong) ContactSyncResult *syncResult;
@property (nonatomic, strong) UIImage *profileImageRef;

@property (nonatomic, strong) NSString *mobileUploadsFolderName;

@property (nonatomic) ContactSyncType syncType;

@property (assign) BOOL shuffleFlag;

@property (nonatomic, strong) NSMutableArray *bgOngoingTasksOriginalUrls;

@property (nonatomic) BOOL quotaExceed80EventFlag;

@property (nonatomic, strong) NSString *otpReferenceToken;
@property (nonatomic, strong) NSString *signupReferenceMsisdn;
@property (nonatomic, strong) NSString *signupReferenceEmail;
@property (nonatomic, strong) NSString *signupReferencePassword;

@property (nonatomic) BOOL emailEmptyMessageShown;
@property (nonatomic) BOOL emailNotVerifiedMessageShown;

@property (nonatomic) BOOL emailEmpty;
@property (nonatomic) BOOL msisdnEmpty;
@property (nonatomic) BOOL emailNotVerified;

@property (nonatomic) BOOL storageFullPopupShown;

- (void) playAudioItemAtIndex:(int) itemIndex;
- (void) playNextAudioItem;
- (void) playPreviousAudioItem;
- (void) playNextShuffledAudioItem;
- (void) playPreviousShuffleAudioItem;
- (void) playAudioItem;
- (void) pauseAudioItem;
- (void) stopAudioItem;
- (void) shuffleItems;
- (MetaFile *) itemRefForCurrentAsset;
- (void) checkLatestContactSyncStatus;
- (BOOL) isPrevNextAvailable;
- (void) cleanoutAfterLogout;

- (void) addBgOngoingTaskUrl:(NSString *) taskUrl;
- (void) cleanBgOngoingTaskUrls;
- (BOOL) isUrlPresentInBgOngoingTaskUrls:(NSString *) taskUrl;

- (void) modifyPlayerItemFavUnfavFlag:(BOOL) favUnfav forUuid:(NSString *) uuid;

- (void) initNowPlayingInfoCenter:(MetaFile *) songInfo;
- (BOOL) isAudioPlaying;

- (void) musicFileWasDeletedWithUuids:(NSArray *) uuidVals;

@end
