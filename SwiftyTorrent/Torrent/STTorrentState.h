//
//  STTorrentState.h
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 6/26/19.
//  Copyright © 2019 Danylo Kostyshyn. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, STTorrentState) {
   STTorrentStateCheckingFiles,
   STTorrentStateDownloadingMetadata,
   STTorrentStateDownloading,
   STTorrentStateFinished,
   STTorrentStateSeeding,
   STTorrentStateAllocating,
   STTorrentStateCheckingResumeData
} NS_SWIFT_NAME(Torrent.State);
