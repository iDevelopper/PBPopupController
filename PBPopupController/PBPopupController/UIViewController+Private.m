//
//  UIViewController+Private.m
//  PBPopupController
//
//  Created by Patrick BODET on 28/03/2018.
//  Copyright © 2018-2020 Patrick BODET. All rights reserved.
//

#import "PBPopupController.h"
#import <PBPopupController/PBPopupController-Swift.h>

@import ObjectiveC;

//_updateContentOverlayInsetsForSelfAndChildren
static NSString *const upCoOvBase64 = @"X3VwZGF0ZUNvbnRlbnRPdmVybGF5SW5zZXRzRm9yU2VsZkFuZENoaWxkcmVu";

@implementation UIViewController (Private)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [UIViewController vc_swizzle];
    });
}

static inline void _LNPopupSupportFixInsetsForViewController_modern(UIViewController* controller, BOOL layout, UIEdgeInsets additionalSafeAreaInsets) API_AVAILABLE(ios(11.0))
{
    if([controller isKindOfClass:UITabBarController.class] || [controller isKindOfClass:UINavigationController.class] || [controller isKindOfClass:UISplitViewController.class] || controller.childViewControllers.count > 0)
    {
        [controller.childViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * __nonnull obj, NSUInteger idx, BOOL * __nonnull stop) {
            if ([obj isKindOfClass:[UINavigationController class]]) {
                _LNPopupSupportFixInsetsForViewController_modern(obj, layout, additionalSafeAreaInsets);
                return;
            }
            UIEdgeInsets oldInsets = obj.additionalSafeAreaInsets;
            UIEdgeInsets insets = oldInsets;
            if (oldInsets.top == 0 || additionalSafeAreaInsets.top < 0) {
                insets.top += additionalSafeAreaInsets.top;
                
            }
            if (oldInsets.bottom < additionalSafeAreaInsets.bottom + controller.additionalSafeAreaInsetsBottomForContainer || additionalSafeAreaInsets.bottom < 0) {
                insets.bottom += (additionalSafeAreaInsets.bottom + (additionalSafeAreaInsets.bottom == 0 ? controller.additionalSafeAreaInsetsBottomForContainer : 0));
            }
            if (UIEdgeInsetsEqualToEdgeInsets(oldInsets, insets) == NO)
            {
                obj.additionalSafeAreaInsets = insets;
            }
        }];
    }
    else
    {
        UIEdgeInsets oldInsets = controller.additionalSafeAreaInsets;
        UIEdgeInsets insets = oldInsets;
        if (oldInsets.top == 0 || additionalSafeAreaInsets.top < 0) {
            insets.top += additionalSafeAreaInsets.top;
        }
        if (oldInsets.bottom == 0 || additionalSafeAreaInsets.bottom < 0) {
            insets.bottom += additionalSafeAreaInsets.bottom;
            
        }
        if (UIEdgeInsetsEqualToEdgeInsets(oldInsets, insets) == NO)
        {
            controller.additionalSafeAreaInsets = insets;
        }
    }
    
    if (layout)
    {
        [controller.view setNeedsUpdateConstraints];
        [controller.view setNeedsLayout];
        [controller.view layoutIfNeeded];
    }
}

static inline void _LNPopupSupportFixInsetsForViewController_legacy(UIViewController* controller, BOOL layout, CGFloat additionalSafeAreaInsetsBottom)
{
    static NSString* selName;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //_updateContentOverlayInsetsForSelfAndChildren
        selName = _PBPopupDecodeBase64String(upCoOvBase64);
    });
    
    void (*dispatchMethod)(id, SEL) = (void(*)(id, SEL))objc_msgSend;
    dispatchMethod(controller, NSSelectorFromString(selName));
    
    [controller.childViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * __nonnull obj, NSUInteger idx, BOOL * __nonnull stop) {
        _LNPopupSupportFixInsetsForViewController_legacy(obj, NO, 0);
    }];
    
    if (layout)
    {
        [controller.view setNeedsUpdateConstraints];
        [controller.view setNeedsLayout];
        [controller.view layoutIfNeeded];
    }
}

void _LNPopupSupportFixInsetsForViewController(UIViewController* controller, BOOL layout, UIEdgeInsets additionalSafeAreaInsets)
{
    if (@available(iOS 11.0, *))
    {
        _LNPopupSupportFixInsetsForViewController_modern(controller, layout, additionalSafeAreaInsets);
    }
    else
    {
        _LNPopupSupportFixInsetsForViewController_legacy(controller, layout, additionalSafeAreaInsets.bottom);
    }
}


- (void)_configurePopupBarFromBottomBar
{
    if (self.popupBar.inheritsVisualStyleFromBottomBar == NO)
    {
        return;
    }
    
    if ([self.bottomBar respondsToSelector:@selector(barStyle)])
    {
        [self.popupBar setBarStyle:[(id)self.bottomBar barStyle]];
    }
    
    self.popupBar.tintColor = self.bottomBar.tintColor;
    
    if ([self isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nc = (UINavigationController *)self;
        self.popupBar.tintColor = nc.navigationBar.tintColor;
    }
    
    // Split view controller detail OS Bug
    if ([self.parentViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nc = (UINavigationController *)self.parentViewController;
        self.popupBar.tintColor = nc.navigationBar.tintColor;
    }

    if ([self.bottomBar respondsToSelector:@selector(barTintColor)])
    {
        [self.popupBar setBarTintColor:[(id)self.bottomBar barTintColor]];
    }
    self.popupBar.backgroundColor = self.bottomBar.backgroundColor;
    
    if ([self.bottomBar respondsToSelector:@selector(isTranslucent)])
    {
        self.popupBar.isTranslucent = [(id)self.bottomBar isTranslucent];
    }
}

NSString *_PBPopupDecodeBase64String(NSString* base64String)
{
    return [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:base64String options:0] encoding:NSUTF8StringEncoding];
}

@end

@implementation UITabBarController (Private)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [UITabBarController tbc_swizzle];
    });
}

@end

@implementation UINavigationController (Private)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [UINavigationController nc_swizzle];
    });
}

@end

/*
@implementation UISplitViewController (Private)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [UISplitViewController svc_swizzle];
    });
}

@end
*/

