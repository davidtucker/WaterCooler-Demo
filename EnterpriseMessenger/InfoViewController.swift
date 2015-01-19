//
//  InfoViewController.swift
//  EnterpriseMessenger
//
//  Created by David Tucker on 2/16/15.
//  Copyright (c) 2015 Universal Mind. All rights reserved.
//

import Foundation

@objc(InfoViewController)

class InfoViewController : UIViewController, UITextViewDelegate {
    
    //MARK: -
    //MARK: IBOutlets
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var infoTextView: UITextView!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    
    //MARK: -
    //MARK: UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.setTranslatesAutoresizingMaskIntoConstraints(false)
        let rtfURL = NSBundle.mainBundle().URLForResource("about", withExtension: "rtf")
        let options = [
            NSDocumentTypeDocumentAttribute : NSRTFTextDocumentType
        ]
        let attrStr = NSAttributedString(fileURL: rtfURL, options: options, documentAttributes: nil, error: nil)
        infoTextView.delegate = self
        infoTextView.attributedText = attrStr
        infoTextView.selectable = true
        infoTextView.delaysContentTouches = false
        infoTextView.invalidateIntrinsicContentSize()
        view.setNeedsUpdateConstraints()
        textViewHeightConstraint.constant = infoTextView.sizeThatFits(CGSizeMake(self.infoTextView.frame.size.width, CGFloat.max)).height + 220
    }
    
    override func viewWillAppear(animated: Bool) {
        println("WILL APPEAR")
    }
    
    //MARK: -
    //MARK: UITextViewDelegate Implementation
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        return true
    }
    
}