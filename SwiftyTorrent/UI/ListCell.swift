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

        var constraints = [NSLayoutConstraint]()
        constraints.append(contentsOf: [
            titleLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: LayoutConstants.contentInsets.left
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: LayoutConstants.contentInsets.right
            ),
            titleLabel.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: LayoutConstants.contentInsets.top
            ),
            titleLabel.bottomAnchor.constraint(
                equalTo: subtitleLabel.topAnchor,
                constant: -5.0
            )
        ])        
        constraints.append(contentsOf: [
            subtitleLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: LayoutConstants.contentInsets.left
            ),
            subtitleLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: LayoutConstants.contentInsets.right
            ),
            subtitleLabel.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: LayoutConstants.contentInsets.bottom
            )
        ])
        constraints.forEach({ $0.isActive = true })
    }

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        if let cell = context.previouslyFocusedView as? ListCell {
            coordinator.addCoordinatedAnimations {
                cell.titleLabel.textColor = .label
                cell.subtitleLabel.textColor = .systemGray
            }
        }
        if let cell = context.nextFocusedView as? ListCell {
            coordinator.addCoordinatedAnimations {
                cell.titleLabel.textColor = .black
                cell.subtitleLabel.textColor = .black
            }
        }
    }

}

extension ListCell: ViewModelConfigurable {
    
    typealias ViewModel = Row
    
    func configure(_ viewModel: Row) {
        titleLabel.text = viewModel.title
        subtitleLabel.numberOfLines = 0
        subtitleLabel.text = viewModel.subtitle
        switch viewModel.rowType {
        case .plain:
            selectionStyle = .none
            accessoryType = .none
            titleLabel.textColor = .label
            subtitleLabel.textColor = .systemGray
            titleLabel.font = .preferredFont(forTextStyle: .headline)
            subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        case .button:
            selectionStyle = .default
            accessoryType = .none
            titleLabel.textColor = tintColor
            subtitleLabel.textColor = tintColor
            titleLabel.font = .preferredFont(forTextStyle: .body)
            subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        case .navigation:
            selectionStyle = .default
            accessoryType = .disclosureIndicator
            titleLabel.textColor = .label
            subtitleLabel.textColor = .systemGray
            titleLabel.font = .preferredFont(forTextStyle: .headline)
            subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        }
    }
    
}

extension ListCell: AnyViewModelConfigurable { }
