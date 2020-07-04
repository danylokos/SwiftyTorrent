//
//  UITableView+TypeSafe.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 06.07.2020.
//  Copyright © 2020 Danylo Kostyshyn. All rights reserved.
//

import UIKit

extension UITableViewCell {
 
    static var defaultReuseIdentifier: String { description() }

}

extension UITableView {
    
    func registerCell<T: UITableViewCell>(_ cellClass: T.Type) {
        register(cellClass, forCellReuseIdentifier: cellClass.defaultReuseIdentifier)
    }
    
    func dequeueReusableCell<T: UITableViewCell>(_ cellClass: T.Type) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: cellClass.defaultReuseIdentifier) as? T else {
            fatalError("Can't dequeue cell for class: \(cellClass)")
        }
        return cell
    }

}
