//
//  MixerViewController.m
//  Synergy
//
//  Created by David Grunzweig on 3/28/15.
//  Copyright (c) 2015 David Grunzweig. All rights reserved.
//


#import "MixerViewController.h"
#import <SCAPI.h>
#import <SCUI.h>
#import "TracklistViewController.h"
#import <Firebase/Firebase.h>

@interface MixerViewController ()

@end

@implementation MixerViewController

@synthesize player1, player2, trackListVC, isMusician, location, deck1ArtistURL, deck2ArtistURL, deck1TrackID, deck2TrackID, onlyUsers, localUserIDs, localUserNames;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_loadDeck1 setEnabled:false];
    [_loadDeck2 setEnabled:false];
    [_getInfoDeck1 setEnabled:false];
    [_getInfoDeck2 setEnabled:false];
    [_playDeck1 setEnabled:false];
    [_playDeck2 setEnabled:false];
    [_stopDeck1 setEnabled:false];
    [_stopDeck2 setEnabled:false];
    
    [_spinner setHidden:YES];
    
    
    
    player1 = [AVAudioPlayer alloc];
    player2 = [AVAudioPlayer alloc];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"" forKey:@"deck1TrackTitle"];
    [defaults setObject:@"" forKey:@"deck2TrackTitle"];
    [defaults setObject:@"" forKey:@"deck1ArtistInfo"];
    [defaults setObject:@"" forKey:@"deck2ArtistInfo"];
    [defaults setObject:@"" forKey:@"deck1TrackID"];
    [defaults setObject:@"" forKey:@"deck2TrackID"];
    [defaults synchronize];
    isMusician = (BOOL)[defaults boolForKey:@"isMusician"];
    onlyUsers = false;
    [_usersOnlySwitch setOn:NO];
    
    if (isMusician)
    {
        _myUserName = [defaults objectForKey:@"username"];
        _myUserID = [defaults objectForKey:@"id"];
        _artistName1.text = _myUserName;
        [_turnOffMusicianMode setOn:YES];
    } else {
        [_turnOffMusicianMode setOn:NO];
    }
    
    location = [defaults objectForKey:@"location"];
    if ([location isEqual:@""] || location == nil)
    {
        location = @"Berlin, Germany";
    }
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    
    [self.view addGestureRecognizer:_panGesture];
    
    if (trackListVC  == nil)
        trackListVC = [[TracklistViewController alloc] initWithNibName:@"TracklistViewController" bundle:nil];
    
    localUserNames = [[NSMutableArray alloc] initWithCapacity:10];
    localUserIDs = [[NSMutableArray alloc] initWithCapacity:10];
    Firebase *ref = [[Firebase alloc] initWithUrl: @"https://synergymusic256b.firebaseio.com/users/"];
    [[[ref queryOrderedByChild:@"location"] queryLimitedToLast:10] observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        NSLog(@"%@", snapshot.key);
        
        NSString* userName = snapshot.value[@"username"];
        NSString* userID = snapshot.value[@"user_id"];
        NSString* userLocation = snapshot.value[@"city"];
        
        if ([userLocation isEqualToString:location])
        {
            [localUserIDs addObject:userID];
            [localUserNames addObject:userName];
            NSLog(@"%@ has user_id %@ and is in %@", userName, userID, location);
        }
        
    }];

    
    
    _isDeck1Playing = false;
    _isDeck2Playing = false;
    
    NSString *search = [location stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    [_spinner setHidden:NO];
    [_spinner startAnimating];
    
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.soundcloud.com/users?q=%@&format=json", search]]
             usingParameters:nil
                 withAccount:[SCSoundCloud account]
      sendingProgressHandler:nil
             responseHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                 
                 NSError *jsonError;
                 NSJSONSerialization *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                 
                 if (!jsonError && [jsonResponse isKindOfClass:[NSArray class]]) {
                     
                     _artists = (NSArray *)jsonResponse;
                     NSLog(@"Finished Finding Artists");
                     [_loadDeck1 setEnabled:true];
                     [_loadDeck2 setEnabled:true];
                     [_spinner stopAnimating];
                     [_spinner setHidden:YES];
                 }
                 else {
                     
                     NSLog(@"%@", error.localizedDescription);
                     
                 }
                 
             }];
    
    
    
}

