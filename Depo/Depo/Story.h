//
//  Story.h
//  Depo
//
//  Created by Mahir Tarlan on 05/07/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Story : NSObject

@property (nonatomic, strong) NSMutableArray *fileList;
@property (nonatomic, strong) NSString *musicFileUuid;
@property (nonatomic, strong) NSString *musicFileId;
@property (nonatomic, strong) NSString *title;

@end
