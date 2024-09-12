//
//  PlayListTracksView.swift
//  AppleMusicalChairs
//
//  Created by Justin on 8/23/24.
//

import SwiftUI
import MusicKit

struct PlayListTracksView: View {
    @State var playlist: Playlist?
    @State private var playlistSongs: [Track]?
    
    var body: some View {
        VStack {
            if let artwork = playlist?.artwork {
                ArtworkImage(artwork, height: 200)
            } else {
                Image(systemName: "music.note.list")
                    .resizable()
                    .frame(width: 200, height: 200)
            }
            
            
            Text(playlist?.name ?? "Unknown Playlist Name")
            
            Text("\(playlistSongs?.count ?? 0)")
            
            List(playlistSongs ?? [], id: \.self) { song in
                NavigationLink(destination: PlayBackView(song: song)) {
                    HStack {
                        if let artwork = song.artwork {
                            ArtworkImage(artwork, height: 50)
                        } else {
                            Image(systemName: "music.note")
                                .resizable()
                                .frame(width: 50, height: 50)
                        }
                        
                        Text(song.title)
                    }
                }
            }
        }
        .task {
            await loadTracks()
        }
        
    }
    
    @MainActor
    private func loadTracks() async {
        guard let playlist = playlist else { return }
        
        do {
            let detailedPlaylist = try await playlist.with([.tracks])
            let tracks = detailedPlaylist.tracks ?? []
            setTracks(tracks)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @MainActor
    private func setTracks(_ tracks: MusicItemCollection<Track>) {
        playlistSongs = Array(tracks)
    }
}

#Preview {
    PlayListTracksView()
}
