//
//  CustomTableViewCell.swift
//  Hina Bike Rental
//
//  Created by Adam Alexander Campbell on 15/03/2019.
//  Copyright © 2019 Adam Alexander Campbell. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell
{
    lazy var backView: UIView =
    {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 50))
        view.backgroundColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1)
        return view
    }()
    
    lazy var settingImage: UIImageView =
    {
        let imageView = UIImageView(frame: CGRect(x: 15, y: 10, width: 30, height: 30))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var label: UILabel =
    {
        let label = UILabel(frame: CGRect(x: 60, y: 10, width: self.frame.width-75, height: 30))
        label.textColor = UIColor.white
        return label
    }()
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
        addSubview(backView)
        addSubview(settingImage)
        addSubview(label)
    }
}
