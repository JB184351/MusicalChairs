//
//  SettingsView.swift
//  AppleMusicalChairs
//
//  Created by Justin on 10/17/24.
//

import SwiftUI
import MusicKit

struct SettingsView: View {
    @Binding var songTimer: Int
    @Binding var roundTimer: Int
    @Binding var isSongTimerRandom: Bool
    @Binding var isRoundTimerRandom: Bool
    @Binding var isSongTimerDisplayed: Bool
    @Binding var isRoundTimerDisplayed: Bool
    @Binding var playlist: Playlist?
    @State private var playlists: [Playlist] = []
    
    var body: some View {
        Form {
            Section(header: Text("Song Timer")) {
                Slider(value: Binding(get: {
                    Double(songTimer)
                }, set: {
                    songTimer = Int($0)
                }), in: 5...45, step: 1) {
                    Text("Song Timer")
                } minimumValueLabel: {
                    Text("1")
                } maximumValueLabel: {
                    Text("45")
                }
                Text("\(songTimer) seconds")
            }
            
            Section(header: Text("Round Timer")) {
                Slider(value: Binding(get: {
                    Double(roundTimer)
                }, set: {
                    roundTimer = Int($0)
                }), in: 5...15, step: 1) {
                    Text("Round Timer")
                } minimumValueLabel: {
                    Text("5")
                } maximumValueLabel: {
                    Text("15")
                }
                Text("\(roundTimer) seconds")
            }
            
            Section(
                header: Text("Random Timer Options"),
                footer: Text("""
                             Song Timer Will Be Between 5-45 Seconds
                             Round Timer Will Be Between 5-15 Seconds
                            """)
            ) {
                Toggle("Random Song Timer", isOn: $isSongTimerRandom)
                Toggle("Random Round Timer", isOn: $isRoundTimerRandom)
            }
            
            Section() {
                Toggle("Song Timer Display", isOn: $isSongTimerDisplayed)
                Toggle("Round Timer Display", isOn: $isRoundTimerDisplayed)
            } header: {
                Text("Timer Display Options")
            } footer: {
                Text("This will show the remaining time the song or round has left")
            }
            
            Section(header: Text("Playlist Selection")) {
                if playlists.isEmpty {
                    Text("Playlists are loading or not available")
                        .foregroundColor(.secondary)
                } else {
                    Picker("Select Playlist", selection: $playlist) {
                        Text("None").tag(Optional<Playlist>.none)
                        ForEach(playlists, id: \.id) { playlist in
                            Text(playlist.name).tag(Optional(playlist))
                        }
                    }
                }
            }
        }
        .task {
            await loadPlaylists()
        }

    }
    
    @MainActor
    private func loadPlaylists() async {
        do {
            let url = URL(string: "https://api.music.apple.com/v1/me/library/playlists")!
            let libraryPlaylistRequest = MusicDataRequest(urlRequest: URLRequest(url: url))
            let libraryPlaylistResponse = try await libraryPlaylistRequest.response()
            
            let decoder = JSONDecoder()
            let libraryPlaylists = try decoder.decode(MusicItemCollection<Playlist>.self, from: libraryPlaylistResponse.data)
            setPlaylists(libraryPlaylists)
        } catch {
            setPlaylists(MusicItemCollection<Playlist>())
        }
    }
    
    @MainActor
    private func setPlaylists(_ playlists: MusicItemCollection<Playlist>) {
        withAnimation {
            self.playlists = Array(playlists)
        }
    }


}

//#Preview {
//    SettingsView(songTimer: .constant(30), roundTimer: .constant(60))
//}

