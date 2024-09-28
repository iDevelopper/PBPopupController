//
//  UIView+PBPopupSupportPrivate.m
//  PBPopupController
//
//  Created by Patrick BODET on 30/08/2023.
//  Copyright © 2018-2024 Patrick BODET. All rights reserved.
//

#import "UIView+PBPopupSupportPrivate.h"
#import "NSObject+PBPopupSupportPrivate.h"
@import ObjectiveC;
#if TARGET_OS_MACCATALYST
@import AppKit;
#endif

// https://www.base64encode.org/
//backdropGroupName
//static NSString* _bGN = @"YmFja2Ryb3BHcm91cE5hbWU=";
//groupName
static NSString* _gN = @"Z3JvdXBOYW1l";
//_UINavigationBarVisualProvider
static NSString* _UINBVP = @"X1VJTmF2aWdhdGlvbkJhclZpc3VhbFByb3ZpZGVy";
//_UINavigationBarVisualProviderLegacyIOS
static NSString* _UINBVPLI = @"X1VJTmF2aWdhdGlvbkJhclZpc3VhbFByb3ZpZGVyTGVnYWN5SU9T";
//_UINavigationBarVisualProviderModernIOS
static NSString* _UINBVPMI = @"X1VJTmF2aWdhdGlvbkJhclZpc3VhbFByb3ZpZGVyTW9kZXJuSU9T";
//_UIToolbarVisualProviderModernIOS
static NSString* _UITBVPMI = @"X1VJVG9vbGJhclZpc3VhbFByb3ZpZGVyTW9kZXJuSU9T";

//updateBackgroundGroupName
static NSString* _uBGN = @"dXBkYXRlQmFja2dyb3VuZEdyb3VwTmFtZQ==";

@implementation UIView (PBPopupSupportPrivate)

+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		//updateBackgroundGroupName
		SEL updateBackgroundGroupNameSEL = NSSelectorFromString(_PBPopupDecodeBase64String(_uBGN));
		
		id (^trampoline)(void (*)(id, SEL)) = ^ id (void (*orig)(id, SEL)){
			return ^ (id _self) {
				orig(_self, updateBackgroundGroupNameSEL);
				
				static NSString* key = nil;
				static dispatch_once_t onceToken;
				dispatch_once(&onceToken, ^{
                    //backdropGroupName
                    //key = _PBPopupDecodeBase64String(_bGN);
                    //groupName
                    key = _PBPopupDecodeBase64String(_gN);
				});
				
                //NSString* groupName = [_self valueForKey:key];
                id backgroundView = [_self valueForKey:@"backgroundView"];
                
                NSString* groupName = [backgroundView valueForKey:key];
				if(groupName != nil && [groupName hasSuffix:@"🤡"] == NO)
				{
                    //[_self setValue:[NSString stringWithFormat:@"%@🤡", groupName] forKey:key];
                    [backgroundView setValue:[NSString stringWithFormat:@"%@🤡", groupName] forKey:key];
				}
			};
		};
		
		{
			//_UINavigationBarVisualProvider
			Class cls = NSClassFromString(_PBPopupDecodeBase64String(_UINBVP));
			Method m = class_getInstanceMethod(cls, updateBackgroundGroupNameSEL);
			void (*orig)(id, SEL) = (void*)method_getImplementation(m);
			method_setImplementation(m, imp_implementationWithBlock(trampoline(orig)));
		}
		
		{
			//_UINavigationBarVisualProviderLegacyIOS
			Class cls = NSClassFromString(_PBPopupDecodeBase64String(_UINBVPLI));
			Method m = class_getInstanceMethod(cls, updateBackgroundGroupNameSEL);
			void (*orig)(id, SEL) = (void*)method_getImplementation(m);
			method_setImplementation(m, imp_implementationWithBlock(trampoline(orig)));
		}
		
		{
			//_UINavigationBarVisualProviderModernIOS
			Class cls = NSClassFromString(_PBPopupDecodeBase64String(_UINBVPMI));
			Method m = class_getInstanceMethod(cls, updateBackgroundGroupNameSEL);
			void (*orig)(id, SEL) = (void*)method_getImplementation(m);
			method_setImplementation(m, imp_implementationWithBlock(trampoline(orig)));
		}
        
        /*
        {
            //_UIToolbarVisualProviderModernIOS
            Class cls = NSClassFromString(_PBPopupDecodeBase64String(_UITBVPMI));
            Method m = class_getInstanceMethod(cls, updateBackgroundGroupNameSEL);
            void (*orig)(id, SEL) = (void*)method_getImplementation(m);
            method_setImplementation(m, imp_implementationWithBlock(trampoline(orig)));
        }
        */
});
}

@end

@implementation UITabBar (LNPopupSupportPrivate)

- (BOOL)_ignoringLayoutDuringTransition
{
    return [objc_getAssociatedObject(self, PBPopupIgnoringLayoutDuringTransition) boolValue];
}

- (void)_setIgnoringLayoutDuringTransition:(BOOL)ignoringLayoutDuringTransition
{
    objc_setAssociatedObject(self, PBPopupIgnoringLayoutDuringTransition, @(ignoringLayoutDuringTransition), OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)_ignoringNastedFrameDuringTransition
{
    return [objc_getAssociatedObject(self, PBPopupIgnoringNastedFrameDuringTransition) boolValue];
}

- (void)_setIgnoringNastedFrameDuringTransition:(BOOL)ignoringNastedFrameDuringTransition
{
    objc_setAssociatedObject(self, PBPopupIgnoringNastedFrameDuringTransition, @(ignoringNastedFrameDuringTransition), OBJC_ASSOCIATION_RETAIN);
}

+ (void)load
{
    @autoreleasepool
    {
        Method origMethod = class_getInstanceMethod(self, @selector(setFrame:));
        Method swizzledMethod = class_getInstanceMethod(self, @selector(pb_setFrame:));
        method_exchangeImplementations(origMethod, swizzledMethod);
    }
}

- (void)pb_setFrame:(CGRect)frame
{
    if(self._ignoringNastedFrameDuringTransition && frame.origin.y < self.superview.bounds.size.height)
    {
        return;
    }
    if(self._ignoringLayoutDuringTransition == NO)
    {
        [self pb_setFrame:frame];
    }
}

@end

