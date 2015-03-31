//
//  SettingsViewController.m
//  Synergy
//
//  Created by David Grunzweig on 3/2/15.
//  Copyright (c) 2015 David Grunzweig. All rights reserved.
//

#import "SettingsViewController.h"
#import <SCUI.h>
#import <SCAPI.h>
#import <Firebase/Firebase.h>


@interface SettingsViewController ()

@end

@implementation SettingsViewController

@synthesize scrollView, activeField, meData;

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height += kbSize.height;
    if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
        [self.scrollView scrollRectToVisible:activeField.frame animated:YES];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [activeField resignFirstResponder];
    activeField = nil;
    
}


// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // register for keyboard notifications
    [self registerForKeyboardNotifications];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *locVal = (NSString*)[defaults objectForKey:@"location"];
    _location.text = locVal;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

-(IBAction)login:(id)sender
{
    SCLoginViewControllerCompletionHandler handler = ^(NSError *error) {
        if (SC_CANCELED(error)) {
            NSLog(@"Canceled!");
        } else if (error) {
            NSLog(@"Error: %@", [error localizedDescription]);
        } else {
            NSLog(@"Done!");
            _loggedOn = YES;
        }
    };
    
    [SCSoundCloud requestAccessWithPreparedAuthorizationURLHandler:^(NSURL *preparedURL) {
        SCLoginViewController *loginViewController;
        
        loginViewController = [SCLoginViewController
                               loginViewControllerWithPreparedURL:preparedURL
                               completionHandler:handler];
        [self presentModalViewController:loginViewController animated:YES];
    }];
    
    
}
-(IBAction)updateLocation:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:_location.text forKey:@"location"];
    [defaults synchronize];
    
}

-(IBAction)back:(id)sender
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    bool isMusician = [defaults boolForKey:@"isMusician"];
    
    if (!isMusician && _loggedOn){
    SCAccount *account = [SCSoundCloud account];
    
    SCRequestResponseHandler gethandler;
    gethandler = ^(NSURLResponse *response, NSData *data, NSError *error) {
        NSError *jsonError = nil;
        NSJSONSerialization *jsonResponse = [NSJSONSerialization
                                             JSONObjectWithData:data
                                             options:0
                                             error:&jsonError];
        if (!jsonError && [jsonResponse isKindOfClass:[NSDictionary class]]) {
            meData = (NSDictionary*)jsonResponse;
           // NSLog(@"%@", meData);
                // Create a reference to a Firebase location
                Firebase *myRootRef = [[Firebase alloc] initWithUrl:@"https://synergymusic256b.firebaseio.com/"];
                Firebase *usersRef = [myRootRef childByAppendingPath: @"users"];
                // Write data to Firebase
                NSDictionary *currentUser = @{
                                                    @"user_id" : [meData objectForKey:@"id"],
                                                    @"username" : [meData objectForKey:@"username"],
                                                    @"city": [meData objectForKey:@"city"]
                                                    };
 
            Firebase *post1Ref = [usersRef childByAutoId];
            [post1Ref setValue: currentUser];

            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:(NSString*)[meData objectForKey:@"city"] forKey:@"location"];
            [defaults setObject:(NSString*)[meData objectForKey:@"id" ] forKey:@"id"];
            [defaults setObject:(NSString*)[meData objectForKey:@"username" ] forKey:@"username"];
            
            [defaults synchronize];

        } else {
            NSLog(@"%@", jsonError.localizedDescription);
        }
    };
    
    NSString* resourceURL = @"https://api.soundcloud.com/me.json";
    
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:resourceURL]
             usingParameters:nil
                 withAccount:account
      sendingProgressHandler:nil
             responseHandler:gethandler];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:true forKey:@"isMusician"];
        [defaults synchronize];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
