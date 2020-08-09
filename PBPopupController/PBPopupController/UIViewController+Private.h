//
//  UIViewController+Private.h
//  PBPopupController
//
//  Created by Patrick BODET on 28/03/2018.
//  Copyright © 2018-2020 Patrick BODET. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PBPopupBar;
@class PBPopupController;

@interface UIViewController (Private)

void _LNPopupSupportFixInsetsForViewController(UIViewController* controller, BOOL layout, UIEdgeInsets additionalSafeAreaInsets);

- (void)_configurePopupBarFromBottomBar;

@end
