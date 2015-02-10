//
//  EventTableViewCell.swift
//  FaghelgApp
//
//  Created by Anders Ullnæss on 16/09/14.
//  Copyright (c) 2014 Mesan. All rights reserved.
//

import UIKit
import CoreData

class EventTableViewCell: UITableViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var abstractLabel: UILabel!
    @IBOutlet weak var personImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var extraInfoView: UIView!
    
    // Constraint used for automatic resizing
    @IBOutlet weak var extraInfoViewHeight: NSLayoutConstraint!
    
    var extraInfoViewHeightConstraintConstant: CGFloat = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        self.extraInfoViewHeightConstraintConstant = self.extraInfoViewHeight.constant
        
        // Rounding employee image
        personImage.layer.cornerRadius = personImage.frame.size.width / 2
        personImage.clipsToBounds = true
        personImage.layer.borderWidth = 1.0
        personImage.layer.borderColor = UIColor.whiteColor().CGColor
    }
    
    func setEvent(event: Event) {
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "HH:mm"
        timeLabel.text = dateStringFormatter.stringFromDate(event.start)
        if (event.hostNames != nil) {
            nameLabel.text = event.hostNames
        }
        else {
            nameLabel.text = nil
        }
        var durationSeconds:Double = event.end.timeIntervalSinceDate(event.start)
        var durationMinutes:Double = durationSeconds / 60
        var durationString: String? = String(format: "%.0f min", durationMinutes)
        if (durationString != nil) {
            durationLabel.text = durationString
        }
        else {
            durationLabel.text = nil
        }
        
        abstractLabel.text = event.desc
        titleLabel.text = event.title
        if (event.responsible == nil && event.hostNames != nil && event.hostNames.lowercaseString == "faggruppen") {
            var bgImage = getImage(event.hostNames.lowercaseString, profileImageUrl: "http://faghelg.s3-website-eu-west-1.amazonaws.com/" + event.hostNames.lowercaseString + ".png");
            personImage.image = bgImage
        }
        else if (event.responsible != nil && event.responsible?.profileImageUrl != nil && event.responsible?.shortName != nil) {
            var bgImage = getImage(event.responsible!.shortName!, profileImageUrl: event.responsible!.profileImageUrl!);
            personImage.image = bgImage
        }
        else {
            personImage.image = UIImage(named: "ukjent");
        }
    }
    
    func showExtraInfoView(show: Bool) {
        if (show) {
            self.extraInfoViewHeight.constant = self.extraInfoViewHeightConstraintConstant
        } else {
            self.extraInfoViewHeight.constant = 0
        }
        
        self.extraInfoView.hidden = !show
        self.layoutIfNeeded()
    }
    
    func getImage(shortName: String, profileImageUrl: String) -> UIImage? {
        var managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
        
        var nsFetchRequest: NSFetchRequest = NSFetchRequest(entityName: "Bilde")
        nsFetchRequest.includesPendingChanges = false
        nsFetchRequest.predicate = NSPredicate(format: "shortName = %@", shortName)
        var existingBildes: NSArray = managedObjectContext?.executeFetchRequest(nsFetchRequest, error: nil) as NSArray!
        var existingBilde: Bilde? = existingBildes.firstObject as? Bilde
        
        if (existingBilde != nil) {
            return UIImage(data: existingBilde!.imageData)!
        }
        

        if let newBilde = getImageFromWeb(profileImageUrl, shortName: shortName, managedObjectContext: managedObjectContext!) {
            newBilde.save()
            return UIImage(data: newBilde.imageData)!
        }
        
        return nil
    }
    
    func getImageFromWeb(profileImageUrl: String, shortName: String, managedObjectContext: NSManagedObjectContext) -> Bilde? {
        let url = NSURL(string:profileImageUrl);
        var err: NSError? = nil
        
        if let imageData = NSData(contentsOfURL: url!,options: NSDataReadingOptions.DataReadingMappedIfSafe, error: &err) {
        
            var bilde: Bilde = Bilde(entity: NSEntityDescription.entityForName("Bilde", inManagedObjectContext: managedObjectContext)!, insertIntoManagedObjectContext: managedObjectContext)
        
            bilde.shortName = shortName
            bilde.imageData = imageData
            return bilde
        }
        
        return nil
    }
}
