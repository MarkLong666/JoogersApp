//
//  HistoryTableViewCell.swift
//  joggers
//
//  Created by Long Baolin on 16/3/17.
//  Copyright © 2016年 Lintasty. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var runningDistanceLabel: UILabel!
    @IBOutlet weak var runningTimeLabel: UILabel!
    
    var iconImage: UIImage!{
        didSet{
            UIGraphicsBeginImageContextWithOptions(iconImageView.bounds.size, false, 2.0)
            UIBezierPath(roundedRect: iconImageView.bounds, cornerRadius: iconImageView.bounds.size.width/2).addClip()
            iconImage.drawInRect(iconImageView.bounds)
            iconImageView.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        separatorInset = UIEdgeInsets(top: 0, left: iconImageView.layer.bounds.width + 10, bottom: 0, right: 8)
    }
}
