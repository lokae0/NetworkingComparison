//
//  SubtitleCell.swift
//  NetworkingComparison
//
//  Created by Ian Luo on 10/31/19.
//  Copyright © 2019 Lokae. All rights reserved.
//

import UIKit

class SubtitleCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }

    func update(forecast: Forecast) {
        detailTextLabel?.text = forecast.formattedDate
        textLabel?.text = forecast.formattedDescription
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

