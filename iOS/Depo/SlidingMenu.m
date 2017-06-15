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
@synthesize audioFooterView;
@synthesize tableUpdateCounter;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [Util UIColorForHexColor:@"1a1e24"];
        
        int topIndex = 10;
        if(!IS_BELOW_7) {
            topIndex = 30;
        }
        
        tableUpdateCounter = 1;
        [self updateMenuByLoginStatus];
        
        menuTable = [[UITableView alloc] initWithFrame:CGRectMake(0, topIndex, 276, self.frame.size.height-topIndex) style:UITableViewStylePlain];
        menuTable.delegate = self;
        menuTable.dataSource = self;
        menuTable.backgroundColor = [UIColor clearColor];
        menuTable.backgroundView = nil;
        menuTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        menuTable.separatorColor = [UIColor clearColor];
        menuTable.contentInset = UIEdgeInsetsMake(0, 0, 60, 0);
        menuTable.isAccessibilityElement = YES;
        menuTable.accessibilityIdentifier = @"menuTableSlidingMenu";
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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forcePhotosPage) name:PHOTOS_SCREEN_AUTO_TRIGGERED_NOTIFICATION object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playingMusicChanged:) name:MUSIC_CHANGED_NOTIFICATION object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldRemoveMusic) name:MUSIC_SHOULD_BE_REMOVED_NOTIFICATION object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cropyEmptied) name:CROPY_EMPTY_NOTIFICATION object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(favsUpdated) name:FAV_LIST_UPDATED_NOTIFICATION object:nil];

        
    }
    return self;
}

- (void) playingMusicChanged:(NSNotification *) notification {
    NSDictionary *userInfo = notification.userInfo;
    MetaFile *musicFilePlaying = [userInfo objectForKey:CHANGED_MUSIC_OBJ_KEY];
    
    if(audioFooterView) {
        [audioFooterView removeFromSuperview];
        audioFooterView = nil;
    }
    
    self.audioFooterView = [[AudioMenuFooterView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 60, self.frame.size.width, 60) withFile:musicFilePlaying];
    audioFooterView.delegate = self;
    [self addSubview:audioFooterView];
}

- (void) shouldRemoveMusic {
    if(audioFooterView) {
        [audioFooterView removeFromSuperview];
        audioFooterView = nil;
    }
}

- (void) updateMenuByLoginStatus {
    if(APPDELEGATE.session.user) {
        sectionMetaArray = [AppUtil readMenuItemsForLoggedIn];
    } else {
        //simdilik logout user icin giris olmadigindan menu yok
        sectionMetaArray = [AppUtil readMenuItemsForLoggedIn];
    }
}

- (void) cropyEmptied {
    sectionMetaArray = [AppUtil readMenuItemsForLoggedIn];
    tableUpdateCounter ++;
    [menuTable reloadData];
}
    
