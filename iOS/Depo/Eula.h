//
//  Eula.h
//  Depo
//
//  Created by Mahir Tarlan on 31/03/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Eula : NSObject

@property (nonatomic) int eulaId;
@property (nonatomic, strong) NSString *locale;
@property (nonatomic, strong) NSString *content;

@end
