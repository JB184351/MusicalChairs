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
            AsyncImage(url: playlist?.artwork?.url(width: 100, height: 100)) { image in
                image
                    .resizable()
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1.0, contentMode: .fit)
            } placeholder: {
                Image(systemName: "music.note.list")
                    .resizable()
                    .frame(width: 100, height: 100)
            }
            
            
            Text(playlist?.name ?? "Unknown Playlist Name")
            
            Text("\(playlistSongs?.count ?? 0)")
            
            List(playlistSongs ?? [], id: \.self) { song in
                NavigationLink(destination: PlayBackView(song: song)) {
                    HStack {
                        AsyncImage(url: song.artwork?.url(width: 50, height: 50)) { image in
                            image
                                .resizable()
                                .frame(maxWidth: .infinity)
                                .aspectRatio(1.0, contentMode: .fit)
                        } placeholder: {
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
