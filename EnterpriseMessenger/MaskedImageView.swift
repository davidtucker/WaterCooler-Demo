//
//  MaskedImageView.swift
//  EnterpriseMessenger
//
//  Created by David Tucker on 1/19/15.
//  Copyright (c) 2015 Universal Mind. All rights reserved.
//

import Foundation

class MaskedImageView : UIImageView {

    func setupMask() {
        let maskLayer:CAShapeLayer = CAShapeLayer();
        maskLayer.path = UIBezierPath(ovalInRect: self.bounds).CGPath;
        maskLayer.fillColor = UIColor.blackColor().CGColor;
        self.layer.mask = maskLayer;
        self.backgroundColor = UIColor(white: 0.0, alpha: 0.1)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupMask()
    }
    
}