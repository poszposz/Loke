//
//  LockViewController.h
//  Lockify
//
//  Created by Jan Posz on 12.06.2015.
//  Copyright (c) 2015 lockify. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface LockViewController : BaseViewController

@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *roundedButtons;
@property (nonatomic, assign) IBOutlet UILabel *doneLabel;
@property (nonatomic, assign) IBOutlet UILabel *connectingLabel;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *spinner;

@end
