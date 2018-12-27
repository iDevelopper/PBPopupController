//
//  This is free and unencumbered software released into the public domain.
//
//  Anyone is free to copy, modify, publish, use, compile, sell, or
//  distribute this software, either in source code form or as a compiled
//  binary, for any purpose, commercial or non-commercial, and by any
//  means.
//
//  In jurisdictions that recognize copyright laws, the author or authors
//  of this software dedicate any and all copyright interest in the
//  software to the public domain. We make this dedication for the benefit
//  of the public at large and to the detriment of our heirs and
//  successors. We intend this dedication to be an overt act of
//  relinquishment in perpetuity of all present and future rights to this
//  software under copyright law.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
//  OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
//  ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//
//  For more information, please refer to <http://unlicense.org/>
//

#import "PBPopupController.h"
#import <PBPopupController/PBPopupController-Swift.h>

@implementation UIViewController (Insets)
/*
- (UIEdgeInsets)insetsForView:(UIView*)view
{
	UIViewController* viewController = self;
	
	//	Until root, navigation or tabBar controller
	if(![viewController isKindOfClass:[UINavigationController class]] &&
	   ![viewController isKindOfClass:[UITabBarController class]])
	{
		while(viewController.parentViewController != nil &&
			  ![viewController.parentViewController isKindOfClass:[UINavigationController class]] &&
			  ![viewController.parentViewController isKindOfClass:[UITabBarController class]])
			viewController = viewController.parentViewController;
	}
	
	const CGRect selfViewFrame = self.view.frame;
	
	const CGRect convertedFrame = [viewController.view convertRect:view.bounds fromView:view];
	
	const CGFloat topLayoutGuideLength = (([viewController respondsToSelector:@selector(topLayoutGuide)]) ? [viewController.topLayoutGuide length] : 0);
	const CGFloat bottomLayoutGuideLength = (([viewController respondsToSelector:@selector(bottomLayoutGuide)]) ? [viewController.bottomLayoutGuide length] : 0);
	
	const UIEdgeInsets rawInsets = UIEdgeInsetsMake(topLayoutGuideLength - CGRectGetMinY(convertedFrame), 0, bottomLayoutGuideLength, 0);
	
	return UIEdgeInsetsMake(MAX(0, rawInsets.top) + ABS(MIN(0, CGRectGetMinY(selfViewFrame) + CGRectGetMinY(convertedFrame))),
							MAX(0, rawInsets.left),
							MAX(0, rawInsets.bottom) - ((bottomLayoutGuideLength <= 0) ? 0 : MIN(bottomLayoutGuideLength, selfViewFrame.size.height - CGRectGetMaxY(convertedFrame))),
							MAX(0, rawInsets.right));
}
*/
@end
