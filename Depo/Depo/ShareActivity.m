//
//  ShareActivity.m
//  ShareTest
//
//  Created by Ömer Burak Kır on 20/03/2017.
//  Copyright © 2017 Ömer Burak Kır. All rights reserved.
//

#import "ShareActivity.h"
#import <FBSDKShareKit/FBSDKShareKit.h>

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
            NSData *data=[NSData dataWithContentsOfURL:item];
            UIImage *image=[UIImage imageWithData:data];
            if (image != nil) {
                return YES;
            }
            return NO;
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
    
    id firstItem = self.activityItems[0];
    
    NSMutableArray *itemsToShare = [@[] mutableCopy];
    
    if ([firstItem isKindOfClass:[UIImage class]]) {
        for (UIImage *image in self.activityItems) {
            FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
            photo.image = image;
            photo.userGenerated = YES;
            [itemsToShare addObject:photo];
        }
    } else if ([firstItem isKindOfClass:[NSURL class]]) {
        for (NSURL *url in self.activityItems) {
            UIImage *image = [UIImage imageWithData:
                              [NSData dataWithContentsOfURL:url]];
            FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
            photo.image = image;
            photo.userGenerated = YES;
            [itemsToShare addObject:photo];
        }
    }
    
    FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
    content.photos = [itemsToShare copy];
    
    [FBSDKShareDialog showFromViewController:self.sourceViewController
                                 withContent:content
                                    delegate:nil];
    [self activityDidFinish:YES];
}

@end
