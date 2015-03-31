//
//  SettingsViewController.h
//  Synergy
//
//  Created by David Grunzweig on 3/2/15.
//  Copyright (c) 2015 David Grunzweig. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController <UITextFieldDelegate>

@property IBOutlet UITextField* location;
@property IBOutlet UIScrollView* scrollView;
@property UITextField* activeField;
@property NSDictionary* meData;
@property BOOL loggedOn;

-(IBAction)login:(id)sender;
-(IBAction)updateLocation:(id)sender;

@end
