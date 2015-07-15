//
//  ShareViewController.m
//  ShareExtension
//
//  Created by Mahir on 13/07/15.
//  Copyright (c) 2015 com.igones. All rights reserved.
//

#import "ShareViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface ShareViewController ()

@end

@implementation ShareViewController

- (BOOL)isContentValid {
    // Do validation of contentText and/or NSExtensionContext attachments here
    return YES;
}

- (void)didSelectPost {
    // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
    // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
    __block UIImage *imgRef = nil;
    
    NSExtensionItem *inputItem = self.extensionContext.inputItems.firstObject;
    NSItemProvider *itemProvider = inputItem.attachments.firstObject;
    if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *) kUTTypeImage]) {
        [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeImage options:nil completionHandler:^(UIImage *image, NSError *error) {
            if(image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    imgRef = image;
                    NSLog(@"Image Desc:%@", image.description);
                });
            }
        }];
    }
    
    NSExtensionItem *outputItem = [inputItem copy];
    outputItem.attributedContentText = [[NSAttributedString alloc] initWithString:self.contentText attributes:nil];
    // Complete this implementation by setting the appropriate value on the output item.
    
    NSArray *outputItems = @[outputItem];
    
    [self.extensionContext completeRequestReturningItems:outputItems completionHandler:nil];
}

- (NSArray *)configurationItems {
    item = [[SLComposeSheetConfigurationItem alloc] init];
    [item setTitle:@"Uploading_Img"];
    [item setValue:@"None"];
    [item setTapHandler:^(void){
    }];
    return @[item];
}

@end
