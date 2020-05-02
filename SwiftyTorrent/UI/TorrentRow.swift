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
                .font(Font.system(size: 16))
                .bold()
            Spacer(minLength: 5)
            Text(model.statusDetails)
                .font(Font.system(size: 14))
                .bold()
            Spacer(minLength: 5)
            Text(model.connectionDetails)
                .font(Font.system(size: 14))
        }
    }
    
}
