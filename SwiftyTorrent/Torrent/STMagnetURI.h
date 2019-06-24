//
//  STMagnetURI.h
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 6/29/19.
//  Copyright © 2019 Danylo Kostyshyn. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "STDownloadable.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(MagnetURI)
@interface STMagnetURI : NSObject <STDownloadable>
@property (readonly, strong, nonatomic) NSURL *magnetURI;

- (instancetype)initWithMagnetURI:(NSURL *)magnetURI;

+ (STMagnetURI *)test_1;

@end

NS_ASSUME_NONNULL_END
