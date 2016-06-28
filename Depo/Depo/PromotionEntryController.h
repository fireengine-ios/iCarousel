//
//  PromotionEntryController.h
//  Depo
//
//  Created by Mahir Tarlan on 28/06/16.
//  Copyright © 2016 com.igones. All rights reserved.
//

#import "MyViewController.h"
#import "GeneralTextField.h"
#import "PromoCodeActivateDao.h"

@interface PromotionEntryController : MyViewController

@property (nonatomic, strong) GeneralTextField *promoField;
@property (nonatomic, strong) PromoCodeActivateDao *activateDao;
@property (nonatomic, strong) UIScrollView *mainScroll;

@end
