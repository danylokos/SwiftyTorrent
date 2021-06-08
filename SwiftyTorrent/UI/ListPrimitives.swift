//
//  ListPrimitives.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 09.06.2021.
//  Copyright © 2021 Danylo Kostyshyn. All rights reserved.
//

import UIKit

typealias RowAction = () -> Void

enum RowType {
    case plain(RowAction? = nil)
    case button(RowAction)
    case navigation(RowAction)
}

struct Section: Equatable, Hashable {
    var id: String = UUID().uuidString
    var title: String?
    var rows: [Row]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Section, rhs: Section) -> Bool {
        return lhs.id == rhs.id
    }

}

struct Row: Equatable, Hashable {
    var id: String
    var viewType: UITableViewCell.Type { ListCell.self }
    var title: String?
    var subtitle: String?
    var rowType: RowType = .plain()

    var action: RowAction? {
        switch rowType {
        case .plain(let action): return action
        case .button(let action): return action
        case .navigation(let action): return action
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Row, rhs: Row) -> Bool {
        return lhs.id == rhs.id
    }

}
