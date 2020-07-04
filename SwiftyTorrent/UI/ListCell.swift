//
//  ListCell.swift
//  SwiftyTorrent
//
//  Created by Danylo Kostyshyn on 06.07.2020.
//  Copyright © 2020 Danylo Kostyshyn. All rights reserved.
//

import UIKit

final class ListCell: UITableViewCell {
    
    private struct LayoutConstants {
        static let contentInsets = UIEdgeInsets(top: 10.0, left: 20.0, bottom: -10.0, right: -20.0)
    }
    
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leadingAnchor.constraint(
            equalTo: contentView.leadingAnchor,
            constant: LayoutConstants.contentInsets.left).isActive = true
        titleLabel.trailingAnchor.constraint(
            equalTo: contentView.trailingAnchor,
            constant: LayoutConstants.contentInsets.right).isActive = true
        titleLabel.topAnchor.constraint(
            equalTo: contentView.topAnchor,
            constant: LayoutConstants.contentInsets.top).isActive = true
        titleLabel.bottomAnchor.constraint(
            equalTo: subtitleLabel.topAnchor,
            constant: -5.0).isActive = true
        
        subtitleLabel.leadingAnchor.constraint(
            equalTo: contentView.leadingAnchor,
            constant: LayoutConstants.contentInsets.left).isActive = true
        subtitleLabel.trailingAnchor.constraint(
            equalTo: contentView.trailingAnchor,
            constant: LayoutConstants.contentInsets.right).isActive = true
        subtitleLabel.bottomAnchor.constraint(
            equalTo: contentView.bottomAnchor,
            constant: LayoutConstants.contentInsets.bottom).isActive = true
    }

}
