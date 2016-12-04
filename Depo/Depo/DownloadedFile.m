//
//  DownloadedFile.m
//  Depo
//
//  Created by Salih GUC on 04/12/2016.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "DownloadedFile.h"

@implementation DownloadedFile

-(id)initWithFileUUID:(NSString *)uuid localIdentifier:(NSString *)localIdentifier inAlbumName:(NSString *)inAlbumName {
    if (self = [super init]) {
        self.fileUUID = uuid;
        self.fileLocalIdentifier = localIdentifier;
        self.albumName = inAlbumName;
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder {
    //Encode the properties of the object
    [encoder encodeObject:self.fileUUID forKey:@"fileUUID"];
    [encoder encodeObject:self.fileLocalIdentifier forKey:@"fileLocalIdentifier"];
    [encoder encodeObject:self.albumName forKey:@"albumName"];
}

-(id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        //decode the properties
        self.fileUUID = [decoder decodeObjectForKey:@"fileUUID"];
        self.fileLocalIdentifier = [decoder decodeObjectForKey:@"fileLocalIdentifier"];
        self.albumName = [decoder decodeObjectForKey:@"albumName"];
    }
    return self;
}

@end
