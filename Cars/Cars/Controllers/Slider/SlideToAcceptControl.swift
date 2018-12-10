//
//  SlideToAcceptControl.swift
//  Cars
//
//  Created by Sasi M on 25/08/18.
//  Copyright © 2018 Sasi. All rights reserved.
//

import UIKit

@objc protocol SlideControlDelegate: AnyObject {
    func slideComplete()
    func slideDidCancel()
}


class SlideToAcceptControl: UIViewController {
    
    @IBOutlet private weak var sliderView: UIView!
    @IBOutlet private weak var sliderIcon: UIView!
    @IBOutlet private weak var sliderArrowLabel: UILabel!
    @IBOutlet private weak var sliderLabel: UILabel!
    @IBOutlet private weak var cancelButton: UIButton!
    
    weak var delegate : SlideControlDelegate?
    
    // MARK: Init Methods
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc convenience init(withDelegate delegate: SlideControlDelegate) {
        self.init(nibName: "SlideToAcceptControl", bundle: Bundle.main)
        self.delegate = delegate
    }
    
    // MARK: Life cycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sliderIcon.layer.cornerRadius = 17.5
        sliderIcon.backgroundColor = UIColor.init(red: 200.0/255.0, green: 221.0/255.0, blue: 87.0/255.0, alpha: 1.0)
        
        sliderArrowLabel.font = UIFont.systemFont(ofSize: 20)
        sliderArrowLabel.layer.masksToBounds = true
        sliderArrowLabel.layer.cornerRadius = sliderArrowLabel.frame.size.height / 2
        sliderArrowLabel.textColor = UIColor.white
        
        sliderView.layer.cornerRadius = 22.5
        sliderView.layer.borderColor = UIColor.lightGray.cgColor
        sliderView.layer.borderWidth = 0.5
        sliderView.backgroundColor = UIColor.init(red: 251.0/255.0, green: 222.0/255.0, blue: 55.0/255.0, alpha: 1.0)
        
        let panGesture: UIPanGestureRecognizer! = UIPanGestureRecognizer.init(target: self, action: #selector(slideToAccept(panGesture:)))
        panGesture.maximumNumberOfTouches = 1
        panGesture.minimumNumberOfTouches = 1
        sliderView.addGestureRecognizer(panGesture)
        
        cancelButton.layer.cornerRadius = cancelButton.frame.size.height / 2
        cancelButton.backgroundColor = UIColor.red
        cancelButton.setTitleColor(UIColor.white, for: .normal)
        cancelButton.adjustsImageWhenHighlighted = false
    }
    
    @objc func resetSlider() {
        
        let sliderY: Double = Double(self.sliderView!.frame.origin.y)
        
        sliderView.frame = (CGRect) (x: 0, y: sliderY, width: Double(180), height: Double(45))
        sliderLabel.alpha = 1.0
        sliderLabel.frame = (CGRect) (x: 53, y: 0, width: Double(125), height: Double(45))
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        delegate!.slideDidCancel()
    }
    
    // MARK: Pan gesture and slider methods
    
    @objc private func slideToAccept(panGesture: UIPanGestureRecognizer) {
        
        UIApplication.shared.delegate!.window!?.endEditing(true)
        
        var sliderWidth: Double! = Double(self.sliderView!.frame.size.width)
        let sliderHeight: Double! = Double(self.sliderView!.frame.size.height)
        var sliderX: Double! = Double(self.sliderView!.frame.origin.x)
        let sliderY: Double! = Double(self.sliderView!.frame.origin.y)
        
        if(panGesture.state == .ended) {
            sliderX = Double(self.view.frame.size.width - 200.0);
            UIView.animate(withDuration: 0.5, animations: {
                
                if (self.sliderView.frame.size.width <= 100) {
                    self.sliderView.frame = CGRect(x: 127, y: sliderY, width: 45.0, height: sliderHeight)
                    self.sliderLabel.frame = CGRect(x: -45, y: 0, width: self.sliderLabel!.frame.size.width, height: self.sliderLabel.frame.size.height)
                    self.sliderLabel.alpha = 0.0
                    self.delegate!.slideComplete()
                } else {
                    self.resetSlider()
                }
            })
            return
        }
        
        let location: CGPoint = panGesture.location(in: panGesture.view)
        var dX: Double = Double(location.x)
        
        if (sliderWidth - dX < 45) {
            dX = sliderWidth - 45
        } else if (sliderWidth - dX > 180) {
            dX = sliderWidth - 180
        }
        
        sliderWidth = sliderWidth - dX
        sliderX = sliderX + dX
        
        UIView.animate(withDuration: 0.15, animations: {
            self.sliderView.frame = CGRect(x: sliderX, y: sliderY, width: sliderWidth, height: sliderHeight)
            self.sliderLabel.frame = CGRect(x: sliderWidth - 125, y: 0.0, width: Double(self.sliderLabel!.frame.size.width), height: Double(self.sliderLabel.frame.size.height))
            self.sliderLabel.alpha = CGFloat((sliderWidth / 180) - 0.25);
            if (sliderWidth <= 60) {
                self.sliderLabel.alpha = 0
            }
        })
    }
}
