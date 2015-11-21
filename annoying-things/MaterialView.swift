//
//  MaterialView.swift
//  annoying-things
//
//  Created by Jon on 11/20/15.
//  Copyright © 2015 Coder Vox. All rights reserved.
//

import UIKit

class MaterialView: UIView {

    //awakeFromNib is called when the user interface is loaded from the storyboard.
    override func awakeFromNib() {
        layer.cornerRadius = 2.0
        layer.shadowColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 0.5).CGColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5.0 //How much blur and shadow coverage you want
        layer.shadowOffset = CGSizeMake(0.0, 2.0)
    }

}
