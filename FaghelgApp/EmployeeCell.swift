//
//  EmployeeCell.swift
//  FaghelgApp
//
//  Created by Patrick Romstad on 16/09/14.
//  Copyright (c) 2014 Mesan. All rights reserved.
//

import UIKit

class EmployeeCell: UITableViewCell {

    @IBOutlet weak var fullName: UILabel!
    var shortName: String!
    @IBOutlet weak var employeeImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // Make cells not selectable
        self.userInteractionEnabled = false
        
        // Wrap full name
        fullName.lineBreakMode = NSLineBreakMode.ByWordWrapping
        fullName.numberOfLines = 0
        
        // Rounding employee image
        employeeImage.layer.cornerRadius = employeeImage.frame.size.width / 2
        employeeImage.clipsToBounds = true
        employeeImage.layer.borderWidth = 1.0
        employeeImage.layer.borderColor = UIColor.whiteColor().CGColor
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCell(fullName: String, shortName: String) {
        self.employeeImage.image = UIImage(named: "\(shortName).png")
        self.fullName.text = fullName
        self.shortName = shortName
    }

}
