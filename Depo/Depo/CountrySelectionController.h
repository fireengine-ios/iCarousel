//
//  CountrySelectionController.h
//  Depo
//
//  Created by RDC on 09/03/2017.
//  Copyright © 2017 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CountrySelectionController : UITableViewController <UISearchBarDelegate>

@property (nonatomic) void(^completion)(id);

@end
