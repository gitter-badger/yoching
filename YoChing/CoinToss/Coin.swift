//
//  Coin.swift
//  YoChing
//
//  Created by Juan Wellington Moreno on 3/31/16.
//  Copyright © 2016 Gary.com. All rights reserved.
//

import Foundation
import QuartzCore
import UIKit

let kMAX_REPS_QUICK = 5
let kMAX_REPS_SLOW = 10
let kSLOW_ANIMATION: Double = 0.4
let kQUICK_ANIMATION: Double = 0.10

class Coin {
    
    weak var image: UIImageView?
    
    private var repeatCount = 0
    private var animationDuration = kQUICK_ANIMATION
    private var maxReps = kMAX_REPS_QUICK
    
    private var onDone: (CoinSide -> Void)?
    
    private lazy var tails: UIImage = UIImage(named: "Coin_Tails")!
    private lazy var heads: UIImage = UIImage(named: "Coin_Heads")!
    
    enum CoinSide {
        case HEADS
        case TAILS
    }
    
    init(image: UIImageView) {
        self.image = image
    }

    func doAnimation() {
        
        guard let image = image else { return }
        
        if repeatCount > maxReps  { //This means we're done
            
            let isEven: Bool = (Int(arc4random()) % 2 == 0)
            let resultingSide: CoinSide =  isEven ? .HEADS : .TAILS
            
            image.layer.contents =  resultingSide == .HEADS ? heads.CGImage : tails.CGImage
            image.layer.transform = CATransform3DIdentity

            onDone?(resultingSide)
            
            return
        }
        repeatCount += 1
        
        if repeatCount == 1 {					// first time for this animation
            let duration: Double = (animationDuration * Double((maxReps+1)))
            let startFrame = image.frame
            UIView.animateWithDuration(duration, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                
                var frame = image.frame
                
                frame.origin.y = 90.0
                image.frame = frame
                }, completion: {
                    _ in
                    
                    UIView.animateWithDuration(duration, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {
                        
                        image.frame = startFrame
                        }, completion: nil)
            })
        }
        
        UIView.animateWithDuration(animationDuration, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: { [weak self] in
            
            guard let `self` = self else { return }
            
            var rotation = CATransform3DIdentity
            rotation = CATransform3DRotate(rotation, CGFloat(M_PI_2), 1.0, 0.0, 0.0)
            image.layer.transform = rotation
            
            }, completion: {
                _ in
                
                image.layer.contents = self.tails.CGImage
                UIView.animateWithDuration(self.animationDuration, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
                    
                    var rotation = image.layer.transform
                    
                    rotation = CATransform3DRotate(rotation, CGFloat(M_PI), 1.0, 0.0, 0.0)
                    image.layer.transform = rotation;
                    }, completion: {
                        _ in
                        
                        image.layer.contents = self.heads.CGImage
                        self.doAnimation()
                })
        })
    }
    
    
    func flipCoinAction(onDone: CoinSide -> Void) {
        
        print("Flip Coin called")
        
        guard let image = self.image else {
            print("Coin Missing Image")
            return
        }
        
        self.repeatCount = 0
        self.onDone = onDone
        
        image.layer.removeAllAnimations()
        image.layer.contents = heads.CGImage
        doAnimation()
    }
}