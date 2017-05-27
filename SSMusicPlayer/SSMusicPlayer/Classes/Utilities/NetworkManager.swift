//
//  NetworkManager.swift
//  SSMusicPlayer
//
//  Created by Santosh Kumar Sahoo on 5/21/17.
//
//

import Foundation
import SystemConfiguration

var ErrorCodeJsonError = 1980
var albumUrl = "https://itunes.apple.com/in/rss/topsongs/limit=100/json"
var Error_Code_NoInternet_Connection = 1230


/// Use this class to implement any network related task.
class NetworkManager {
    
    
    /// Call this method to get JSON data from a url.
    ///
    /// - Parameters:
    ///   - urlString: url string
    ///   - handler: completion handler will execute,once fetch completed
    class func fetchJsonData(from urlString: String?, completionHandler handler: ((_ jsonResult: Any?, _ error: NSError?)-> Void)?) {
        if NetworkManager.isConnectedToNetwork() {
            fetchData(from: urlString) { (_ data: Data?, _ error: Error?) in
                var jsonResult : Any?
                var jsonError : Error?
                do {
                    if let data = data {
                        jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
                    }
                } catch {
                    jsonError = NSError.init(domain: NSLocalizedString("Data display error", comment: ""), code: ErrorCodeJsonError, userInfo: [NSLocalizedDescriptionKey:"Something went wrong while fetching data" ])
                }
                handler?(jsonResult, jsonError as NSError?)
            }
        } else {
            let noInternetError = NSError(domain:"Error!", code: Error_Code_NoInternet_Connection, userInfo: ["NSLocalizedDescription": "No internet connection"])
            handler?(nil, noInternetError)
        }
    }
    
    
    /// Call this method to get content of a url as Data format.
    ///
    /// - Parameters:
    ///   - urlString: url string
    ///   - handler: completion handler will execute,once fetch completed
    class func fetchData(from urlString: String?, completionHandler handler: ((_ jsonResult: Data?, _ error: NSError?)-> Void)?) {
        if NetworkManager.isConnectedToNetwork() {
            if let urlString = urlString, let url = URL(string: urlString) {
                let session = URLSession.shared
                let dataTask = session.dataTask(with: url, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
                    if let data = data {
                        DispatchQueue.main.async {
                            handler?(data, error as NSError?)
                        }
                    }
                })
                dataTask.resume()
            }
        } else {
            let noInternetError = NSError(domain:"Error!", code: Error_Code_NoInternet_Connection, userInfo: ["NSLocalizedDescription": "No internet connection"])
            handler?(nil, noInternetError)
        }
    }
    
    /// To get music album call this method , curently url is hardcoded
    ///
    /// - Parameter handler: completion handler
    class func getAlbumWith(completionHandler handler: @escaping ((_ album: Album?, _ error: NSError?)-> Void)) {
        fetchJsonData(from: albumUrl) { (jsonResult: Any?, error: Error?) in
            if let error = error {
                handler(nil, error as NSError?)
            } else if let jsonResult = jsonResult as? [String: Any] {
                if let feedDic = jsonResult["feed"] as? [String: Any] {
                    let album = Album(dictionary: feedDic)
                    handler(album,nil)
                }
            }
        }
    }
    
    /// Call this method before doing any network operation
    ///
    /// - Returns: it will return whether internet connection is exist or not in device
    class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        
        return isReachable && !needsConnection
        
    }
}
