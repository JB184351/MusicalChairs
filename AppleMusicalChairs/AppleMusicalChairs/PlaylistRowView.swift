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
            AsyncImage(url: playlist.artwork?.url(width: 100, height: 100)) { image in
                image
                    .resizable()
                    .aspectRatio(1.0, contentMode: .fit)
            } placeholder: {
                Image(systemName: "music.note.list")
                    .resizable()
                    .frame(width: 100, height: 100)
            }
            
            Text(playlist.name)
        }
    }
}

//#Preview {
//    PlaylistView()
//}
