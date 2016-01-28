//
//  Constants.swift
//  annoying-things
//
//  Created by Jon on 11/20/15.
//  Copyright © 2015 Coder Vox. All rights reserved.
//

import Foundation
import UIKit

//We don't put constants into a class because that gives it a limited scope. We want our constants to be globally accessible.


//This is to give our view a shadow color.
let SHADOW_COLOR: CGFloat = 157.0 / 255.0

//Keys
let KEY_UID = "uid"
let KEY_USERNAME = "username"

//Segues
let SEGUE_LOGGED_IN = "loggedIn"
let TO_FEED_VC = "tofeedvc"
let SEGUE_STRAIGHT_TO_FEED = "straightofeed"
let TO_TERMS_VC = "toTermsVC"

//Status Codes
let STATUS_ACCOUNT_NONEXIST = -8

//Time
let TIMESTAMP = NSDate().timeIntervalSince1970
let TIMEDATE = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)

