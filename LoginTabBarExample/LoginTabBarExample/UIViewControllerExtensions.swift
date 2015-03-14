//
//  UIViewControllerExtensions.swift
//  LoginTabBarExample
//
//  Created by Josip Cavar on 12/03/15.
//  Copyright (c) 2015 Josip Cavar. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func transitionToMainViewController() {
        
        if let window = self.view.window {
            UIView.transitionWithView(window, duration: 0.3, options: UIViewAnimationOptions.TransitionFlipFromLeft, animations: {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                window.rootViewController = storyboard.instantiateInitialViewController() as? UIViewController
                }, completion: nil)
            }
    }
    
    func transitionToLoginViewController() {
        
        if let window = self.view.window {
            UIView.transitionWithView(window, duration: 0.3, options: UIViewAnimationOptions.TransitionFlipFromLeft, animations: {
                let storyboard = UIStoryboard(name: "Login", bundle: nil)
                window.rootViewController = storyboard.instantiateInitialViewController() as? UIViewController
                }, completion: nil)
        }
    }
}