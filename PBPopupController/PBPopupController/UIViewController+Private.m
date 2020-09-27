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

static const void* LNPopupAdditionalSafeAreaInsets = &LNPopupAdditionalSafeAreaInsets;

@implementation UIViewController (Private)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [UIViewController vc_swizzle];
    });
}

void _PBSetPopupSafeAreaInsets(id self, UIEdgeInsets additionalSafeAreaInsets)
{
    objc_setAssociatedObject(self, LNPopupAdditionalSafeAreaInsets, [NSValue valueWithUIEdgeInsets:additionalSafeAreaInsets], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

UIEdgeInsets _PBPopupSafeAreaInsets(id self)
{
    return [objc_getAssociatedObject(self, LNPopupAdditionalSafeAreaInsets) UIEdgeInsetsValue];
}

static inline void _LNPopupSupportFixInsetsForViewController_modern(UIViewController* controller, BOOL layout, UIEdgeInsets additionalSafeAreaInsets) API_AVAILABLE(ios(11.0))
{
    if([controller isKindOfClass:UITabBarController.class] || [controller isKindOfClass:UINavigationController.class] || (controller.childViewControllers.count > 0 && ![controller isKindOfClass:UISplitViewController.class]))
    {
        [controller.childViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * __nonnull obj, NSUInteger idx, BOOL * __nonnull stop)
         {
            UIEdgeInsets oldInsets = _PBPopupSafeAreaInsets(obj);
            UIEdgeInsets insets = oldInsets;
            if (oldInsets.top != additionalSafeAreaInsets.top) {
                insets.top += additionalSafeAreaInsets.top;
            }
            if (oldInsets.bottom != additionalSafeAreaInsets.bottom) {
                insets.bottom += additionalSafeAreaInsets.bottom;
            }
            if (UIEdgeInsetsEqualToEdgeInsets(oldInsets, insets) == NO)
            {
                obj.additionalSafeAreaInsets = insets;
                _PBSetPopupSafeAreaInsets(controller, insets);
                _PBSetPopupSafeAreaInsets(obj, insets);
            }
        }];
    }
    else
    {
        UIEdgeInsets oldInsets = _PBPopupSafeAreaInsets(controller);
        UIEdgeInsets insets = oldInsets;
        if (oldInsets.top != additionalSafeAreaInsets.top) {
            insets.top += additionalSafeAreaInsets.top;
        }
        if (oldInsets.bottom != additionalSafeAreaInsets.bottom) {
            insets.bottom += additionalSafeAreaInsets.bottom;
        }
        if (UIEdgeInsetsEqualToEdgeInsets(oldInsets, insets) == NO)
        {
            controller.additionalSafeAreaInsets = insets;
            _PBSetPopupSafeAreaInsets(controller, insets);
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

- (void)pb_viewDidLayoutSubviews
{
    struct objc_super superInfo = {
        self,
        [UIViewController class]
    };
    void (*super_call)(struct objc_super*, SEL) = (void (*)(struct objc_super*, SEL))objc_msgSendSuper;
    super_call(&superInfo, @selector(viewDidLayoutSubviews));
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

