//
//  ObjC+PBPopupSupportPrivate.h
//  PBPopupController
//
//  Created by Patrick BODET on 02/09/2024.
//  Copyright © 2024 Patrick BODET. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (PBPopupSupportPrivate)

NSString* _PBPopupDecodeBase64String(NSString* base64String);
NSTimeInterval __pb_durationForTransition(UIViewController* vc, NSUInteger transition);
id<UIViewControllerTransitionCoordinator> __pb_transitionCoordinator(UIViewController* vc, NSUInteger transition);

@end

@interface __LNFakeContext: NSObject

@property(nonatomic, getter=isCancelled) BOOL cancelled;

@end


NS_ASSUME_NONNULL_END
