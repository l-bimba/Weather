//
//  BottomPopupDismissAnimator.swift
//  Weather
//
//  Created by Lukas Bimba on 7/3/20.
//  Copyright © 2020 Lukas Bimba. All rights reserved.
//

import UIKit

class BottomPopupDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    private unowned var attributesOwner: BottomPopupViewController
    
    init(attributesOwner: BottomPopupViewController) {
        self.attributesOwner = attributesOwner
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return attributesOwner.getPopupDismissDuration()
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: .from)!
        let dismissFrame = CGRect(origin: CGPoint(x: 0, y: UIScreen.main.bounds.size.height), size: fromVC.view.frame.size)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            fromVC.view.frame = dismissFrame
        }) { (_) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
