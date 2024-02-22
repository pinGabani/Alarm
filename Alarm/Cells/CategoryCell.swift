//
//  CategoryCell.swift
//  Alarm
//
//  Created by pinali gabani on 17/12/23.
//

import UIKit

class CategoryCell: UICollectionViewCell {

    @IBOutlet weak var categoryName: UILabel!
    @IBOutlet weak var selectIndicator: UIView!
    
    public func configure(with title: String, isSelected: Bool = false) {
        categoryName.text = title
        categoryName.textColor = isSelected ? .black : UIColor(named: "unselectColor")
        selectIndicator.isHidden = isSelected ? false : true
    }
}
