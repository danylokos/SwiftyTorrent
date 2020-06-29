//
//  STTorrentFile.m
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 6/29/19.
//  Copyright © 2019 Danylo Kostyshyn. All rights reserved.
//

#import "STTorrentFile.h"

#import "libtorrent/torrent_info.hpp"
#import "libtorrent/add_torrent_params.hpp"

@interface STTorrentFile ()
@property (readwrite, strong, nonatomic) NSData *fileData;
@end

@implementation STTorrentFile

- (instancetype)initWithFileAtURL:(NSURL *)fileURL {
    self = [self init];
    if (self) {
        _fileData = [NSData dataWithContentsOfURL:fileURL];
    }
    return self;
}

#pragma mark - STDownloadable

- (lt::torrent_info)torrent_info {
    uint8_t *buffer = (uint8_t *)[self.fileData bytes];
    size_t size = [self.fileData length];
    return lt::torrent_info((char *)buffer, (int)size);;
}

- (void)configureAddTorrentParams:(void *)params {
    lt::add_torrent_params *_params = (lt::add_torrent_params *)params;
    lt::torrent_info ti = [self torrent_info];
    _params->ti = std::make_shared<lt::torrent_info>(ti);
}

#pragma mark - Test torrents

+ (NSBundle *)currentBundle {
    return [NSBundle bundleForClass:self];
}

+ (STTorrentFile *)test_1 {
    NSURL *fileURL = [[self currentBundle] URLForResource:@"ubuntu-18.04.2-live-server-amd64.iso" withExtension:@"torrent"];
    return [[STTorrentFile alloc] initWithFileAtURL:fileURL];
}

+ (STTorrentFile *)test_2 {
    NSURL *fileURL = [[self currentBundle] URLForResource:@"ubuntu-19.04-live-server-amd64.iso" withExtension:@"torrent"];
    return [[STTorrentFile alloc] initWithFileAtURL:fileURL];
}

@end
