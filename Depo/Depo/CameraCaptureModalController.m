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
#import <ImageIO/ImageIO.h>
#import "AccurateLocationManager.h"

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

    BOOL savedWithLoc = NO;
    if([AccurateLocationManager sharedInstance].currentLocation != nil) {
        NSDictionary *locationDict = [self gpsDictionaryForLocation:[AccurateLocationManager sharedInstance].currentLocation];
        NSMutableDictionary *imageMetadata = [[info objectForKey:UIImagePickerControllerMediaMetadata] mutableCopy];
        [imageMetadata setObject:locationDict forKey:(NSString*)kCGImagePropertyGPSDictionary];
        
        //TODO orientation yanlis geliyor
        [imageMetadata removeObjectForKey:@"Orientation"];

        CGImageSourceRef source = CGImageSourceCreateWithData((CFDataRef)UIImageJPEGRepresentation(resized, 1.0), NULL);
        CFStringRef UTI = CGImageSourceGetType(source);
        NSMutableData *destData = [NSMutableData data];
        CGImageDestinationRef destination = CGImageDestinationCreateWithData((CFMutableDataRef)destData, UTI, 1, NULL);
        
        if(destination) {
            CGImageDestinationAddImageFromSource(destination, source, 0, (CFDictionaryRef) imageMetadata);
            
            BOOL success = CGImageDestinationFinalize(destination);
            
            if(success) {
                [destData writeToFile:tempPath atomically:NO];
                savedWithLoc = YES;
            }
            
            CFRelease(destination);
            CFRelease(source);
        }
    }

    if(!savedWithLoc) {
        [UIImageJPEGRepresentation(resized, 1.0) writeToFile:tempPath atomically:NO];
    }
    [modalDelegate cameraCapturaModalDidCaptureAndStoreImageToPath:tempPath withName:camImgName];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSDictionary *) gpsDictionaryForLocation:(CLLocation *)location {
    CLLocationDegrees exifLatitude  = location.coordinate.latitude;
    CLLocationDegrees exifLongitude = location.coordinate.longitude;
    
    NSString * latRef;
    NSString * longRef;
    if (exifLatitude < 0.0) {
        exifLatitude = exifLatitude * -1.0f;
        latRef = @"S";
    } else {
        latRef = @"N";
    }
    
    if (exifLongitude < 0.0) {
        exifLongitude = exifLongitude * -1.0f;
        longRef = @"W";
    } else {
        longRef = @"E";
    }
    
    NSMutableDictionary *locDict = [[NSMutableDictionary alloc] init];

    [locDict setObject:location.timestamp forKey:(NSString*)kCGImagePropertyGPSTimeStamp];
    [locDict setObject:latRef forKey:(NSString*)kCGImagePropertyGPSLatitudeRef];
    [locDict setObject:[NSNumber numberWithFloat:exifLatitude] forKey:(NSString *)kCGImagePropertyGPSLatitude];
    [locDict setObject:longRef forKey:(NSString*)kCGImagePropertyGPSLongitudeRef];
    [locDict setObject:[NSNumber numberWithFloat:exifLongitude] forKey:(NSString *)kCGImagePropertyGPSLongitude];
    [locDict setObject:[NSNumber numberWithFloat:location.horizontalAccuracy] forKey:(NSString*)kCGImagePropertyGPSDOP];
    [locDict setObject:[NSNumber numberWithFloat:location.altitude] forKey:(NSString*)kCGImagePropertyGPSAltitude];
    
    return locDict;
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
