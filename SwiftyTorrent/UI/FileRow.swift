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
                .font(Font.headline)
                .bold()
//            Spacer(minLength: 5)
//            Text(model.pathDetails)
//                .font(Font.subheadline)
//                .foregroundColor(.gray)
//            Spacer(minLength: 5)
//            Text(model.sizeDetails)
//                .font(Font.subheadline)
        }
    }
    
}
