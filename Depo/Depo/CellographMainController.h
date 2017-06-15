//
//  CellographMainController.h
//  Depo
//
//  Created by Mahir Tarlan on 18/07/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "MyViewController.h"
#import "CellographSegmentView.h"

@interface CellographMainController : MyViewController <CellographSegmentDelegate>

@property (nonatomic, strong) CellographSegmentView *segmentView;

@end
