//
//  Util.m
//  Depo
//
//  Created by Mahir on 9/18/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "Util.h"
#import "AppConstants.h"
#import <sys/utsname.h>

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
        return [NSString stringWithFormat:@"%.0f %@", convertedValue, [tokens objectAtIndex:multiplyFactor]];
    else
        return [NSString stringWithFormat:@"%.1f %@", convertedValue, [tokens objectAtIndex:multiplyFactor]];
    
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

+ (BOOL) isValidEmail:(NSString *)checkString {
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

+ (NSString *) readLocaleCode {
    NSLocale *locale = [NSLocale currentLocale];
    NSString *langCode = [locale objectForKey:NSLocaleLanguageCode];
    if(langCode == nil) {
        langCode = @"en";
    }
    return langCode;
}

+ (NSString *)deviceType {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *result = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    NSDictionary *matches = @{
                              @"i386" : @"32-bit Simulator",
                              @"x86_64" : @"64-bit Simulator",
                              @"iPod1,1" : @"iPod Touch",
                              @"iPod2,1" : @"iPod Touch Second Generation",
                              @"iPod3,1" : @"iPod Touch Third Generation",
                              @"iPod4,1" : @"iPod Touch Fourth Generation",
                              @"iPod5,1" : @"iPod Touch Fifth Generation",
                              @"iPhone1,1" : @"iPhone",
                              @"iPhone1,2" : @"iPhone 3G",
                              @"iPhone2,1" : @"iPhone 3GS",
                              @"iPad1,1" : @"iPad",
                              @"iPad2,1" : @"iPad 2",
                              @"iPad3,1" : @"3rd Generation iPad",
                              @"iPad3,2" : @"iPad 3(GSM+CDMA)",
                              @"iPad3,3" : @"iPad 3(GSM)",
                              @"iPad3,4" : @"iPad 4(WiFi)",
                              @"iPad3,5" : @"iPad 4(GSM)",
                              @"iPad3,6" : @"iPad 4(GSM+CDMA)",
                              @"iPhone3,1" : @"iPhone 4",
                              @"iPhone4,1" : @"iPhone 4S",
                              @"iPad3,4" : @"4th Generation iPad",
                              @"iPad2,5" : @"iPad Mini",
                              @"iPhone5,1" : @"iPhone 5(GSM)",
                              @"iPhone5,2" : @"iPhone 5(GSM+CDMA)",
                              @"iPhone5,3" : @"iPhone 5C(GSM)",
                              @"iPhone5,4" : @"iPhone 5C(GSM+CDMA)",
                              @"iPhone6,1" : @"iPhone 5S(GSM)",
                              @"iPhone6,2" : @"iPhone 5S(GSM+CDMA)",
                              @"iPhone7,1" : @"iPhone 6 Plus",
                              @"iPhone7,2" : @"iPhone 6",
                              @"iPhone8,1" : @"iPhone 6S",
                              @"iPhone8,2" : @"iPhone 6S Plus"
                              };
    
    if (matches[result]) {
        return matches[result];
    } else {
        return result;
    }
}

+ (double) getDiskUsage {
    double totalSpace = 0;
    double totalFreeSpace = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary && error == nil) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes doubleValue];
        totalFreeSpace = [freeFileSystemSizeInBytes doubleValue];
    } else {
        NSString *log = [NSString stringWithFormat:@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]];
        NSLog(@"getDiskUsage %@", log);
    }
    
    return 1 - ((totalFreeSpace/1024ll)/1024ll) / ((totalSpace/1024ll)/1024ll);
}

@end
