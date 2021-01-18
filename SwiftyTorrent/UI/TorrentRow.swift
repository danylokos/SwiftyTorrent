//
//  TorrentRow.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 7/13/19.
//  Copyright © 2019 Danylo Kostyshyn. All rights reserved.
//

import SwiftUI

struct TorrentRow: View {
    
    var model: TorrentRowModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(model.title)
                .font(Font.headline)
                .bold()
            Spacer(minLength: 5)
            Text(model.statusDetails)
                .font(Font.subheadline)
                .bold()
            Spacer(minLength: 5)
            Text(model.connectionDetails)
                .font(Font.subheadline)
        }
    }
    
}
