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

#if DEBUG
+ (NSArray *)torrentsFromPlist {
    NSBundle *bundle = [NSBundle bundleForClass:self];
    NSURL *plsitURL = [bundle URLForResource:@"Torrents.plist" withExtension:nil];
    NSData *plistData = [NSData dataWithContentsOfURL:plsitURL options:0 error:nil];
    NSDictionary *dict = [NSPropertyListSerialization propertyListWithData:plistData options:0 format:nil error:nil];
    return dict[@"torrents"];
}

+ (STTorrentFile *)testFileAtIndex:(NSUInteger)index {
    NSArray *torrents = [self torrentsFromPlist];
    NSArray *torrent = torrents[index];
    
    NSString *fileName = [torrent[0] stringByAppendingPathExtension:@"torrent"];
    NSData *fileData = [[NSData alloc] initWithBase64EncodedString:torrent[2] options:0];

    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [cacheDir stringByAppendingPathComponent:fileName];
    [fileData writeToFile:filePath atomically:YES];
    
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    return [[STTorrentFile alloc] initWithFileAtURL:fileURL];
}

+ (STTorrentFile *)test_1 {
    return [self testFileAtIndex:0];
}

+ (STTorrentFile *)test_2 {
    return [self testFileAtIndex:1];
}
#endif

@end
