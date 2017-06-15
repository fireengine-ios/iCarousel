//
//  VideofyAudioCell.h
//  Depo
//
//  Created by Mahir Tarlan on 08/07/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideofyAudio.h"

@protocol VideofyAudioCellDelegate <NSObject>
- (void) videofyAudioCellPlayClickedWithId:(long) audioId;
- (void) videofyAudioCellPauseClickedWithId:(long) audioId;
@end

@interface VideofyAudioCell : UITableViewCell

@property (nonatomic, weak) id<VideofyAudioCellDelegate> delegate;
@property (nonatomic, strong) VideofyAudio *audio;

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withAudio:(VideofyAudio *) _audio;

@end
