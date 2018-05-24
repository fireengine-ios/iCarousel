//
//  MMessageResponse.h
//  MPush
//
//  Created by Vlad Soroka on 9/7/17.
//  Copyright © 2017 MPush. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MMessage.h"
#import "MAction.h"

@interface MMessageResponse : NSObject

@property (nonatomic, nonnull, readonly) MMessage* message;
@property (nonatomic, nonnull, readonly) MAction* action;

- (NSDictionary * _Nonnull ) dictionaryRepresentation;

@end
