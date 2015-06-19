//
//  LockViewController.m
//  Lockify
//
//  Created by Jan Posz on 12.06.2015.
//  Copyright (c) 2015 lockify. All rights reserved.
//

#import "LockViewController.h"

@interface LockViewController ()

@property (nonatomic, strong) NSMutableArray *passwordDigits;

@end

@implementation LockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.passwordDigits = [NSMutableArray new];
    self.doneLabel.alpha = 0;
    for (UIButton *btn in self.roundedButtons) {
        btn.layer.masksToBounds = YES;
        btn.layer.cornerRadius = btn.frame.size.width / 2;
        btn.layer.borderWidth = 1.0f;
        btn.layer.borderColor = [UIColor whiteColor].CGColor;
        [btn addTarget:self action:@selector(digitDidClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self.spinner startAnimating];
    [self setupConnection];
}

- (void)setupConnection {
    
    __weak typeof(self) weakSelf = self;
    [getApp().bluetoothManager connectLockWithCompletionHandler:^(NSError *error) {
        
        self.connectingLabel.hidden = YES;
        [weakSelf.spinner stopAnimating];
        [weakSelf.spinner removeFromSuperview];
        [weakSelf activateButtons:YES];
    }];
}

- (void)digitDidClick:(UIButton *)sender {
    
    [self.passwordDigits addObject:[NSString stringWithFormat:@"0%@", [sender titleForState:UIControlStateNormal]]];
    if (self.passwordDigits.count == 4) {
        [self tryLoginWithPassword:[self.passwordDigits componentsJoinedByString:@""]];
    }
}

- (void)tryLoginWithPassword:(NSString *)pass {
    if (![pass isEqualToString:@"06030104"]) {
        [self.passwordDigits removeAllObjects];
        [self wrongPassword];
        return;
    }
    
    [self rightPassword];
    [getApp().bluetoothManager unlockWithPassword:pass unlockCompletionHandler:^(BOOL success) {
        NSLog(@"Yaay, unlocked");
        [getApp().bluetoothManager writeAnything];
    }];
    [self.passwordDigits removeAllObjects];
}

- (void)rightPassword {
    
    [UIView animateWithDuration:0.5 animations:^{
        self.doneLabel.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:2.0 animations:^{
            self.doneLabel.alpha = 0;
        }];
    }];
}

- (void)wrongPassword {
    [UIView animateWithDuration:0.05 animations:^{
        for (UIButton *btn in self.roundedButtons) {
            CGRect r = btn.frame;
            r.origin.x = r.origin.x - 10;
            btn.frame = r;
        }
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.05 animations:^{
            for (UIButton *btn in self.roundedButtons) {
                CGRect r = btn.frame;
                r.origin.x = r.origin.x + 20;
                btn.frame = r;
            }
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.05 animations:^{
                for (UIButton *btn in self.roundedButtons) {
                    CGRect r = btn.frame;
                    r.origin.x = r.origin.x - 10;
                    btn.frame = r;
                }
            }];
        }];
    }];
}

- (void)activateButtons:(BOOL)activate {
    
    for (UIButton *btn in self.roundedButtons) {
        btn.alpha = activate ? 1.0 : 0.5;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)unlogged {
    [self performSegueWithIdentifier:@"NoSetupSegue" sender:self];
}

@end
