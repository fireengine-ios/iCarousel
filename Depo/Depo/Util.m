//
//  Util.m
//  Depo
//
//  Created by Mahir on 9/18/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "Util.h"
#import "AppConstants.h"

@implementation Util

+ (CGFloat) calculateHeightForText:(NSString *)str forWidth:(CGFloat)width forFont:(UIFont *)font {
	CGFloat result = 20.0f;
	if (str) {
		CGSize textSize = { width, 20000.0f };
		CGSize size = [str sizeWithFont:font constrainedToSize:textSize lineBreakMode:UILineBreakModeWordWrap];
		result = MAX(size.height, 20.0f);
	}
	return result;
}

+ (CGFloat) calculateWidthForText:(NSString *)str forHeight:(CGFloat)height forFont:(UIFont *)font {
	CGFloat result = 20.0f;
	if (str) {
		CGSize textSize = { 20000.0f, height };
		CGSize size = [str sizeWithFont:font constrainedToSize:textSize lineBreakMode:UILineBreakModeWordWrap];
		result = MAX(size.width, 20.0f);
	}
	return result;
}

+ (UIColor *) UIColorForHexColor:(NSString *) hexColor {
	unsigned int red, green, blue;
	NSRange range;
	range.length = 2;
    
	range.location = 0;
	[[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&red];
	range.location = 2;
	[[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&green];
	range.location = 4;
	[[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&blue];
	
	return [UIColor colorWithRed:(float)(red/255.0f) green:(float)(green/255.0f) blue:(float)(blue/255.0f) alpha:1.0f];
}

+ (UIImage*) circularScaleNCrop:(UIImage*)image forRect:(CGRect) rect {
    CGFloat ratio = rect.size.height / image.size.height;
    if(image.size.width < image.size.height) {
        ratio = rect.size.width / image.size.width;
    }
    
    UIImage *scaledImage = [UIImage imageWithCGImage:[image CGImage] scale:(image.scale * ratio) orientation:(image.imageOrientation)];
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 1.0);
    [[UIBezierPath bezierPathWithRoundedRect:rect
                                cornerRadius:rect.size.width/2] addClip];
    [scaledImage drawInRect:rect];
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return finalImage;
}

+ (NSString *) transformedSizeValue:(long) byteCount {
    
    double convertedValue = (double) byteCount;
    int multiplyFactor = 0;
    
    NSArray *tokens = [NSArray arrayWithObjects:@"bytes", @"KB", @"MB", @"GB", @"TB", nil];
    
    while (convertedValue >= 1024 && multiplyFactor < [tokens count]-1) {
        convertedValue /= 1024;
        multiplyFactor++;
    }
    
    return [NSString stringWithFormat:@"%4.1f %@", convertedValue, [tokens objectAtIndex:multiplyFactor]];
}

+ (NSString *) transformedHugeSizeValue:(long long) byteCount {
    
    double convertedValue = (double) byteCount;
    int multiplyFactor = 0;
    
    NSArray *tokens = [NSArray arrayWithObjects:@"bytes", @"KB", @"MB", @"GB", @"TB", nil];
    
    while (convertedValue >= 1024 && multiplyFactor < [tokens count]-1) {
        convertedValue /= 1024;
        multiplyFactor++;
    }
    
    if (multiplyFactor == 0 || multiplyFactor == 1 || multiplyFactor == 2)
        return [NSString stringWithFormat:@"%4.0f %@", convertedValue, [tokens objectAtIndex:multiplyFactor]];
    else
        return [NSString stringWithFormat:@"%4.1f %@", convertedValue, [tokens objectAtIndex:multiplyFactor]];
    
}

+ (NSString *) transformedHugeSizeValueNoDecimal:(long long) byteCount {
    
    double convertedValue = (double) byteCount;
    int multiplyFactor = 0;
    
    NSArray *tokens = [NSArray arrayWithObjects:@"bytes", @"KB", @"MB", @"GB", @"TB", nil];
    
    while (convertedValue >= 1024) {
        convertedValue /= 1024;
        multiplyFactor++;
    }
    
    if (multiplyFactor == 0 || multiplyFactor == 1 || multiplyFactor == 2)
        return [NSString stringWithFormat:@"%d %@", (int)convertedValue, [tokens objectAtIndex:multiplyFactor]];
    else
        return [NSString stringWithFormat:@"%d %@", (int)convertedValue, [tokens objectAtIndex:multiplyFactor]];
    
}

+ (NSString *) transformedHugeSizeValueDecimalIfNecessary:(long long) byteCount {
    
    double convertedValue = (double) byteCount;
    int multiplyFactor = 0;
    
    NSArray *tokens = [NSArray arrayWithObjects:@"bytes", @"KB", @"MB", @"GB", @"TB", nil];
    
    while (convertedValue >= 1024) {
        convertedValue /= 1024;
        multiplyFactor++;
    }
    
    BOOL hasDecimal = (convertedValue-(int)convertedValue != 0);
    
    if (multiplyFactor == 0 || multiplyFactor == 1 || multiplyFactor == 2)
        return [NSString stringWithFormat:@"%d %@", (int)convertedValue, [tokens objectAtIndex:multiplyFactor]];
    else
        return hasDecimal ? [NSString stringWithFormat:@"%4.1f %@", convertedValue, [tokens objectAtIndex:multiplyFactor]] : [NSString stringWithFormat:@"%d %@", (int)convertedValue, [tokens objectAtIndex:multiplyFactor]];
    
}

+ (NSArray *) transformedHugeSizeValueDecimalAsArrayIfNecessary:(long long) byteCount {
    
    double convertedValue = (double) byteCount;
    int multiplyFactor = 0;
    
    NSArray *tokens = [NSArray arrayWithObjects:@"bytes", @"KB", @"MB", @"GB", @"TB", nil];
    
    while (convertedValue >= 1024) {
        convertedValue /= 1024;
        multiplyFactor++;
    }
    
    BOOL hasDecimal = (convertedValue-(int)convertedValue != 0);
    
    if (multiplyFactor == 0 || multiplyFactor == 1 || multiplyFactor == 2)
        return [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", (int)convertedValue], [tokens objectAtIndex:multiplyFactor], nil];
    else
        return [NSArray arrayWithObjects:hasDecimal ? [NSString stringWithFormat:@"%4.1f", convertedValue] : [NSString stringWithFormat:@"%d", (int)convertedValue], [tokens objectAtIndex:multiplyFactor], nil];
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToFillSize:(CGSize)size {
    CGFloat scale = MAX(size.width/image.size.width, size.height/image.size.height);
    CGFloat width = image.size.width * scale;
    CGFloat height = image.size.height * scale;
    CGRect imageRect = CGRectMake((size.width - width)/2.0f,
                                  (size.height - height)/2.0f,
                                  width,
                                  height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [image drawInRect:imageRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (NSString *) uniqueGlobalDeviceIdentifier {
    if (SYSTEM_VERSION_LESS_THAN(@"6.0")) {
        return [Util getWorkaroundUUID];
    } else {
        NSString *uniqueIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        return uniqueIdentifier;
    }
}

+ (NSString *) getWorkaroundUUID {
    NSString *UUID = [[NSUserDefaults standardUserDefaults] objectForKey:@"tsdk_unique_id"];
    if (!UUID) {
        CFUUIDRef theUUID = CFUUIDCreate(NULL);
        CFStringRef string = CFUUIDCreateString(NULL, theUUID);
        CFRelease(theUUID);
        UUID = [(__bridge NSString*)string stringByReplacingOccurrencesOfString:@"-"withString:@""];
        [[NSUserDefaults standardUserDefaults] setValue:UUID forKey:@"tsdk_unique_id"];
    }
    return UUID;
}

+ (NSString *) cleanSpecialCharacters:(NSString *) rawStr {
    rawStr = [rawStr stringByReplacingOccurrencesOfString:@"^" withString:@""];
    rawStr = [rawStr stringByReplacingOccurrencesOfString:@"/" withString:@""];
    rawStr = [rawStr stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    rawStr = [rawStr stringByReplacingOccurrencesOfString:@":" withString:@""];
    rawStr = [rawStr stringByReplacingOccurrencesOfString:@"*" withString:@""];
    rawStr = [rawStr stringByReplacingOccurrencesOfString:@"?" withString:@""];
    rawStr = [rawStr stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    rawStr = [rawStr stringByReplacingOccurrencesOfString:@"<" withString:@""];
    rawStr = [rawStr stringByReplacingOccurrencesOfString:@">" withString:@""];
    rawStr = [rawStr stringByReplacingOccurrencesOfString:@"|" withString:@""];
    return rawStr;
}

@end
