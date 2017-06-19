//
//  CameraCaptureModalController.h
//  Depo
//
//  Created by Mahir on 10/4/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@protocol CameraCapturaModalDelegate <NSObject>
- (void) cameraCapturaModalDidCancel;
- (void) cameraCapturaModalDidCaptureAndStoreImageToPath:(NSString *) filePath withName:(NSString *) fileName;
@end

@interface CameraCaptureModalController : UIImagePickerController <UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
}

@property (nonatomic, weak) id<CameraCapturaModalDelegate> modalDelegate;

@end
