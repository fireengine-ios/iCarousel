//
//  Util.h
//  Depo
//
//  Created by Mahir on 9/18/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Util : NSObject

+ (CGFloat) calculateHeightForText:(NSString *)str forWidth:(CGFloat)width forFont:(UIFont *)font;
+ (CGFloat) calculateWidthForText:(NSString *)str forHeight:(CGFloat)height forFont:(UIFont *)font;
+ (UIColor *) UIColorForHexColor:(NSString *) hexColor;
+ (UIImage*) circularScaleNCrop:(UIImage*)image forRect:(CGRect) rect;
+ (NSString *) transformedSizeValue:(long) byteCount;
+ (NSString *) transformedHugeSizeValue:(long long) byteCount;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToFillSize:(CGSize)size;
+ (NSString *) uniqueGlobalDeviceIdentifier;
+ (NSString *) getWorkaroundUUID;

@end
