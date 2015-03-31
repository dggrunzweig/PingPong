//
//  TracklistViewController.m
//  Synergy
//
//  Created by David Grunzweig on 3/28/15.
//  Copyright (c) 2015 David Grunzweig. All rights reserved.
//

#import "TracklistViewController.h"
#import <SCAPI.h>
 
@interface TracklistViewController ()


@end

@implementation TracklistViewController
@synthesize tracks, player, artistInfoURL, trackID, trackTitle, currentDeck, table;
- (void)viewDidLoad {
    [super viewDidLoad];
    table.delegate = self;
    table.dataSource = self;
    [_spinner setHidden:YES];
    [_spinner stopAnimating];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setArtistName:(NSString *)artistName
{
    _artistNameLabel.text = [NSString stringWithFormat:@"Artist Name: %@", artistName];
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [cell setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1]];
    [[cell textLabel] setTextColor:[UIColor greenColor]];
    

    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [self.tracks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{


    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *track = [self.tracks objectAtIndex:indexPath.row];
    cell.textLabel.text = [track objectForKey:@"title"];
    

    
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_artistButton setEnabled:NO];
    [tableView setUserInteractionEnabled:NO];
    NSDictionary *track = [self.tracks objectAtIndex:indexPath.row];
    NSString *streamURL = [track objectForKey:@"stream_url"];
    trackTitle = [track objectForKey:@"title"];
    trackID = (NSString*)[track objectForKey:@"id"];
    artistInfoURL = (NSString*)[track objectForKey:@"user_id"];
    ;
    SCAccount *account = [SCSoundCloud account];
    [_spinner setHidden:NO];
    [_spinner startAnimating];
    if (currentDeck == 1)
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:trackTitle forKey:@"deck1TrackTitle"];
        [defaults setObject:artistInfoURL forKey:@"deck1ArtistInfo"];
        [defaults setObject:trackID forKey:@"deck1TrackID"];
        
        [defaults synchronize];
    } else {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:trackTitle forKey:@"deck2TrackTitle"];
        [defaults setObject:artistInfoURL forKey:@"deck2ArtistInfo"];
        [defaults setObject:trackID forKey:@"deck2TrackID"];
        
        [defaults synchronize];
    }
    
    
    
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:streamURL]
             usingParameters:nil
                 withAccount:account
      sendingProgressHandler:nil
             responseHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                 NSError* playerError;

                 player = [player initWithData:data error:&playerError];
                 [_spinner stopAnimating];
                 [_spinner setHidden:YES];
                 [tableView setUserInteractionEnabled:YES];
                 [_artistButton setEnabled:YES];
                 [self dismissViewControllerAnimated:true completion:NULL];

             }];

}


-(IBAction)newArtist:(id)sender
{
    [self dismissViewControllerAnimated:true completion:NULL];
}


@end
