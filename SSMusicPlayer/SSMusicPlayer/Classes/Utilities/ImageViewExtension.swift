//
//  ImageViewExtension.swift
//  SSMusicPlayer
//
//  Created by Santosh Kumar Sahoo on 5/23/17.
//
//

import Foundation
import UIKit
import SDWebImage

extension UIImageView {
    
    /// Call this method to set image of an image view if the image url is nil then placeholder image will set.
    ///
    /// - Parameter urlPath: image url
    func setImageFromUrlPath(_ urlPath: String?) {
        if let urlPath = urlPath {
            setImageFromUrlPath(urlPath, withConstrainedWidth: frame.size.width, layout: true, handler: nil)
        } else {
            //Url is nil so set the place holder image
            image = UIImage(named: "placeholder_image")
        }
    }
    
    
    /// Use this method to set image frome a url.
    ///
    /// - Parameters:
    ///   - urlPath: url string
    ///   - width: width of image
    ///   - layout: to handle activityindicator layout
    ///   - handler: completion handler
    func setImageFromUrlPath(_ urlPath: String, withConstrainedWidth width: CGFloat, layout:Bool, handler: SDWebImageCompletionBlock?) {
        viewWithTag(564)?.removeFromSuperview()
        let activityIndicatorView = UIActivityIndicatorView.init(activityIndicatorStyle: .gray)
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.center = CGPoint(x: width * 0.5, y: frame.size.height * 0.5)
        activityIndicatorView.startAnimating()
        activityIndicatorView.tag = 564
        if layout {
            activityIndicatorView.autoresizingMask = UIViewAutoresizing.flexibleLeftMargin
        }
        addSubview(activityIndicatorView)
        
        self.sd_setImage(with: URL(string: urlPath), completed:
            {(image: UIImage?, error: Error?, cacheType: SDImageCacheType, url: URL?) -> Void in
                activityIndicatorView.stopAnimating()
                activityIndicatorView.removeFromSuperview()
                
                if let completionHandler = handler {
                    completionHandler(image, error, cacheType, url)
                }
        })
    }
}
