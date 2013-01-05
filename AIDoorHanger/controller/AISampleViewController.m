//
//  AISampleViewController.m
//  AIDoorHanger
//
//  Created by CocoaToucher on 1/4/13.
//  Copyright (c) 2013 CocoaToucher. All rights reserved.
//

#import "AISampleViewController.h"
#import "AIDoorHangerWrapper.h"
#import <QuartzCore/QuartzCore.h>


@interface AISampleViewController ()

@property(nonatomic, strong) AIDoorHangerWrapper *doorHangerWrapper;

@end

@implementation AISampleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
#if !(__has_feature(objc_arc))
	[_doorHangerWrapper release];
	_doorHangerWrapper = nil;
	
	[super dealloc];
#endif
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	UIImageView *hangerView = [[UIImageView alloc] initWithFrame:CGRectMake(floorf((self.view.bounds.size.width - 160.0f) / 2.0f), floorf(self.view.bounds.size.height / 2.0f), 160.0f, 82.0f)];
	hangerView.image = [UIImage imageNamed:@"hanger.png"];
	hangerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
	[self.view addSubview:hangerView];
	
	UIView *pinView = [[UIView alloc] initWithFrame:CGRectZero];
	pinView.backgroundColor = [UIColor brownColor];
	pinView.layer.cornerRadius = 10.0f;
	[self.view addSubview:pinView];
	CGRect pinRect = pinView.frame;
	pinRect.size.width = 20.0f;
	pinRect.size.height = 20.0f;
	pinRect.origin.x = floorf((self.view.bounds.size.width - pinRect.size.width) / 2.0f);
	pinRect.origin.y = hangerView.frame.origin.y - floorf(pinRect.size.height / 2.0f);
	pinView.frame = pinRect;
	
	AIDoorHangerWrapper *tWrapper = [[AIDoorHangerWrapper alloc] initWithDoorHangerView:hangerView];
	self.doorHangerWrapper = tWrapper;
#if !(__has_feature(objc_arc))
	[hangerView release];
	[tWrapper release];
	[pinView release];
#endif
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
