//
//  TabBarCollectionViewCell.swift
//
//  Created by L on 2022/12/16.
//  Copyright © 2022 All rights reserved.
//

import UIKit

class TabBarCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "TabBarCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var selectedTitleTextColor: UIColor = ColorHexUtil.hexColor(hex: "#84329b")
    var notSelectedTitleTextColor: UIColor = ColorHexUtil.hexColor(hex: "#333333")
    var selectedTitleFont: UIFont = UIFont.init(name: "PingFangTC-Medium", size: 15)!
    var notSelectedTitleFont: UIFont = UIFont.init(name: "PingFangTC-Regular", size: 15)!
    var isWidthEqualToCell: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.textColor = notSelectedTitleTextColor
        titleLabel.font = notSelectedTitleFont
        
        titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = isWidthEqualToCell
        titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = isWidthEqualToCell
    }
    
    func setTitle(title: String) {
        titleLabel.text = title
    }
    
    override var isSelected: Bool {
        willSet {
            if newValue {
                titleLabel.textColor = selectedTitleTextColor
                titleLabel.font = selectedTitleFont
            } else {
                titleLabel.textColor = notSelectedTitleTextColor
                titleLabel.font = notSelectedTitleFont
            }
        }
    }
    
    override func prepareForReuse() {
        isSelected = false
    }
}
