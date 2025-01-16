//
//  SongInformationView.swift
//  AppleMusicalChairs
//
//  Created by Justin on 1/16/25.
//

import SwiftUI
import MusicKit

struct SongInformationView: View {
    @Binding var songTitle: String
    @Binding var songAlbumTitle: String
    @Binding var songArtistName: String
    @Binding var songArtwork: Artwork?
    
    var body: some View {
        // Album Cover
        HStack(spacing: 20) {
            if let artwork = songArtwork {
                ArtworkImage(artwork, height: 150)
            } else {
                Image(systemName: "music.note")
                    .resizable()
                    .frame(width: 100, height: 100)
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
        }
        .padding()
    }
}

//#Preview {
//    SongInformationView()
//}
