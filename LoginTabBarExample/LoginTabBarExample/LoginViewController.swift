//
//  LoginViewController.swift
//  LoginTabBarExample
//
//  Created by Josip Cavar on 12/03/15.
//  Copyright (c) 2015 Josip Cavar. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonLoginTouchUpInside(sender: AnyObject) {
        
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "UserLoggedIn")
        NSUserDefaults.standardUserDefaults().synchronize()
        transitionToMainViewController()
    }

}
