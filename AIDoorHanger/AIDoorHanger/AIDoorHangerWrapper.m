//
//  AIDoorHangerWrapper.m
//  AIDoorHanger
//
//  Created by CocoaToucher on 1/4/13.
//  Copyright (c) 2013 CocoaToucher. All rights reserved.
//

#import "AIDoorHangerWrapper.h"
#import <CoreMotion/CoreMotion.h>
#import <QuartzCore/QuartzCore.h>

CGFloat RadiansToDegrees(CGFloat radians) {return radians * 180 / M_PI;}
CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;}
NSNumber* DegreesToNumber(CGFloat degrees) {return [NSNumber numberWithFloat:DegreesToRadians(degrees)];}

@interface AIDoorHangerWrapper ()

@property(nonatomic, strong) CMMotionManager *motionManager;
@property(nonatomic, strong) NSOperationQueue *opQueue;
@property(nonatomic, copy) CMAccelerometerHandler accHandler;
@property(nonatomic) CMAcceleration lastAcceleration;
@property(nonatomic) NSTimeInterval lastTimestamp;
@property(nonatomic) BOOL lastClockwise;

@end

@implementation AIDoorHangerWrapper

- (id)initWithDoorHangerView:(UIView *)doorHangerView {
	self = [super init];
	if (self) {
#if !(__has_feature(objc_arc))
		_doorHangerView = [doorHangerView retain];
#else
		_doorHangerView = doorHangerView;
#endif
		_doorHangerView.layer.anchorPoint = CGPointMake(0.5, 0.0);
		
		_motionManager = [[CMMotionManager alloc] init];
		_motionManager.accelerometerUpdateInterval = 0.3;
		
		_opQueue = [[NSOperationQueue alloc] init];
		
		_lastTimestamp = -1.0;
		
		if (_motionManager.isAccelerometerAvailable &&
			!_motionManager.isAccelerometerActive) {
			
			__block __unsafe_unretained AIDoorHangerWrapper *blockSelf = self;
			
			self.accHandler = ^(CMAccelerometerData *accelerometerData, NSError *error) {
				
				[blockSelf performSelectorOnMainThread:@selector(motionUpdate:)
											withObject:accelerometerData
										 waitUntilDone:NO];
				
			};
			
			[self.motionManager startAccelerometerUpdatesToQueue:self.opQueue
													 withHandler:self.accHandler];
			[self motionUpdate:self.motionManager.accelerometerData];
		}
	}
	return self;
}

- (void)dealloc {
	if (_motionManager.isAccelerometerAvailable ||
		_motionManager.isAccelerometerActive) {
		[_motionManager stopAccelerometerUpdates];
	}
#if !(__has_feature(objc_arc))
	[_doorHangerView release];
	_doorHangerView = nil;
	[_motionManager release];
	_motionManager = nil;
	[_opQueue release];
	_opQueue = nil;
	[_accHandler release];
	_accHandler = nil;
	
	[super dealloc];
#endif
}

- (void)addAcceleration:(CMAcceleration)accel withTimestamp:(NSTimeInterval)timestamp
{
	if (self.lastTimestamp >= 0.0) {
		NSTimeInterval dt = timestamp - self.lastTimestamp;
		
		double RC = 1.0 / 20.0;
		
		double alpha = dt / (dt + RC);
		
		CMAcceleration acc = self.lastAcceleration;
		
		acc.x = accel.x * alpha + acc.x * (1.0 - alpha);
		acc.y = accel.y * alpha + acc.y * (1.0 - alpha);
		acc.z = accel.z * alpha + acc.z * (1.0 - alpha);
		
		self.lastAcceleration = acc;
	}
	self.lastTimestamp = timestamp;
}

- (CGFloat)currentAngle {
	CATransform3D currentTransform = [(CALayer *)[_doorHangerView.layer presentationLayer] transform];
	CGFloat currentAngle = RadiansToDegrees(atan2f(currentTransform.m12, currentTransform.m11));
	if (currentAngle < 0.0f)
		currentAngle += 360.0f;
	return currentAngle;
}

