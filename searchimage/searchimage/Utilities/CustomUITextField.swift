//
//  CustomUITextField.swift
//  searchimage
//
//  Created by Nandish Bellad on 30/05/2022.
//

import UIKit

class CustomUITextField: UITextField {
    var activityIndicator : UIActivityIndicatorView!
    
    override func awakeFromNib() {
        activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.hidesWhenStopped = true
        self.addSubview(activityIndicator)
        activityIndicator.frame = self.bounds
    }
    
    func startAnimating() {
        activityIndicator.startAnimating()
    }
    func stopAnimating() {
        activityIndicator.stopAnimating()
    }
}
