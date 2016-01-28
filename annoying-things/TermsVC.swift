//
//  TermsVC.swift
//  annoying-things
//
//  Created by Jon on 1/28/16.
//  Copyright © 2016 Coder Vox. All rights reserved.
//

import UIKit

class TermsVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func agreeButton(sender: AnyObject) {
        performSegueWithIdentifier(TO_FEED_VC, sender: nil)
    }
    


}
