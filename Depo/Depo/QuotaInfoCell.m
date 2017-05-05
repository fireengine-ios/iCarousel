//
//  QuotaInfoView.m
//  Depo
//
//  Created by RDC Partner on 22/02/2017.
//  Copyright © 2017 com.igones. All rights reserved.
//

#import "QuotaInfoCell.h"
#import "CustomLabel.h"
#import <QuartzCore/QuartzCore.h>
#import "Util.h"
#import "AppConstants.h"

@interface QuotaInfoCell() {
    
}



@end

@implementation QuotaInfoCell

@synthesize packageUsageBar;
@synthesize sizeOfUsedPackageLabel;
@synthesize sizeOfPackageLabel;
@synthesize sizeUnitLabel;
@synthesize packageUsageContainer;

-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withTitle:(NSString *) title withUsage:(id) usage withCellRect:(CGRect) rect showInternetData:(BOOL) shouldShow {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        CGRect cellRect = rect;
        
        NSArray *QuotaInfoArray;
        double usedQuotaPercentage;
        
        if(shouldShow) {
            Usage *internetDataUsage = [[Usage alloc] init];
            InternetDataUsage *idu = usage;
            internetDataUsage.totalStorage = (idu.total * 1024) * 1024;
            internetDataUsage.usedStorage = ((idu.total - idu.remaining) * 1024) * 1024;
            QuotaInfoArray = [self parseQuotaString:internetDataUsage];
            title = idu.offerName;
            //             usedQuotaPercentage = (double)(usage.internetDataUsage.total - usage.internetDataUsage.remaining) / (double)usage.internetDataUsage.total;
            usedQuotaPercentage = (double)(idu.remaining) / (double)idu.total;
        } else {
            Usage *tempUsage = usage;
            QuotaInfoArray = [self parseQuotaString:tempUsage];
            //             usedQuotaPercentage = (double)usage.usedStorage/(double)usage.totalStorage;
            usedQuotaPercentage = (double)tempUsage.remainingStorage/(double)tempUsage.totalStorage;
        }
        
        //Package Name Label
        
        CustomLabel *packageLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 15) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:16] withColor:[Util UIColorForHexColor:@"363e4f"] withText:@"" withAlignment:NSTextAlignmentLeft numberOfLines:1];
        packageLabel.text = title;
        [self addSubview:packageLabel];
        
        //Package Date Label
        
        if(shouldShow) {
            InternetDataUsage *idu = usage;
            CustomLabel *packageDateLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, packageLabel.frame.size.height + 5, self.frame.size.width, 15) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:12] withColor:[Util UIColorForHexColor:@"7b8497"] withText:@"" withAlignment:NSTextAlignmentLeft numberOfLines:1];
            packageDateLabel.text = [self getExpireDate:idu.expiryDate];
            [self addSubview:packageDateLabel];
        }
        
        //Package Usage Bar
        
        packageUsageBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        packageUsageBar.frame = CGRectMake(0, cellRect.size.height - packageUsageBar.frame.size.height, cellRect.size.width, packageUsageBar.frame.size.height);
        CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 4.0f);
        packageUsageBar.transform = transform;
        packageUsageBar.progressImage = [UIImage imageNamed:@"progress_fill_pattern.png"];
        packageUsageBar.trackImage = [UIImage imageNamed:@"progress_bg_pattern.png"];
        [packageUsageBar setProgress:usedQuotaPercentage];
        [self addSubview:packageUsageBar];
        
        //Package Rest Label
        
        CustomLabel *packageRestLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, packageUsageBar.frame.origin.y - 17, 60, 12) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:12] withColor:[Util UIColorForHexColor:@"7b8497"] withText:NSLocalizedString(@"RemainingQuotaTitle", @"") withAlignment:NSTextAlignmentLeft numberOfLines:1];
        [self addSubview:packageRestLabel];
        
        //Package Usage Label Container
        
        packageUsageContainer = [[UIView alloc] initWithFrame:CGRectMake((cellRect.size.width - 40) - 100, packageRestLabel.frame.origin.y - 30 + packageRestLabel.frame.size.height, 100, 30)];
        //    packageUsageContainer.backgroundColor = [UIColor redColor];
        [self addSubview:packageUsageContainer];
        
        //Package Size Of Used Label
        
        sizeOfUsedPackageLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0,2,0,0) withFont:[UIFont fontWithName:@"TurkcellSaturaReg" size:25] withColor:[Util UIColorForHexColor:@"EC2182"] withText:@"" withAlignment:NSTextAlignmentLeft numberOfLines:0];
        sizeOfUsedPackageLabel.text = QuotaInfoArray[2];
        [sizeOfUsedPackageLabel sizeToFit];
        //             sizeOfUsedPackageLabel.backgroundColor = [UIColor yellowColor];
        [packageUsageContainer addSubview:sizeOfUsedPackageLabel];
        
        CustomLabel *sizeUnitLabel2 = [[CustomLabel alloc] initWithFrame:CGRectMake(sizeOfUsedPackageLabel.frame.origin.x + sizeOfUsedPackageLabel.frame.size.width + 3,1,0,0) withFont:[UIFont fontWithName:@"TurkcellSaturaReg" size:15] withColor:[Util UIColorForHexColor:@"7b8497"] withText:@""];
        sizeUnitLabel2.text = QuotaInfoArray[3];
        [sizeUnitLabel2 sizeToFit];
        sizeUnitLabel2.frame = CGRectMake(sizeOfUsedPackageLabel.frame.size.width + sizeOfUsedPackageLabel.frame.origin.x + 3,sizeOfUsedPackageLabel.frame.size.height - sizeUnitLabel2.frame.size.height,sizeUnitLabel2.frame.size.width, sizeUnitLabel2.frame.size.height);
        //    sizeUnitLabel2.backgroundColor = [UIColor yellowColor];
        [packageUsageContainer addSubview:sizeUnitLabel2];
        
        int horizontalIndex = 5;
        
        //Package - Separator
        
        UIView *packageSeparator = [[UIView alloc] initWithFrame:CGRectMake(sizeUnitLabel2.frame.origin.x + sizeUnitLabel2.frame.size.width + 7, 7, 1, 20)];
        packageSeparator.backgroundColor = [Util UIColorForHexColor:@"ebebed"];
        [packageUsageContainer addSubview:packageSeparator];
        
        horizontalIndex += 5;
        
        //Package - Size of Package
        
        sizeOfPackageLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(packageSeparator.frame.origin.x + packageSeparator.frame.size.width + 7,2,0,0) withFont:[UIFont fontWithName:@"TurkcellSaturaReg" size:25] withColor:[Util UIColorForHexColor:@"5a5859"] withText:@""];
        sizeOfPackageLabel.text = QuotaInfoArray[0];
        [sizeOfPackageLabel sizeToFit];
        //    sizeOfPackageLabel.backgroundColor = [UIColor yellowColor];
        [packageUsageContainer addSubview:sizeOfPackageLabel];
        
        horizontalIndex += 3;
        
        //Package Size Unit Label 2
        
        sizeUnitLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(sizeOfPackageLabel.frame.origin.x + sizeOfPackageLabel.frame.size.width + 3,1,0,0) withFont:[UIFont fontWithName:@"TurkcellSaturaReg" size:15] withColor:[Util UIColorForHexColor:@"7b8497"] withText:@""];
        sizeUnitLabel.text = QuotaInfoArray[1];
        [sizeUnitLabel sizeToFit];
        sizeUnitLabel.frame = CGRectMake(sizeOfPackageLabel.frame.size.width + sizeOfPackageLabel.frame.origin.x + 3,sizeOfPackageLabel.frame.size.height - sizeUnitLabel.frame.size.height,sizeUnitLabel.frame.size.width, sizeUnitLabel.frame.size.height);
        //    sizeUnitLabel2.backgroundColor = [UIColor yellowColor];
        [packageUsageContainer addSubview:sizeUnitLabel];
        
        float w = 0;
        float h = 0;
        
        for (UIView *v in [packageUsageContainer subviews]) {
            float fw = v.frame.origin.x + v.frame.size.width;
            float fh = v.frame.origin.y + v.frame.size.height;
            w = MAX(fw, w);
            h = MAX(fh, h);
        }
        [packageUsageContainer setFrame:CGRectMake(packageUsageContainer.frame.origin.x, packageUsageContainer.frame.origin.y, w, h)];
        
        packageUsageContainer.frame = CGRectMake((cellRect.size.width - packageUsageContainer.frame.size.width), packageUsageContainer.frame.origin.y, packageUsageContainer.frame.size.width, packageUsageContainer.frame.size.height);
        
    }
    return self;
}

