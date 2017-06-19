//
//  SuggestDao.h
//  Depo
//
//  Created by Seyma Tanoglu on 21/12/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "BaseDao.h"

@interface SuggestDao : BaseDao 

- (void) requestSuggestion:(NSString*) key ;

@end