- (void) favsUpdated {
    sectionMetaArray = [AppUtil readMenuItemsForLoggedIn];
    tableUpdateCounter ++;
    [menuTable reloadData];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return [sectionMetaArray count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    MetaMenu *item = [sectionMetaArray objectAtIndex:section];

//    if(item.menuType == MenuTypeFiles || item.menuType == MenuTypeLogout)
    
//    if(item.menuType == MenuTypeFiles || ([APPDELEGATE.session.user.countryCode isEqualToString:@"90"] && item.menuType == MenuTypeCellograph) || (![APPDELEGATE.session.user.countryCode isEqualToString:@"90"] && item.menuType == MenuTypeHelp)) {
//        return 21;
//    }
    
    if(item.menuType == MenuTypeFiles || item.menuType == MenuTypeCreateStory) {
        return 21;
    }
    return 0;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    MetaMenu *item = [sectionMetaArray objectAtIndex:section];

//    if(item.menuType == MenuTypeFiles || item.menuType == MenuTypeLogout)
    
//    if(item.menuType == MenuTypeFiles || ([APPDELEGATE.session.user.countryCode isEqualToString:@"90"] && item.menuType == MenuTypeCellograph) || (![APPDELEGATE.session.user.countryCode isEqualToString:@"90"] && item.menuType == MenuTypeHelp)) {
//        UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 21)];
//        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(12, 10, separatorView.frame.size.width-24, 1)];
//        separator.backgroundColor = [Util UIColorForHexColor:@"2c3037"];
//        [separatorView addSubview:separator];
//        return separatorView;
//    }
    
    if(item.menuType == MenuTypeFiles || item.menuType == MenuTypeCreateStory) {
        UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 21)];
//        separatorView.backgroundColor = [UIColor yellowColor];
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(12, 20, separatorView.frame.size.width-24, 1)];
        separator.backgroundColor = [Util UIColorForHexColor:@"2c3037"];
        [separatorView addSubview:separator];
        return separatorView;
    }
    return nil;
}
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0)
        return 50;
    else if(indexPath.section == 1)
        return 40;
    else
        return 40;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
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
    NSString *cellIdentifier = [NSString stringWithFormat:@"MenuCell%d-%d-%d", (int)indexPath.section, (int)indexPath.row, tableUpdateCounter];
    
    MetaMenu *metaData = [sectionMetaArray objectAtIndex:indexPath.section];
    
    if(APPDELEGATE.session.user) {
        if(indexPath.section == 0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if(!cell) {
                cell = [[MenuProfileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withMetaData:metaData];
            }
            return cell;
        }
//        else if(indexPath.section == 1) {
//            MenuSearchCell *cell = [[MenuSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withMetaData:metaData];
//            return cell;
//        }
        else {
            MenuCell *cell = [[MenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withMetaData:metaData isCollapsible:NO isCollapsed:YES];
            return cell;
        }
    } else {
        if(indexPath.section == 0) {
            MenuProfileCell *cell = [[MenuProfileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withMetaData:metaData];
            return cell;
        }
//        else if(indexPath.section == 1) {
//            MenuSearchCell *cell = [[MenuSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier withMetaData:metaData];
//            return cell;
//        }
        else {
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
        case MenuTypePromo:
            [delegate didTriggerPromotions];
            break;
        case MenuTypeDropbox:
            [delegate didTriggerDropbox];
            break;
        case MenuTypeContactSync:
            [delegate didTriggerContactSync];
            break;
        case MenuTypeLogin:
            [delegate didTriggerLogin];
            break;
        case MenuTypeCropAndShare:
            [delegate didTriggerCropAndShare];
            break;
        case MenuTypeCellograph:
            [delegate didTriggerCellograph];
            break;
        case MenuTypeCreateStory:
            [cell setSelected:NO animated:YES];
            [delegate didTriggerCreateStory];
            break;
        case MenuTypeReachUs:
            [delegate didTriggerReachUs];
            break;
        case MenuTypeHelp:
            [delegate didTriggerHelp];
            break;
        case MenuTypeLogout:
            [delegate didTriggerLogout];
            break;
        default:
            break;
    }
    if(sectionType != MenuTypeCreateStory) {[self close];}
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
    tableUpdateCounter ++;
    [menuTable reloadData];
    [delegate didTriggerHome];
}

- (void) silentLoginSuccessful {
    [self updateMenuByLoginStatus];
    tableUpdateCounter ++;
    [menuTable reloadData];
}

- (void) logoutSuccessful {
    [self updateMenuByLoginStatus];
    tableUpdateCounter ++;
    [menuTable reloadData];
}

- (void) forceHomePage {
    [menuTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] animated:NO scrollPosition:UITableViewScrollPositionNone];
    [delegate didTriggerHome];
}

- (void) forcePhotosPage {
    [menuTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:5] animated:NO scrollPosition:UITableViewScrollPositionNone];
    [delegate didTriggerPhotos];
}

#pragma mark AudioFooterDelegate methods

- (void) audioMenuFooterWasClicked {
    [delegate didTriggerCurrentMusic];
    [self close];
}

@end
