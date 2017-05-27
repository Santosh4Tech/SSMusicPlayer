//
//  MusicTrackCell.swift
//  SSMusicPlayer
//
//  Created by Santosh Kumar Sahoo on 5/22/17.
//
//

import UIKit

class MusicTrackCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layoutIfNeeded()
    }

    override func prepareForReuse() {
        iconImageView.image = nil
        songNameLabel.text = nil
        artistLabel.text = nil
    }
    
    class func getCellIdentifier() -> String {
        return "MusicTrackCell"
    }
    
    func configureCellWith(_ song: Song?) {
        if let song = song {
            songNameLabel.text = song.name
            artistLabel.text = song.artist
            iconImageView.setImageFromUrlPath(song.iconUrl)
        }
    }


}