-(void)viewDidAppear:(BOOL)animated
{
    //    [defaults setObject:trackTitle forKey:@"deck2TrackTitle"];
    //    [defaults setInteger:artistInfoURL forKey:@"deck2ArtistInfo"];
    //    [defaults setInteger:trackID forKey:@"deck2TrackID"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString * deck1Title = [defaults objectForKey:@"deck1TrackTitle"];
    NSString * deck2Title = [defaults objectForKey:@"deck2TrackTitle"];
    
    [_track1Title setText:deck1Title];
    [_track2Title setText:deck2Title];
}

-(IBAction)switchCollabMode:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL original = (BOOL)[defaults boolForKey:@"isMusician"];
    if (original)
    {
        isMusician = !isMusician;
    } else
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"You are not logged in!" message:@"You must log into your Soundcloud account in the settings window to access collab mode" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@""          , nil];
        
        [alert show];
        UISwitch* collabSwitch = (UISwitch*)sender;
        [collabSwitch setOn:NO animated:YES];
        
    }
}

-(IBAction)switchUserMode:(id)sender
{
    onlyUsers = !onlyUsers;
}

-(void)handlePanGesture:(UIPanGestureRecognizer*)gesture
{
    CGPoint touchLocation = [gesture locationInView:self.view];
    int height = _faderKnob.bounds.size.height;
    int width = _faderKnob.bounds.size.width;
    int y = _faderKnob.frame.origin.y;
    int left = _leftEdge.frame.origin.x;
    int right = _rightEdge.frame.origin.x;
    if (_isDeck1Playing && _isDeck2Playing){
        if (touchLocation.y < y+height && touchLocation.y > y)
        {
            if (touchLocation.x > left && touchLocation.x <right)
            {
                [_faderKnob setFrame:CGRectMake(touchLocation.x, y, width, height)];
                mMixerValue = (float)(touchLocation.x - left)/(right-left);
                //            printf("%f\n", mMixerValue);
                mMixerValue = mMixerValue < .05? 0: mMixerValue;
                mMixerValue = mMixerValue > .95? 1: mMixerValue;
                [player1 setVolume:(1-mMixerValue)];
                [player2 setVolume:(mMixerValue)];
            }
        }
    }
}

-(void)outputAccelertionData:(CMAcceleration)acceleration
{
    //    float theta = fabs(180.0f/M_PI*atan2(acceleration.z, acceleration.x))-90.0;
    //    theta = theta > 90.0? 90.0: theta;
    //    theta = theta < -90.0? -90.0: theta;
    //    if (_isDeck1Playing || _isDeck2Playing){
    //        if (theta < 0)
    //        {
    //            theta = theta / 180.0f;
    //            float rate = 1 + theta;
    //            printf("%f\n", rate);
    //            [player1 setRate:rate];
    //        } else {
    //            theta = theta / 90.0f;
    //            float rate = 1 + theta;
    //            printf("%f\n", rate);
    //
    //            [player1 setRate:rate];
    //        }
    //    }
}
-(void)outputRotationData:(CMRotationRate)rotation
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- play and stop decks

-(IBAction)playDeck1:(id)sender
{
    if (player1 != nil && !_isDeck1Playing)
    {
        [player1 prepareToPlay];
        [player1 setEnableRate:YES];
        [player1 play];
        
        _isDeck1Playing = true;
    }
}
-(IBAction)playDeck2:(id)sender
{
    if (player2 != nil && !_isDeck2Playing)
    {
        [player2 setEnableRate:YES];
        [player2 prepareToPlay];
        [player2 play];
        _isDeck2Playing = true;
    }
}
-(IBAction)stopDeck1:(id)sender
{
    if (player1 != nil && _isDeck1Playing)
    {
        [player1 stop   ];
        [player1 setEnableRate:NO];
        _isDeck1Playing = false;
        
        
    }
}
-(IBAction)stopDeck2:(id)sender
{
    if (player2 != nil && _isDeck2Playing)
    {
        [player2 stop];
        [player2 setEnableRate:NO];
        _isDeck2Playing = false;
        
    }
}

