//
//  ContactSyncResultView.m
//  Depo
//
//  Created by Turan Yilmaz on 28/03/2017.
//  Copyright © 2017 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactSyncResultView.h"
#import "CustomLabel.h"
#import "Util.h"
#import "AppConstants.h"

@implementation ContactSyncResultView

- (id) initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        UIView *rootContainer = [[UIView alloc] init];
        [self addSubview:rootContainer];
        
        
        float contactImageViewSize = IS_IPAD ? 120 : IS_IPHONE_6P_OR_HIGHER ? 110 : 90;
        
        UIImageView *contactImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, (frame.size.height-110)/2, contactImageViewSize, contactImageViewSize)];
        contactImageView.contentMode = UIViewContentModeScaleAspectFit;
        contactImageView.image = [UIImage imageNamed:@"new_contacts_icon.png"];
        [rootContainer addSubview:contactImageView];
        
        UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(contactImageView.frame.size.width + 10, 0 , 2, contactImageView.frame.size.height * 1.5)];
        [self alignViewToCenter:lineImageView toView:contactImageView onCoordinate:@"y"];
        lineImageView.image = [UIImage imageNamed:@"Line.png"];
        [rootContainer addSubview:lineImageView];
        
        UIView *container = [[UIView alloc] initWithFrame:CGRectMake((lineImageView.frame.origin.x + 10), lineImageView.frame.origin.y + 30 , lineImageView.frame.size.height, lineImageView.frame.size.height)];
        [rootContainer addSubview:container];
        
        self.totalCountLabel = [[CustomLabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:36] withColor:[Util UIColorForHexColor:@"3fb0e8"] withText:@"0"];
        [container addSubview:self.totalCountLabel];
        
        self.label = [[CustomLabel alloc] initWithFrame:CGRectMake(0, self.totalCountLabel.frame.size.height, frame.size.width/2, 100) withFont:[UIFont fontWithName:@"TurkcellSaturaBol" size:20] withColor:[Util UIColorForHexColor:@"3fb0e8"] withText:@"" withAlignment:NSTextAlignmentLeft numberOfLines:7];
        self.label.lineBreakMode = NSLineBreakByWordWrapping;
        [container addSubview:self.label];
        [self wrapSubviews:container];
        [self alignViewToCenter:container toView:lineImageView onCoordinate:@"y"];
        
        
        [self wrapSubviews:rootContainer];
        [self alignViewToCenter:rootContainer toView:self onCoordinate:@"x"];
        
    }
    return self;
}

- (void) wrapSubviews:(UIView *) view {
    float w = 0;
    float h = 0;
    
    for (UIView *v in [view subviews]) {
        float fw = v.frame.origin.x + v.frame.size.width;
        float fh = v.frame.origin.y + v.frame.size.height;
        w = MAX(fw, w);
        h = MAX(fh, h);
    }
    
    [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, w, h)];
}

- (void) alignViewToCenter:(UIView *) view toView:(UIView *) secondView onCoordinate:(NSString *) coordinate {
    
    CGPoint tempCenter = view.center;
    if ([coordinate isEqualToString:@"x"]) {
        tempCenter.x = secondView.center.x;
    } else {
        tempCenter.y = secondView.center.y;
    }
    view.center = tempCenter;
}

@end
