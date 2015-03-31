//
//  MixerViewController.h
//  Synergy
//
//  Created by David Grunzweig on 3/28/15.
//  Copyright (c) 2015 David Grunzweig. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TracklistViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CoreMotion.h>

@interface MixerViewController : UIViewController <AVAudioPlayerDelegate, AVAudioStereoMixing>
{
    float mMixerValue;
}
@property IBOutlet UIButton* playDeck1;
@property IBOutlet UIButton* playDeck2;
@property IBOutlet UIButton* stopDeck1;
@property IBOutlet UIButton* stopDeck2;
@property IBOutlet UIButton* loadDeck1;
@property IBOutlet UIButton* loadDeck2;
@property IBOutlet UIButton* getInfoDeck1;
@property IBOutlet UIButton* getInfoDeck2;
@property IBOutlet UILabel* track1Title;
@property IBOutlet UILabel* track2Title;
@property IBOutlet UILabel* speedDeck1Label;
@property IBOutlet UILabel* speedDeck2Label;
@property IBOutlet UILabel* leftEdge;
@property IBOutlet UILabel* rightEdge;
@property IBOutlet UIImageView* faderKnob;
@property IBOutlet UIPanGestureRecognizer* panGesture;
@property IBOutlet UILabel* artistName1;
@property IBOutlet UILabel* artistName2;
@property IBOutlet UISwitch* turnOffMusicianMode;
@property IBOutlet UISwitch* usersOnlySwitch;
@property IBOutlet UIActivityIndicatorView* spinner;


@property BOOL isDeck1Playing;
@property BOOL isDeck2Playing;
@property AVAudioPlayer* player1;
@property AVAudioPlayer* player2;
@property BOOL isMusician;
@property BOOL onlyUsers;
@property IBOutlet TracklistViewController* trackListVC;
@property NSString* location;
@property NSArray* artists;
@property NSURL* deck1ArtistURL;
@property NSURL* deck2ArtistURL;
@property NSURL* deck1TrackID;
@property NSURL* deck2TrackID;
@property NSMutableArray* localUserNames;
@property NSMutableArray* localUserIDs;
@property NSString* myUserID;
@property NSString* myUserName;


@property (strong, nonatomic) CMMotionManager *motionManager;



-(IBAction)playDeck1:(id)sender;
-(IBAction)playDeck2:(id)sender;
-(IBAction)stopDeck1:(id)sender;
-(IBAction)stopDeck2:(id)sender;
-(IBAction)loadDeck1:(id)sender;
-(IBAction)loadDeck2:(id)sender;
-(IBAction)infoDeck1:(id)sender;
-(IBAction)infoDeck2:(id)sender;
-(IBAction)likeTrackDeck1:(id)sender;
-(IBAction)likeTrackDeck2:(id)sender;
-(IBAction)home:(id)sender;
-(IBAction)switchCollabMode:(id)sender;
-(IBAction)switchUserMode:(id)sender;


@end
