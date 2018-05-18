//
//  Animations.swift
//  Book of stories
//
//  Created by Alex Odintsov on 09.05.2018.
//  Copyright © 2018 Alex Odintsov. All rights reserved.
//

import UIKit

//back and next buttons
func moveAnimationsNext(label: UILabel) {
    
    let positionAnimation = CABasicAnimation(keyPath: "position")
    positionAnimation.fromValue = NSValue(cgPoint: CGPoint(x: label.center.x + 70, y: label.center.y))
    positionAnimation.toValue = NSValue(cgPoint: CGPoint(x: label.center.x, y: label.center.y))
    positionAnimation.duration = 0.3
    
    let fadeAnimation = CABasicAnimation(keyPath: "opacity")
    fadeAnimation.fromValue = 0
    fadeAnimation.toValue = 1
    fadeAnimation.duration = 0.3
    
    label.layer.add(positionAnimation, forKey: nil)
    label.layer.add(fadeAnimation, forKey: nil)
}

func moveAnimatiosBack(label: UILabel) {
    
    let positionAnimation = CABasicAnimation(keyPath: "position")
    positionAnimation.fromValue = NSValue(cgPoint: CGPoint(x: label.center.x - 70, y: label.center.y))
    positionAnimation.toValue = NSValue(cgPoint: CGPoint(x: label.center.x, y: label.center.y))
    positionAnimation.duration = 0.3
    
    let fadeAnimation = CABasicAnimation(keyPath: "opacity")
    fadeAnimation.fromValue = 0
    fadeAnimation.toValue = 1
    fadeAnimation.duration = 0.3

    label.layer.add(positionAnimation, forKey: nil)
    label.layer.add(fadeAnimation, forKey: nil)
}

//blur
func animateBlurIn(visualEffectView: UIVisualEffectView, effect: UIVisualEffect) {
    UIView.animate(withDuration: 0.4, animations: {
        visualEffectView.effect = effect
    })
}

func animateBlurOut(visualEffectView: UIVisualEffectView, effect: UIVisualEffect) {
    UIView.animate(withDuration: 0.4, animations: {
        visualEffectView.effect = nil
    })
}

//selected image in picked date view controller
func animateSelectedImageIn(view: UIView, navigationController: UINavigationController?){
    view.transform = CGAffineTransform.init(scaleX: 0.3, y: 0.3)
    view.alpha = 0
    
    UIView.animate(withDuration: 0.5, animations: {
        view.transform = CGAffineTransform.identity
        view.alpha = 1
        if let navContrl = navigationController {
            navContrl.setNavigationBarHidden(true, animated: true)
        }
    })
    view.backgroundColor = UIColor.black
}
func animateSelectedImageOut(view: UIView, navigationController: UINavigationController?){
    
    UIView.animate(withDuration: 0.5, animations: {
        view.transform = CGAffineTransform.init(scaleX: 0.3, y: 0.3)
        view.alpha = 0
        if let navContrl = navigationController {
            navContrl.isNavigationBarHidden = false
        }
    }) { (success: Bool) in view.removeFromSuperview() }
    view.backgroundColor = UIColor.white
}
