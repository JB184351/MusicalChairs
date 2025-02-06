//
//  SongInformationView.swift
//  AppleMusicalChairs
//
//  Created by Justin on 2/5/25.
//

import SwiftUI
import MusicKit

struct SongInformationView: View {
    @Binding var songArtwork: Artwork?
    @Binding var songTitle: String
    @Binding var songAlbumTitle: String
    @Binding var songArtistName: String
    
    var body: some View {
        HStack(spacing: 20) {
            if let artwork = songArtwork {
                ArtworkImage(artwork, height: 150)
                    .accessibilityHidden(true)
            } else {
                Image(systemName: "music.note")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .accessibilityHidden(true)
            }
            
            VStack(alignment: .leading) {
                // Song Title
                Text(songTitle)
                    .font(.title2)
                    .fontWeight(.bold)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Album Title
                Text(songAlbumTitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Artist Name
                Text(songArtistName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(songTitle) by \(songArtistName) from \(songAlbumTitle)")
        }
    }
}
