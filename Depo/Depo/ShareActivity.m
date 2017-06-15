//
//  ShareActivity.m
//  ShareTest
//
//  Created by Ömer Burak Kır on 20/03/2017.
//  Copyright © 2017 Ömer Burak Kır. All rights reserved.
//

#import "ShareActivity.h"
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

@interface ShareActivity ()
//@property (nonatomic, strong) NSMutableArray *videoAlAssetURLS;
@end

@implementation ShareActivity

# pragma mark - properties and methods we must override

- (NSString *)activityType {
    return @"com.rdc.lifebox.custom-share-activity";
}

- (NSString *)activityTitle {
    return @"Facebook";
}

- (UIImage *)activityImage {
    return [UIImage imageNamed:@"facebook"];
}

+ (UIActivityCategory)activityCategory {
    return UIActivityCategoryShare;
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    for (id item in activityItems) {
        if ([item isKindOfClass:[UIImage class]]) {
            return YES;
        }
        if ([item isKindOfClass:[NSURL class]]) {
            return YES;
        }
    }
    return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    self.activityItems = activityItems;
}

- (UIViewController *)activityViewController {
    return nil;
}

- (void)performActivity {
        
    NSMutableArray *itemsToShare = [@[] mutableCopy];
    
    BOOL notLocalImageFileURL = NO;
    BOOL containsVideo = NO;
    
    for (id sharedItem in self.activityItems) {
        if ([sharedItem isKindOfClass:[UIImage class]]) {
            UIImage *image = (UIImage *)sharedItem;
            FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
            photo.image = image;
            photo.userGenerated = YES;
            [itemsToShare addObject:photo];
        } else if ([sharedItem isKindOfClass:[NSURL class]]) {
            NSURL *url = (NSURL *)sharedItem;
            if ([url.absoluteString rangeOfString:@"mylifebox.com"].location != NSNotFound) {
                notLocalImageFileURL = YES;
                break;
            }
            UIImage *image = [UIImage imageWithData:
                              [NSData dataWithContentsOfURL:url]];
            if (image != nil) {
                FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
                photo.image = image;
                photo.userGenerated = YES;
                [itemsToShare addObject:photo];
            } else {
                containsVideo = YES;
                ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                ALAssetsLibraryWriteVideoCompletionBlock videoWriteCompletionBlock =
                ^(NSURL *newURL, NSError *error) {
                    if (error) {
                        NSLog( @"Error writing image with metadata to Photo Library: %@", error.localizedDescription);
                    } else {
                        NSLog( @"Wrote image with metadata to Photo Library %@", newURL.absoluteString);
                        FBSDKShareVideo *video = [[FBSDKShareVideo alloc] init];
                        video.videoURL = newURL;
                        [itemsToShare addObject:video];
                        if (itemsToShare.count == self.activityItems.count) {
                            FBSDKShareMediaContent *content = [[FBSDKShareMediaContent alloc] init];
                            content.media = [itemsToShare copy];
                            
                            [FBSDKShareDialog showFromViewController:self.sourceViewController
                                                         withContent:content
                                                            delegate:nil];
                            [self activityDidFinish:YES];
                        }
                    }
                };
                if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:url]) {
                    [library writeVideoAtPathToSavedPhotosAlbum:url
                                                completionBlock:videoWriteCompletionBlock];
                }
            }
        }
    }

    if (!containsVideo) {
        if (notLocalImageFileURL) {
            FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
            content.contentURL = self.activityItems[0];
            [FBSDKShareDialog showFromViewController:self.sourceViewController
                                         withContent:content
                                            delegate:nil];
        } else {
            FBSDKShareMediaContent *content = [[FBSDKShareMediaContent alloc] init];
            content.media = [itemsToShare copy];
            
            [FBSDKShareDialog showFromViewController:self.sourceViewController
                                         withContent:content
                                            delegate:nil];
        }
        [self activityDidFinish:YES];
    }
}

@end
