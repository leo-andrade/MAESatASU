//
//  ViewController.h
//  MAESatASU
//
//  Created by Leonardo Andrade Osorio on 3/12/15.
//  Copyright (c) 2015 Leonardo Andrade Osorio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GooglePlus/GooglePlus.h>

@interface ViewController : UIViewController <GPPSignInDelegate>

@property (retain, nonatomic) IBOutlet GPPSignInButton *signInButton; //declare the sign-in button
- (IBAction)signOutPressed:(id)sender;
- (IBAction)getInfo:(id)sender;

@end

@class GPPSignInButton; //forward declare GPPSignInButton
