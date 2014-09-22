//
//  SlidingMenu.m
//  Depo
//
//  Created by mahir tarlan
//  Copyright (c) 2014 iGones. All rights reserved.
//

#import "SlidingMenu.h"
#import "AppDelegate.h"
#import "AppSession.h"
#import "AppUtil.h"
#import "MetaMenu.h"
#import "AppConstants.h"
#import "Util.h"

@implementation SlidingMenu

@synthesize delegate;
@synthesize closeDelegate;
@synthesize menuTable;
@synthesize sectionMetaArray;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [Util UIColorForHexColor:@"1a1e24"];
        
        int topIndex = 10;
        if(!IS_BELOW_7) {
            topIndex = 30;
        }
        
        [self updateMenuByLoginStatus];
        
        menuTable = [[UITableView alloc] initWithFrame:CGRectMake(0, topIndex, 276, self.frame.size.height-topIndex) style:UITableViewStylePlain];
        menuTable.delegate = self;
        menuTable.dataSource = self;
        menuTable.backgroundColor = [UIColor clearColor];
        menuTable.backgroundView = nil;
        menuTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        menuTable.separatorColor = [UIColor clearColor];
        [self addSubview:menuTable];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(loginSuccessful)
                                                     name:LOGGED_IN_NOT_NAME object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(silentLoginSuccessful)
                                                     name:SILENT_LOGGED_IN_NOT_NAME object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(logoutSuccessful)
                                                     name:LOGGED_OUT_NOT_NAME object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(forceHomePage)
                                                     name:FORCE_HOMEPAGE_NOTIFICATION object:nil];

    }
    return self;
}

- (void) updateMenuByLoginStatus {
    if(APPDELEGATE.session.user) {
        sectionMetaArray = [AppUtil readMenuItemsForLoggedIn];
    } else {
        sectionMetaArray = [AppUtil readMenuItemsForLoggedIn];
    }
}

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
    return [sectionMetaArray count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(section == 4 || section == 8) {
        return 21;
    }
    return 0;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if(section == 4 || section == 8) {
        UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 21)];
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(12, 10, separatorView.frame.size.width-24, 1)];
        separator.backgroundColor = [Util UIColorForHexColor:@"2c3037"];
        [separatorView addSubview:separator];
        return separatorView;
    }
    return nil;
}
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0)
        return 60;
    else if(indexPath.section == 1)
        return 60;
    else
        return 50;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

/*
-(void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    // fix for separators bug in iOS 7
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
}


-(void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    // fix for separators bug in iOS 7
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
}
*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *cellIdentifier = [NSString stringWithFormat:@"MenuCell%d-%d", indexPath.section, indexPath.row];
    
    MetaMenu *metaData = [sectionMetaArray objectAtIndex:indexPath.section];
    
    if(APPDELEGATE.session.user) {
        if(indexPath.section == 0) {
            MenuProfileCell *cell = [[MenuProfileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withMetaData:metaData];
            return cell;
        } else if(indexPath.section == 1) {
            MenuSearchCell *cell = [[MenuSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withMetaData:metaData];
            return cell;
        } else {
            MenuCell *cell = [[MenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withMetaData:metaData isCollapsible:NO isCollapsed:YES];
            return cell;
        }
    } else {
        if(indexPath.section == 0) {
            MenuProfileCell *cell = [[MenuProfileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withMetaData:metaData];
            return cell;
        } else if(indexPath.section == 1) {
            MenuSearchCell *cell = [[MenuSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withMetaData:metaData];
            return cell;
        } else {
            MenuCell *cell = [[MenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withMetaData:metaData isCollapsible:NO isCollapsed:YES];
            return cell;
        }
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    MenuType sectionType = MenuTypeHome;
    
    if([cell isKindOfClass:[AbstractMenuCell class]]) {
        AbstractMenuCell *menuCell = (AbstractMenuCell *) cell;
        sectionType = menuCell.metaData.menuType;
    }

    switch (sectionType) {
        case MenuTypeHome:
            [delegate didTriggerHome];
            break;
        case MenuTypeSearch:
            [delegate didTriggerSearch];
            break;
        case MenuTypeFav:
            [delegate didTriggerFavorites];
            break;
        case MenuTypeProfile:
            [delegate didTriggerProfile];
            break;
        case MenuTypeFiles:
            [delegate didTriggerFiles];
            break;
        case MenuTypePhoto:
            [delegate didTriggerPhotos];
            break;
        case MenuTypeMusic:
            [delegate didTriggerMusic];
            break;
        case MenuTypeDoc:
            [delegate didTriggerDocs];
            break;
        case MenuTypeLogin:
            [delegate didTriggerLogin];
            break;
        case MenuTypeLogout:
            [delegate didTriggerLogout];
            break;
        default:
            break;
    }
    [self close];
}

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [[NSNotificationCenter defaultCenter] postNotificationName:MENU_SCROLLING_NOTIFICATION object:nil];
}

- (void) close {
    [[NSNotificationCenter defaultCenter] postNotificationName:MENU_CLOSED_NOTIFICATION object:nil];
    [self.closeDelegate shouldClose];
}

- (void) loginSuccessful {
    [self updateMenuByLoginStatus];
    [menuTable reloadData];
    [delegate didTriggerHome];
}

- (void) silentLoginSuccessful {
    [self updateMenuByLoginStatus];
    [menuTable reloadData];
}

- (void) logoutSuccessful {
    [self updateMenuByLoginStatus];
    [menuTable reloadData];
}

- (void) forceHomePage {
    [menuTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] animated:NO scrollPosition:UITableViewScrollPositionNone];
    [delegate didTriggerHome];
}

@end
