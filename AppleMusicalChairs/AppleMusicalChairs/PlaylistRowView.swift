//
//  PlaylistView.swift
//  AppleMusicalChairs
//
//  Created by Justin on 8/16/24.
//

import SwiftUI
import MusicKit

struct PlaylistRowView: View {
    
    var playlist: Playlist
    
    var body: some View {
        HStack {
            if let artwork = playlist.artwork {
                ArtworkImage(artwork, height: 100)
            } else {
                Image(systemName: "music.note.list")
                    .resizable()
                    .frame(width: 100, height: 100)
            }
            
            Text(playlist.name)
        }
    }
}

//#Preview {
//    PlaylistRowView()
//}
