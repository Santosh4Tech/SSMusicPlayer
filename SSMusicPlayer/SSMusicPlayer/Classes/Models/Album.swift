//
//  Album.swift
//  SSMusicPlayer
//
//  Created by Santosh Kumar Sahoo on 5/21/17.
//
//

import Foundation

class Album {
    
    var title: String?
    var songs = [Song]()
    
    init(dictionary: [String:Any]?) {
        if let titleDic = dictionary?["title"] as? [String:String] {
            title = titleDic["label"]
        }
        if let songsDic = dictionary?["entry"] as? [[String:Any]] {
            for songDic in songsDic {
                let song = Song(dictionary: songDic)
                songs.append(song)
            }
        }
    }
    
}