- (void)motionUpdate:(CMAccelerometerData *)motionData {
	
	if (motionData.timestamp - self.lastTimestamp < 0.3) {
		return;
	}
	
	NSTimeInterval prevTimeStamp = self.lastTimestamp;
	
	[self addAcceleration:motionData.acceleration withTimestamp:motionData.timestamp];
	
	if (prevTimeStamp == -1)
		return;
	
	CGFloat currentAngle = [self currentAngle];
	
	CGFloat angleAtRest = RadiansToDegrees(atan2(self.lastAcceleration.y, self.lastAcceleration.x));
	angleAtRest = -angleAtRest;
	angleAtRest -= 90.0f;
	if (angleAtRest >= 0.0f && angleAtRest <= 90.0f) {
		angleAtRest -= 360.0f;
	}
	angleAtRest += 360.0f;
	
	BOOL clockwise = angleAtRest > currentAngle;
	
	CGFloat currentDistance = fabsf(angleAtRest - currentAngle);
	if (currentDistance > 180.0f) {
		currentDistance = 360.0f - currentDistance;
		
		clockwise = !clockwise;
	}
	
	CGFloat bounceAngle = currentDistance / 2.0f;
	
	self.lastClockwise = clockwise;
	
	[_doorHangerView.layer removeAllAnimations];
	_doorHangerView.layer.transform = [(CALayer *)[_doorHangerView.layer presentationLayer] transform];
	
	CAAnimation *anim = [self springAnimationForKeyPath:@"transform.rotation.z"
										   initialAngle:currentAngle
											angleAtRest:angleAtRest
											bounceAngle:bounceAngle];
	[_doorHangerView.layer addAnimation:anim forKey:@"transform.rotation.z"];
}

- (void)moveFromAngle:(CGFloat *)startAngle toAngle:(CGFloat *)endAngle clockwise:(BOOL)clockwise {
	
	if (clockwise) {
		if (*endAngle < *startAngle) {
			*endAngle += 360.0f;
		}
	} else {
		if (*startAngle < *endAngle) {
			*startAngle += 360.0f;
		}
	}
}

- (CAAnimation*)springAnimationForKeyPath:(NSString*)keyPath
							 initialAngle:(float)initialAngle
							  angleAtRest:(float)angleAtRest
							  bounceAngle:(float)bounceAngle
{
	CAKeyframeAnimation * animation;
	animation = [CAKeyframeAnimation animationWithKeyPath:keyPath];
	animation.removedOnCompletion = NO;
	animation.fillMode = kCAFillModeForwards;
	animation.beginTime = CACurrentMediaTime();
	animation.calculationMode = kCAAnimationCubic;
	animation.cumulative = YES;
	
	NSMutableArray *values = [NSMutableArray array];
	NSMutableArray *timings = [NSMutableArray array];
	
	[self moveFromAngle:&initialAngle toAngle:&angleAtRest clockwise:self.lastClockwise];
	
	[values addObject:DegreesToNumber(initialAngle)];
	[timings addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
	
	CGFloat bounceConstant = 1.0f;
	
	CGFloat lastAngle = initialAngle;
	
	BOOL clockwise = self.lastClockwise;
	
	while (bounceAngle > 1.0f && bounceConstant > 0.0f) {
		
		CGFloat endAngle = angleAtRest + (bounceAngle * ((clockwise) ? 1.0f : -1.0f));
		
		[self moveFromAngle:&lastAngle toAngle:&endAngle clockwise:clockwise];
		
		[values addObject:DegreesToNumber(endAngle)];
		[timings addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
		
		clockwise = !clockwise;
		lastAngle = endAngle;
		
		bounceConstant -= 0.01f;
		bounceAngle *= bounceConstant;
		
		endAngle = angleAtRest + (bounceAngle * ((clockwise) ? 1.0f : -1.0f));
		
		[self moveFromAngle:&lastAngle toAngle:&endAngle clockwise:clockwise];
		
		[values addObject:DegreesToNumber(endAngle)];
		[timings addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
		
		clockwise = !clockwise;
		lastAngle = endAngle;
		
		bounceConstant -= 0.01f;
		bounceAngle *= bounceConstant;
	}
	
	[self moveFromAngle:&lastAngle toAngle:&angleAtRest clockwise:clockwise];
	[values addObject:DegreesToNumber(angleAtRest)];
	
	animation.duration = 8.0;
	animation.values = values;
	
	return animation;
}

@end
