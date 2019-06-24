//
//  STDownloadable.h
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 6/29/19.
//  Copyright © 2019 Danylo Kostyshyn. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol STDownloadable <NSObject>

- (void)configureAddTorrentParams:(void *)params; // lt::add_torrent_params *

@end

NS_ASSUME_NONNULL_END
