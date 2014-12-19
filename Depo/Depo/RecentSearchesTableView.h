//
//  RecentSearchesController.h
//  Depo
//
//  Created by NCO on 24/11/14.
//  Copyright (c) 2014 com.igones. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomButton.h"
#import "SearchTextField.h"

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

@interface RecentSearchesTableView : UITableView <UITableViewDelegate, UITableViewDataSource> {
    CustomButton *crossButton;
    UIButton *clearButton;
    SearchTextField *searchField;
    float topIndex;
    BOOL visibleStatus;
    SEL searchMethod;
    id ownerController;
}

@property (nonatomic) NSMutableArray *dataArray;
@property (nonatomic) SEL searchMethod;
@property (nonatomic, strong) id ownerController;
@property (nonatomic) float tableHeight;

- (id)initWithSearchField:(SearchTextField *)srchFld;
- (void)showTableView;
- (void)hideTableView;
- (void)addTextToSearchHistory:(NSString *)text;



@end
