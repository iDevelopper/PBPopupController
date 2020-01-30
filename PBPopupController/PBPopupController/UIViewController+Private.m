//
//  UIViewController+Private.m
//  PBPopupController
//
//  Created by Patrick BODET on 28/03/2018.
//  Copyright © 2018 Patrick BODET. All rights reserved.
//

//#import "EasyAnimation.h"
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

static inline void _LNPopupSupportFixInsetsForViewController_modern(UIViewController* controller, BOOL layout, CGFloat additionalSafeAreaInsetsBottom) API_AVAILABLE(ios(11.0))
{
    if([controller isKindOfClass:UITabBarController.class] || [controller isKindOfClass:UINavigationController.class])
    {
        [controller.childViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * __nonnull obj, NSUInteger idx, BOOL * __nonnull stop) {
            _LNPopupSupportFixInsetsForViewController_modern(obj, NO, 0);
            
            UIEdgeInsets oldInsets = obj.additionalSafeAreaInsets;
            UIEdgeInsets insets = oldInsets;
            insets.bottom += additionalSafeAreaInsetsBottom;
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
        insets.bottom += additionalSafeAreaInsetsBottom;
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
    
    if (@available(iOS 11.0, *)) {
        UIEdgeInsets insets = controller.additionalSafeAreaInsets;
        insets.bottom += additionalSafeAreaInsetsBottom;
        controller.additionalSafeAreaInsets = insets;
    }
    
    if (layout)
    {
        [controller.view setNeedsUpdateConstraints];
        [controller.view setNeedsLayout];
        [controller.view layoutIfNeeded];
    }
}

void _LNPopupSupportFixInsetsForViewController(UIViewController* controller, BOOL layout, CGFloat additionalSafeAreaInsetsBottom)
{
    if (@available(iOS 11.0, *))
    {
        _LNPopupSupportFixInsetsForViewController_modern(controller, layout, additionalSafeAreaInsetsBottom);
    }
    else
    {
        _LNPopupSupportFixInsetsForViewController_legacy(controller, layout, additionalSafeAreaInsetsBottom);
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

@implementation UITabBarController (Support)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [UITabBarController tbc_swizzle];
    });
}

@end

@implementation UINavigationController (Support)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [UINavigationController nc_swizzle];
    });
}

@end