#pragma mark -- adjust deck speed

- (IBAction)speedDeck1:(UIStepper *)sender {
    double value = [sender value];
    NSNumberFormatter * formatter =  [[NSNumberFormatter alloc] init];
    [formatter setUsesSignificantDigits:YES];
    [formatter setMaximumSignificantDigits:3];
    [formatter setMaximumFractionDigits:2];
    [formatter setRoundingMode:NSNumberFormatterRoundCeiling];
    
    [_speedDeck1Label setText:[NSString stringWithFormat:@"Speed: %@", [formatter stringFromNumber:[NSNumber numberWithDouble:value]]]];
    [player1 setRate:value];
}

- (IBAction)speedDeck2:(UIStepper *)sender {
    double value = [sender value];
    NSNumberFormatter * formatter =  [[NSNumberFormatter alloc] init];
    [formatter setUsesSignificantDigits:YES];
    [formatter setMaximumSignificantDigits:3];
    [formatter setMaximumFractionDigits:2];
    [formatter setRoundingMode:NSNumberFormatterRoundCeiling];
    
    [_speedDeck2Label setText:[NSString stringWithFormat:@"Speed: %@", [formatter stringFromNumber:[NSNumber numberWithDouble:value]]]];
    [player2 setRate:value];
    
}

#pragma mark --Load Decks

-(IBAction)loadDeck1:(id)sender
{
    [_spinner setHidden:NO];
    [_spinner startAnimating];
    [_loadDeck1 setEnabled:NO];
    if (_isDeck1Playing)
    {
        [player1 stop];
    }
    SCAccount *account = [SCSoundCloud account];
    if (account == nil) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Not Logged In"
                              message:@"You must login first"
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    NSString *resourceURL;
    NSString *userName;
    if (!isMusician){
        
        int r = arc4random_uniform([_artists count]);
        NSString *trackCount = (NSString*)[[_artists objectAtIndex:r] objectForKey:@"track_count"];
        while ([trackCount integerValue] == 0)
        {
            r = arc4random_uniform([_artists count]);
            trackCount = (NSString*)[[_artists objectAtIndex:r] objectForKey:@"track_count"];
        }
        NSString *userID = (NSString*)[[_artists objectAtIndex:r] objectForKey:@"id"];
        userName = (NSString*)[[_artists objectAtIndex:r] objectForKey:@"username"];
        NSLog(@"%@", userName);
        NSLog(@"ID: %@, track_count: %@", userID, trackCount);
        deck1ArtistURL = [NSURL URLWithString:(NSString*)[[_artists objectAtIndex:r] objectForKey:@"permalink_url"]];
        
        _artistName1.text = userName;
        resourceURL = [NSString stringWithFormat:@"https://api.soundcloud.com/users/%@/tracks.json", userID];
    } else {
        resourceURL = @"https://api.soundcloud.com/me/tracks.json";
        userName = @"ME";
    }
    
    
    SCRequestResponseHandler handler;
    handler = ^(NSURLResponse *response, NSData *data, NSError *error) {
        NSError *jsonError = nil;
        NSJSONSerialization *jsonResponse = [NSJSONSerialization
                                             JSONObjectWithData:data
                                             options:0
                                             error:&jsonError];
        if (!jsonError && [jsonResponse isKindOfClass:[NSArray class]]) {
            [trackListVC setCurrentDeck:1];
            [trackListVC setPlayer:player1];
            [trackListVC setArtistName:userName];
            [trackListVC setTracks:(NSArray*)jsonResponse];
            [[trackListVC table] reloadData];
            [_loadDeck1 setEnabled:YES];
            [_spinner setHidden:YES];
            [_spinner stopAnimating];
            [self presentViewController:self.trackListVC
                               animated:YES completion:nil];

            
        } else {
            NSLog(@"%@", jsonError.localizedDescription);
        }
    };
    
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:resourceURL]
             usingParameters:nil
                 withAccount:account
      sendingProgressHandler:nil
             responseHandler:handler];
    
    [_playDeck1 setEnabled:YES];
    [_getInfoDeck1 setEnabled:YES];
    [_stopDeck1 setEnabled:YES];
    
    
}

