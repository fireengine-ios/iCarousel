//
//  FacebookController.h
//  Depo
//
//  Created by Mahir Tarlan on 30/06/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "SocialBaseController.h"
#import "FBStatusDao.h"
#import "FBStartDao.h"

@interface FacebookController : SocialBaseController

@property (nonatomic, strong) FBStatusDao *statusDao;
@property (nonatomic, strong) FBStartDao *startDao;

@end
