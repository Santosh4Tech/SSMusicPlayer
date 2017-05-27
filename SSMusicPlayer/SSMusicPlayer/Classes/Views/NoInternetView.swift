//
//  NoInternetView.swift
//  SSMusicPlayer
//
//  Created by Santosh Kumar Sahoo on 5/26/17.
//
//

import UIKit

protocol NoInternetDelegate : class {
    func noInternetView(_ view: UIView?, didSelectRefreshButton isTapped: Bool)
}

class NoInternetView: UIView {

    @IBOutlet weak var refreshButton: UIButton!
    
    weak fileprivate var delegate: NoInternetDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        refreshButton.layer.borderColor = UIColor(red: 0, green: 186, blue: 242, alpha: 1).cgColor
        refreshButton.layer.borderWidth = 1
    }
    
    class func getNoInternetView(with delegate: NoInternetDelegate?) -> NoInternetView? {
        if let nib = UINib(nibName: "NoInternetView", bundle: nil).instantiate(withOwner: self, options: nil).first as? NoInternetView {
            nib.delegate = delegate
            return nib
        }
        return nil
    }
    
    func showView(_ parentView: UIView?) {
        if let parentView = parentView {
            parentView.addSubview(self)
            frame = parentView.frame
        }
    }
    
    func hideView() {
        removeFromSuperview()
    }
    
    @IBAction func didTapRefreshButton(_ sender: UIButton) {
        delegate?.noInternetView(self, didSelectRefreshButton: true)
    }
}
