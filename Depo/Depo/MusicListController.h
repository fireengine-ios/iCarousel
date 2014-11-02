//
//  MusicListController.h
//  Depo
//
//  Created by Mahir on 02/11/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "MyViewController.h"
#import "ElasticSearchDao.h"

@interface MusicListController : MyViewController {
    ElasticSearchDao *elasticSearchDao;
}

@end
