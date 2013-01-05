//
//  AIDoorHangerWrapper.h
//  AIDoorHanger
//
//  Created by CocoaToucher on 1/4/13.
//  Copyright (c) 2013 CocoaToucher. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AIDoorHangerWrapper : NSObject

- (id)initWithDoorHangerView:(UIView *)doorHangerView;

@property(nonatomic, strong, readonly) UIView *doorHangerView;

@end
