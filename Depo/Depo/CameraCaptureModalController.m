//
//  CameraCaptureModalController.m
//  Depo
//
//  Created by Mahir on 10/4/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "CameraCaptureModalController.h"
#import "AppUtil.h"
#import "UIImage+Resize.h"

@interface CameraCaptureModalController ()

@end

@implementation CameraCaptureModalController

@synthesize modalDelegate;

- (id)init {
    self = [super init];
    if (self) {
        self.delegate = self;
        self.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.allowsEditing = NO;
        self.showsCameraControls = YES;
    }
    return self;
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSString *camImgName = [AppUtil randomCamImgName];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *tempPath = [documentsDirectory stringByAppendingFormat:@"/%@", camImgName];
    
    UIImage *pickedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage *resized = [pickedImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:pickedImage.size interpolationQuality:kCGInterpolationHigh];

    [UIImageJPEGRepresentation(resized, 1.0) writeToFile:tempPath atomically:NO];
    
    [modalDelegate cameraCapturaModalDidCaptureAndStoreImageToPath:tempPath withName:camImgName];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [modalDelegate cameraCapturaModalDidCancel];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
