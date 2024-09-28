//
//  UIView+PBPopupSupportPrivate.h
//  PBPopupController
//
//  Created by Patrick BODET on 30/08/2023.
//  Copyright © 2018-2024 Patrick BODET. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (PBPopupSupportPrivate)

@end

static const void* PBPopupIgnoringLayoutDuringTransition = &PBPopupIgnoringLayoutDuringTransition;
static const void* PBPopupIgnoringNastedFrameDuringTransition = &PBPopupIgnoringNastedFrameDuringTransition;

@interface UITabBar (PBPopupSupportPrivate)

@property (nonatomic, getter=_ignoringLayoutDuringTransition, setter=_setIgnoringLayoutDuringTransition:) BOOL ignoringLayoutDuringTransition;
@property (nonatomic, getter=_ignoringNastedFrameDuringTransition, setter=_setIgnoringNastedFrameDuringTransition:) BOOL ignoringNastedFrameDuringTransition;

@end

NS_ASSUME_NONNULL_END
