//
//  STTorrent.m
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 6/25/19.
//  Copyright © 2019 Danylo Kostyshyn. All rights reserved.
//

#import "STTorrent.h"

#import "STFileEntry.h"
#import "STTorrentManager.h"

@interface STTorrent ()
@property (readwrite, strong, nonatomic) NSData *infoHash;
@property (readwrite, strong, nonatomic) NSString *name;
@property (readwrite, nonatomic) STTorrentState state;
@property (readwrite, nonatomic) double progress;
@property (readwrite, nonatomic) NSUInteger numberOfPeers;
@property (readwrite, nonatomic) NSUInteger numberOfSeeds;
@property (readwrite, nonatomic) NSUInteger downloadRate;
@property (readwrite, nonatomic) NSUInteger uploadRate;
@property (readwrite, nonatomic) BOOL hasMetadata;
@end

@implementation STTorrent

#ifdef DEBUG
static NSUInteger stubIdx = 0;

+ (instancetype)randomStubTorrent {
    STTorrent *torrent = [[STTorrent alloc] init];
    torrent.infoHash = [[[NSUUID UUID] UUIDString] dataUsingEncoding:NSUTF8StringEncoding];
    torrent.name = [NSString stringWithFormat:@"Stub torrent (%2lu)", stubIdx];
    torrent.state = stubIdx % ((NSUInteger)STTorrentStateCheckingResumeData);
    torrent.progress = (double)arc4random() / UINT32_MAX;
    torrent.numberOfPeers = arc4random_uniform(100);
    torrent.numberOfSeeds = arc4random_uniform(100);
    torrent.downloadRate = arc4random_uniform(1024 * 1024 * 1024);
    torrent.uploadRate = arc4random_uniform(1024 * 1024 * 1024);
    torrent.hasMetadata = torrent.state != STTorrentStateDownloadingMetadata;
    stubIdx += 1;
    return torrent;
}
#endif

@end
