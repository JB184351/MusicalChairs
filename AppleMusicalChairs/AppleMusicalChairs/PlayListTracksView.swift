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
    @State private var playlistSongs: [Track]? = []
    @State private var isPlayBackPresented = false
    @State private var isShuffled = false
    
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
            
            Text("\(playlistSongs?.count ?? 0) songs")
            
            HStack(spacing: 50) {
                Button {
                    isPlayBackPresented = true
                } label: {
                    Label("Play All", systemImage: "play.fill")
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .padding()
                
                Button {
                    isPlayBackPresented = true
                    isShuffled = true
                } label: {
                    Label("Shuffle", systemImage: "shuffle")
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .padding()
            }
            .sheet(isPresented: $isPlayBackPresented) {
                if let songs = playlistSongs {
                    if let song = songs.first {
                        PlayBackView(song: song, songs: $playlistSongs, isShuffled: $isShuffled)
                    }
                }
            }
            
            List(playlistSongs ?? [], id: \.self) { song in
                NavigationLink(destination: PlayBackView(song: song, songs: $playlistSongs, isShuffled: $isShuffled)) {
                    HStack {
                        if let artwork = song.artwork {
                            ArtworkImage(artwork, height: 50)
                        } else {
                            Image(systemName: "music.note")
                                .resizable()
                                .frame(width: 50, height: 50)
                        }
                        
                        VStack(alignment: .leading) {
                            Text(song.title)
                            
                            Text(song.artistName)
                                .font(.caption)
                        }
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
