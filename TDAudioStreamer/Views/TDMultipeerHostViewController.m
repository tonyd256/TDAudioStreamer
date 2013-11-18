//
//  TDMultipeerHostViewController.m
//  TDAudioStreamer
//
//  Created by Tony DiPasquale on 11/15/13.
//  Copyright (c) 2013 Tony DiPasquale. The MIT License (MIT).
//

#import <MediaPlayer/MediaPlayer.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

#import "TDMultipeerHostViewController.h"
#import "TDAudioStreamer.h"
#import "TDSession.h"

@interface TDMultipeerHostViewController () <MPMediaPickerControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *songs;
@property (strong, nonatomic) TDAudioOutputStreamer *outputStreamer;
@property (strong, nonatomic) TDSession *session;

@end

@implementation TDMultipeerHostViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.songs = [NSMutableArray array];
	self.session = [[TDSession alloc] initWithPeerDisplayName:@"Host"];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.songs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TrackCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    MPMediaItem *item = self.songs[indexPath.row];
    cell.textLabel.text = [item valueForProperty:MPMediaItemPropertyTitle];
    cell.detailTextLabel.text = [item valueForProperty:MPMediaItemPropertyArtist];

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MPMediaItem *item = self.songs[indexPath.row];

    NSArray *peers = [self.session connectedPeers];

    for (MCPeerID *peer in peers) {
        if ([peer.displayName isEqualToString:@"Guest"]) {
            if (!self.outputStreamer)
                self.outputStreamer = [[TDAudioOutputStreamer alloc] initWithOutputStream:[self.session outputStreamForPeer:peer]];

            [self.outputStreamer streamAudioFromURL:[item valueForProperty:MPMediaItemPropertyAssetURL]];
            [self.outputStreamer start];
            break;
        }
    }
}

#pragma mark - Media Picker delegate

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.songs addObjectsFromArray:mediaItemCollection.items];
    [self.tableView reloadData];
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - View Actions

- (IBAction)invite:(id)sender
{
    [self presentViewController:[self.session browserViewControllerForSeriviceType:@"dance-party"] animated:YES completion:nil];
}

- (IBAction)addSongs:(id)sender
{
    MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
    picker.delegate = self;
    picker.allowsPickingMultipleItems = YES;
    [self presentViewController:picker animated:YES completion:nil];
}

@end
