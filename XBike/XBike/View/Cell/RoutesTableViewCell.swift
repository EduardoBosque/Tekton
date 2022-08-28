//
//  RoutesTableViewCell.swift
//  XBike
//
//  Created by Eduardo Vasquez on 26/08/22.
//

import UIKit

class RoutesTableViewCell: UITableViewCell {

    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var origin: UILabel!
    @IBOutlet weak var destination: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        timeLbl.text = kEmptyString
        distanceLbl.text = kEmptyString
        origin.text = kEmptyString
        destination.text = kEmptyString
    }
    
}

protocol Describable {
    static var name: String { get }
}

extension Describable {
    static var name: String {
        return String(describing: self)
    }
}

extension UITableViewCell: Describable { }

extension UICollectionReusableView: Describable { }

extension UITableViewHeaderFooterView: Describable { }

