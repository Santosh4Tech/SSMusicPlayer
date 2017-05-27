//
//  MainActivityIndicatorView.swift
//  SSMusicPlayer
//
//  Created by Santosh Kumar Sahoo on 5/24/17.
//
//

import UIKit

/// Use this view when any task need a delay. ex: while fetching data from server use this view so that user will observ that somthing is going on
class MainActivityIndicatorView: UIView {
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        activityIndicatorView?.stopAnimating()
    }
    
    class func getMainActivityIndicatorView() -> MainActivityIndicatorView? {
        if let nib = UINib(nibName: "MainActivityIndicatorView", bundle: Bundle.main).instantiate(withOwner: nil, options: nil).first as? MainActivityIndicatorView {
            return nib
        }
        return nil
    }
    
    func showView(_ parentView: UIView?) {
        if let parentView = parentView {
            parentView.addSubview(self)
            frame = parentView.frame
            activityIndicatorView?.startAnimating()
        }
    }
    
    func hideView() {
        activityIndicatorView?.stopAnimating()
        removeFromSuperview()
    }
}
