//
//  Song.swift
//  SSMusicPlayer
//
//  Created by Santosh Kumar Sahoo on 5/21/17.
//
//

import Foundation

class Song {
    var name: String?
    var iconUrl: String?
    var songUrl: String?
    var artist: String?
    var duration = 0 // in sec
    init(dictionary: [String:Any]?) {
        if let sonDic = dictionary {
            if let imageArray = sonDic["im:image"] as? [[String:Any]]{
                iconUrl = imageArray.last?["label"] as? String
            }
            if let nameDic = sonDic["im:name"] as? [String:String] {
               name = nameDic["label"]
            }
            if let linkDic = sonDic["link"] as? [[String:Any]] {
                if let attribute = linkDic.last?["attributes"] as? [String:String] {
                    songUrl = attribute["href"]
                }
            }
            if let artistDic = sonDic["im:artist"] as? [String:Any] {
                    artist = artistDic["label"] as? String
            }
            if let linkDic = sonDic["link"] as? [[String:Any]] {
                if let durationDic = linkDic.last?["im:duration"] as? [String:String] {
                    if let duration = durationDic["label"], let durationInt = Int(duration) {
                        self.duration = durationInt/1000
                    }
                }
            }
        }
        
    }
}
