//
//  CountrySelectionController.h
//  Depo
//
//  Created by RDC on 09/03/2017.
//  Copyright © 2017 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CountrySelectionController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic) void(^completion)(NSDictionary*);

@end
