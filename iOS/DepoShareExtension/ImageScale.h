//
//  ImageScale.h
//  Depo
//
//  Created by Turan Yilmaz on 14/04/2017.
//  Copyright © 2017 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageScale : NSObject

+ (UIImage*)imageWithImage:(UIImage*)sourceImage scaledToSize:(CGSize)newSize;

@end