//- (id) initWithFrame:(CGRect)frame withTitle:(NSString *) title withUsage:(Usage *) usage withControllerView:(UIView *) view showInternetData:(BOOL) shouldShow {
//     if(self = [super initWithFrame:frame]) {
//         
//         controllerView = view;
//         
//         NSArray *QuotaInfoArray;
//         double usedQuotaPercentage;
//         
//         if(shouldShow) {
//             Usage *internetDataUsage = [[Usage alloc] init];
//             internetDataUsage.totalStorage = (usage.internetDataUsage.total * 1024) * 1024;
//             internetDataUsage.usedStorage = ((usage.internetDataUsage.total - usage.internetDataUsage.remaining) * 1024) * 1024;
//             QuotaInfoArray = [self parseQuotaString:internetDataUsage];
//             title = usage.internetDataUsage.offerName;
////             usedQuotaPercentage = (double)(usage.internetDataUsage.total - usage.internetDataUsage.remaining) / (double)usage.internetDataUsage.total;
//             usedQuotaPercentage = (double)(usage.internetDataUsage.remaining) / (double)usage.internetDataUsage.total;
//         } else {
//             QuotaInfoArray = [self parseQuotaString:usage];
////             usedQuotaPercentage = (double)usage.usedStorage/(double)usage.totalStorage;
//             usedQuotaPercentage = (double)usage.remainingStorage/(double)usage.totalStorage;
//         }
//         
//         //Package Name Label
//         
//         CustomLabel *packageLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 15) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:16] withColor:[Util UIColorForHexColor:@"363e4f"] withText:@"" withAlignment:NSTextAlignmentLeft numberOfLines:1];
//         packageLabel.text = title;
//         [self addSubview:packageLabel];
//         
//         //Package Date Label
//         
//         if(shouldShow) {
//             CustomLabel *packageDateLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, packageLabel.frame.size.height + 5, self.frame.size.width, 15) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:12] withColor:[Util UIColorForHexColor:@"7b8497"] withText:@"" withAlignment:NSTextAlignmentLeft numberOfLines:1];
//             packageDateLabel.text = [self getExpireDate:usage.internetDataUsage.expiryDate];
//             [self addSubview:packageDateLabel];
//         }
//         
//         //Package Usage Bar
//         
//         packageUsageBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
//         packageUsageBar.frame = CGRectMake(0, self.frame.size.height - packageUsageBar.frame.size.height, self.frame.size.width, packageUsageBar.frame.size.height);
//         CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 4.0f);
//         packageUsageBar.transform = transform;
//         packageUsageBar.progressImage = [UIImage imageNamed:@"progress_fill_pattern.png"];
//         packageUsageBar.trackImage = [UIImage imageNamed:@"progress_bg_pattern.png"];
//         [packageUsageBar setProgress:usedQuotaPercentage];
//         [self addSubview:packageUsageBar];
//         
//         //Package Rest Label
//         
//         CustomLabel *packageRestLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, packageUsageBar.frame.origin.y - 17, 60, 12) withFont:[UIFont fontWithName:@"TurkcellSaturaDem" size:12] withColor:[Util UIColorForHexColor:@"7b8497"] withText:NSLocalizedString(@"RemainingQuotaTitle", @"") withAlignment:NSTextAlignmentLeft numberOfLines:1];
//         [self addSubview:packageRestLabel];
//         
//         //Package Usage Label Container
//         
//         packageUsageContainer = [[UIView alloc] initWithFrame:CGRectMake((view.frame.size.width - 40) - 100, packageRestLabel.frame.origin.y - 30 + packageRestLabel.frame.size.height, 100, 30)];
//         //    packageUsageContainer.backgroundColor = [UIColor redColor];
//         [self addSubview:packageUsageContainer];
//         
//         //Package Size Of Used Label
//         
//         sizeOfUsedPackageLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0,2,0,0) withFont:[UIFont fontWithName:@"TurkcellSaturaReg" size:25] withColor:[Util UIColorForHexColor:@"EC2182"] withText:@"" withAlignment:NSTextAlignmentLeft numberOfLines:0];
//         sizeOfUsedPackageLabel.text = QuotaInfoArray[2];
//         [sizeOfUsedPackageLabel sizeToFit];
////             sizeOfUsedPackageLabel.backgroundColor = [UIColor yellowColor];
//         [packageUsageContainer addSubview:sizeOfUsedPackageLabel];
//         
//         CustomLabel *sizeUnitLabel2 = [[CustomLabel alloc] initWithFrame:CGRectMake(sizeOfUsedPackageLabel.frame.origin.x + sizeOfUsedPackageLabel.frame.size.width + 3,1,0,0) withFont:[UIFont fontWithName:@"TurkcellSaturaReg" size:15] withColor:[Util UIColorForHexColor:@"7b8497"] withText:@""];
//         sizeUnitLabel2.text = QuotaInfoArray[3];
//         [sizeUnitLabel2 sizeToFit];
//         sizeUnitLabel2.frame = CGRectMake(sizeOfUsedPackageLabel.frame.size.width + sizeOfUsedPackageLabel.frame.origin.x + 3,sizeOfUsedPackageLabel.frame.size.height - sizeUnitLabel2.frame.size.height,sizeUnitLabel2.frame.size.width, sizeUnitLabel2.frame.size.height);
//         //    sizeUnitLabel2.backgroundColor = [UIColor yellowColor];
//         [packageUsageContainer addSubview:sizeUnitLabel2];
//         
//         int horizontalIndex = 5;
//         
//         //Package - Separator
//         
//         UIView *packageSeparator = [[UIView alloc] initWithFrame:CGRectMake(sizeUnitLabel2.frame.origin.x + sizeUnitLabel2.frame.size.width + 7, 7, 1, 20)];
//         packageSeparator.backgroundColor = [Util UIColorForHexColor:@"ebebed"];
//         [packageUsageContainer addSubview:packageSeparator];
//         
//         horizontalIndex += 5;
//         
//         //Package - Size of Package
//         
//         sizeOfPackageLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(packageSeparator.frame.origin.x + packageSeparator.frame.size.width + 7,2,0,0) withFont:[UIFont fontWithName:@"TurkcellSaturaReg" size:25] withColor:[Util UIColorForHexColor:@"5a5859"] withText:@""];
//         sizeOfPackageLabel.text = QuotaInfoArray[0];
//         [sizeOfPackageLabel sizeToFit];
//         //    sizeOfPackageLabel.backgroundColor = [UIColor yellowColor];
//         [packageUsageContainer addSubview:sizeOfPackageLabel];
//         
//         horizontalIndex += 3;
//         
//         //Package Size Unit Label 2
//         
//         sizeUnitLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(sizeOfPackageLabel.frame.origin.x + sizeOfPackageLabel.frame.size.width + 3,1,0,0) withFont:[UIFont fontWithName:@"TurkcellSaturaReg" size:15] withColor:[Util UIColorForHexColor:@"7b8497"] withText:@""];
//         sizeUnitLabel.text = QuotaInfoArray[1];
//         [sizeUnitLabel sizeToFit];
//         sizeUnitLabel.frame = CGRectMake(sizeOfPackageLabel.frame.size.width + sizeOfPackageLabel.frame.origin.x + 3,sizeOfPackageLabel.frame.size.height - sizeUnitLabel.frame.size.height,sizeUnitLabel.frame.size.width, sizeUnitLabel.frame.size.height);
//         //    sizeUnitLabel2.backgroundColor = [UIColor yellowColor];
//         [packageUsageContainer addSubview:sizeUnitLabel];
//         
//         float w = 0;
//         float h = 0;
//         
//         for (UIView *v in [packageUsageContainer subviews]) {
//             float fw = v.frame.origin.x + v.frame.size.width;
//             float fh = v.frame.origin.y + v.frame.size.height;
//             w = MAX(fw, w);
//             h = MAX(fh, h);
//         }
//         [packageUsageContainer setFrame:CGRectMake(packageUsageContainer.frame.origin.x, packageUsageContainer.frame.origin.y, w, h)];
//         
//         packageUsageContainer.frame = CGRectMake((controllerView.frame.size.width - 40 - packageUsageContainer.frame.size.width), packageUsageContainer.frame.origin.y, packageUsageContainer.frame.size.width, packageUsageContainer.frame.size.height);
//
//     }
//    return self;
//}

- (NSArray *) parseQuotaString:(Usage *) usage {
    
    NSString *totalStorage = [Util transformedHugeSizeValueDecimalIfNecessary:usage.totalStorage];
    NSArray *myArray = [totalStorage componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
    
    NSString *remainingStorage = [Util transformedHugeSizeValue:(usage.totalStorage - usage.usedStorage)];
    NSArray *myArray2 = [remainingStorage componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
    
//    NSString *usedStorage = [Util transformedHugeSizeValue:[usage usedStorage]];
//    NSArray *myArray2 = [usedStorage componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];

    return [myArray arrayByAddingObjectsFromArray:myArray2];
    
}

- (NSString *) getExpireDate:(long long) timeInMiliseconds {
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:((double)timeInMiliseconds / 1000)];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd MMM yy"];
    NSString *dateString = [dateFormat stringFromDate:date];
    
    return dateString;
}

@end

