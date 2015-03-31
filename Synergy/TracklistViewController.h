//
//  TracklistViewController.h
//  Synergy
//
//  Created by David Grunzweig on 3/28/15.
//  Copyright (c) 2015 David Grunzweig. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface TracklistViewController : UIViewController <AVAudioPlayerDelegate, UITableViewDelegate, UITableViewDataSource>
@property IBOutlet UITableView* table;
@property IBOutlet UILabel* artistNameLabel;
@property IBOutlet UIButton* artistButton;
@property (strong, nonatomic) NSArray* tracks;
@property (nonatomic) NSString* artistName;
@property NSString* trackTitle;
@property NSString* artistInfoURL;
@property NSString* trackID;
@property int currentDeck;
@property AVAudioPlayer* player;
@property IBOutlet UIActivityIndicatorView* spinner;

-(IBAction)newArtist:(id)sender;

@end
