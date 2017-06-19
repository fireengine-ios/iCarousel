//
//  RenameAlbumDao.h
//  Depo
//
//  Created by Mahir on 13.11.2014.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import "BaseDao.h"

@interface RenameAlbumDao : BaseDao

@property (nonatomic, strong) NSString *nameRef;

- (void) requestRenameAlbum:(NSString *) albumUuid withNewName:(NSString *) newName;

@end
