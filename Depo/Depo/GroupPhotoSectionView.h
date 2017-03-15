//
//  GroupPhotoSectionView.h
//  Depo
//
//  Created by Mahir Tarlan on 15/11/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CheckButton.h"

@protocol GroupPhotoSectionViewDelegate <NSObject>
- (void) groupPhotoSectionViewCheckboxChecked:(NSString *) titleVal;
- (void) groupPhotoSectionViewCheckboxUnchecked:(NSString *) titleVal;
@end

@interface GroupPhotoSectionView : UICollectionReusableView <CheckButtonDelegate>

@property (nonatomic, weak) id<GroupPhotoSectionViewDelegate> checkDelegate;

- (void) loadSectionWithTitle:(NSString *) titleVal isSelectible:(BOOL) selectibleFlag isSelected:(BOOL) selectedFlag;

@end