-(IBAction)loadDeck2:(id)sender
{
    [_spinner setHidden:NO];
    [_spinner startAnimating];
    [_loadDeck2 setEnabled:NO];
    if (_isDeck2Playing)
    {
        [player2 stop];
    }
    SCAccount *account = [SCSoundCloud account];
    if (account == nil) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Not Logged In"
                              message:@"You must login first"
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    NSString *resourceURL;
    NSString *userName;
    
    if (!onlyUsers){
        
        int r = arc4random_uniform([_artists count]);
        NSString *trackCount = (NSString*)[[_artists objectAtIndex:r] objectForKey:@"track_count"];
        while ([trackCount integerValue] == 0)
        {
            r = arc4random_uniform([_artists count]);
            trackCount = (NSString*)[[_artists objectAtIndex:r] objectForKey:@"track_count"];
        }
        NSString *userID = (NSString*)[[_artists objectAtIndex:r] objectForKey:@"id"];
        userName = (NSString*)[[_artists objectAtIndex:r] objectForKey:@"username"];
        NSLog(@"%@", userName);
        NSLog(@"ID: %@, track_count: %@", userID, trackCount);
        deck2ArtistURL = [NSURL URLWithString:(NSString*)[[_artists objectAtIndex:r] objectForKey:@"permalink_url"]];
        
        _artistName2.text = userName;
        resourceURL = [NSString stringWithFormat:@"https://api.soundcloud.com/users/%@/tracks.json", userID];
        SCRequestResponseHandler handler;
        handler = ^(NSURLResponse *response, NSData *data, NSError *error) {
            NSError *jsonError = nil;
            NSJSONSerialization *jsonResponse = [NSJSONSerialization
                                                 JSONObjectWithData:data
                                                 options:0
                                                 error:&jsonError];
            if (!jsonError && [jsonResponse isKindOfClass:[NSArray class]]) {
                [trackListVC setCurrentDeck:2];
                [self.trackListVC setPlayer:player2];
                [trackListVC setArtistName:userName];
                [trackListVC setTracks:(NSArray*)jsonResponse];
                [[trackListVC table] reloadData];
                [_loadDeck2 setEnabled:YES];
                [_spinner setHidden:YES];
                [_spinner stopAnimating];
                [self presentViewController:self.trackListVC
                                   animated:YES completion:nil];

                
            }
        };
        
        [SCRequest performMethod:SCRequestMethodGET
                      onResource:[NSURL URLWithString:resourceURL]
                 usingParameters:nil
                     withAccount:account
          sendingProgressHandler:nil
                 responseHandler:handler];
        
    } else {
        
        if ([localUserNames count] == 0)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Registered Users in Your Area"
                                                            message:@"Turn off the 'Only Users' switch!"
                                                           delegate:self
                                  
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil,nil];
            
            [alert show];
            [_spinner stopAnimating];
            [_spinner setHidden:YES];

        } else {
            
            int r = arc4random_uniform([localUserNames count]);
            _artistName2.text = (NSString*)localUserNames[r];
            resourceURL = [NSString stringWithFormat:@"https://api.soundcloud.com/users/%@/tracks.json", localUserIDs[r]];
            SCRequestResponseHandler handler;
            handler = ^(NSURLResponse *response, NSData *data, NSError *error) {
                NSError *jsonError = nil;
                NSJSONSerialization *jsonResponse = [NSJSONSerialization
                                                     JSONObjectWithData:data
                                                     options:0
                                                     error:&jsonError];
                if (!jsonError && [jsonResponse isKindOfClass:[NSArray class]]) {
                    [trackListVC setCurrentDeck:2];
                    [self.trackListVC setPlayer:player2];
                    [trackListVC setArtistName:localUserNames[r]];
                    [trackListVC setTracks:(NSArray*)jsonResponse];
                    [[trackListVC table] reloadData];
                    [_loadDeck2 setEnabled:YES];
                    [_spinner setHidden:YES];
                    [_spinner stopAnimating];
                    [self presentViewController:self.trackListVC
                                       animated:YES completion:nil];
                    
                }
            };
            
            [SCRequest performMethod:SCRequestMethodGET
                          onResource:[NSURL URLWithString:resourceURL]
                     usingParameters:nil
                         withAccount:account
              sendingProgressHandler:nil
                     responseHandler:handler];
            
            
        }
    }
    [_playDeck2 setEnabled:YES];
    [_getInfoDeck2 setEnabled:YES];
    [_stopDeck2 setEnabled:YES];
    
}
-(IBAction)infoDeck1:(id)sender
{
    if (_isDeck1Playing)
        [player1 stop];
    if (_isDeck2Playing)
        [player2 stop];
    [[UIApplication sharedApplication] openURL:deck1ArtistURL];
}
-(IBAction)infoDeck2:(id)sender
{
    if (_isDeck1Playing)
        [player1 stop];
    if (_isDeck2Playing)
        [player2 stop];
    [[UIApplication sharedApplication] openURL:deck2ArtistURL];
}

