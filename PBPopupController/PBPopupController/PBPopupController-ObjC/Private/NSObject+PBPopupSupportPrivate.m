//
//  ObjC+PBPopupSupportPrivate.m
//  PBPopupController
//
//  Created by Patrick BODET on 02/09/2024.
//  Copyright © 2024 Patrick BODET. All rights reserved.
//

#import "NSObject+PBPopupSupportPrivate.h"
@import ObjectiveC;

@implementation NSObject (PBPopupSupportPrivate)

//durationForTransition:
static NSString* const dFTBase64 = @"ZHVyYXRpb25Gb3JUcmFuc2l0aW9uOg==";
//_transitionCoordinator
static NSString* const _tCBase64 = @"X3RyYW5zaXRpb25Db29yZGluYXRvcg==";


NSString* _PBPopupDecodeBase64String(NSString* base64String)
{
    return [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:base64String options:0] encoding:NSUTF8StringEncoding];
}

NSTimeInterval __pb_durationForTransition(UIViewController* vc, NSUInteger transition)
{
    //durationForTransition:
    static SEL dFT = nil;
    static NSTimeInterval (*specialized_objc_msgSend)(id, SEL, NSUInteger) = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //durationForTransition:
        dFT = NSSelectorFromString(_PBPopupDecodeBase64String(dFTBase64));
        specialized_objc_msgSend = (void*)objc_msgSend;
    });
    
    return specialized_objc_msgSend(vc, dFT, transition);
}

id<UIViewControllerTransitionCoordinator> __pb_transitionCoordinator(UIViewController* vc, NSUInteger transition)
{
    //_transitionCoordinator
    static SEL tC = nil;
    static id<UIViewControllerTransitionCoordinator> (*specialized_objc_msgSend)(id, SEL) = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //durationForTransition:
        tC = NSSelectorFromString(_PBPopupDecodeBase64String(_tCBase64));
        specialized_objc_msgSend = (void*)objc_msgSend;
    });
    
    return specialized_objc_msgSend(vc, tC);
}

@end

@implementation __LNFakeContext @end
