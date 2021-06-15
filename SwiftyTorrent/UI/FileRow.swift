//
//  FileRow.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 7/16/19.
//  Copyright © 2019 Danylo Kostyshyn. All rights reserved.
//

import SwiftUI

struct FileRow: View {
    
    var model: FileRowModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(model.title)
                .font(.headline)
                .bold()
                .lineLimit(2)
            if let deltails = model.sizeDetails {
                Spacer(minLength: 5)
                Text(deltails)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }
    
}