-(IBAction)likeTrackDeck1:(id)sender
{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    deck1TrackID = [defaults objectForKey:@"deck1TrackID"];
    
    SCRequestResponseHandler handler;
    handler = ^(NSURLResponse *response, NSData *data, NSError *error) {
        if (!error) {
            NSLog(@"ADDED TO FAVORITES");
        } else {
            NSLog(@"ERROR ADDING TO FAVORITES");
        }
    };
    SCAccount *account = [SCSoundCloud account];
    NSString *resourceURL = [NSString stringWithFormat:@"https://api.soundcloud.com/me/favorites/%@", deck1TrackID];
    [SCRequest performMethod:SCRequestMethodPUT
                  onResource:[NSURL URLWithString:resourceURL]
             usingParameters:nil
                 withAccount:account
      sendingProgressHandler:nil
             responseHandler:handler];
    
}
-(IBAction)likeTrackDeck2:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    deck2TrackID = [defaults objectForKey:@"deck2TrackID"];
    
    SCRequestResponseHandler handler;
    handler = ^(NSURLResponse *response, NSData *data, NSError *error) {
        if (!error) {
            NSLog(@"ADDED TO FAVORITES");
        } else {
            NSLog(@"ERROR ADDING TO FAVORITES");
        }
    };
    SCAccount *account = [SCSoundCloud account];
    NSString *resourceURL = [NSString stringWithFormat:@"https://api.soundcloud.com/me/favorites/%@", deck2TrackID];
    [SCRequest performMethod:SCRequestMethodPUT
                  onResource:[NSURL URLWithString:resourceURL]
             usingParameters:nil
                 withAccount:account
      sendingProgressHandler:nil
             responseHandler:handler];
    
}

-(IBAction)home:(id)sender
{
    if (_isDeck1Playing)
        [player1 stop];
    if (_isDeck2Playing)
        [player2 stop];
}

#pragma mark - Navigation

// This will get called before the view appears
// - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
// if ([[segue identifier] isEqualToString:@"Details"]) {
// // Get destination view controller
//     [segue destinationViewController] = trackListVC;
//
// // Grab the text field contents and put it into a public property on the new view controller
// vc.myText = self.myTextField.text;
// // NOTE: myText is a public NSString property on your MileageDetailViewController
// // NOTE: self.myTextField is the IBOutlet connected to your Text Field
// }
// }

@end
