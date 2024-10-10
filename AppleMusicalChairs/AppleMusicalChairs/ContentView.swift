//
//  ContentView.swift
//  AppleMusicalChairs
//
//  Created by Justin on 8/13/24.
//

import SwiftUI
import MusicKit

struct ContentView: View {
    @Environment(\.openURL) private var openURL
    @State var musicAuthorizationStatus: MusicAuthorization.Status
    @State private var arePlaylistsShowing = false
    @State var playlists = [Playlist]()
    
    @State private var selection: Playlist? = nil
    @State private var isPlaylistSheetShowing = false
    
    var body: some View {
        Group {
            if musicAuthorizationStatus == .authorized {
                NavigationStack {
                    List(playlists, id: \.self, selection: $selection) { playlist in
                        NavigationLink(destination: PlayListTracksView(playlist: playlist)) {
                            PlaylistRowView(playlist: playlist)
                        }
                    }
                    .listStyle(.plain)
                    .navigationTitle("Playlists")
                    .overlay {
                        if playlists.isEmpty {
                            if #available(iOS 17.0, *) {
                                ContentUnavailableView
                                    .init {
                                        Text("Playlists loading...")
                                    }
                            } else {
                                // Fallback on earlier versions
                                Text("Playlist loading...")
                            }
                        }
                    }
                }
            } else {
                AppleMusicPermissionView()
            }
        }
        .task {
            await checkAuthorization()
            
            if musicAuthorizationStatus == .authorized {
                await loadPlaylists()
            }
        }
    }
    
    // MARK: - Initializers
    public init(musicAuthorizationStatus: MusicAuthorization.Status = MusicAuthorization.currentStatus) {
        _musicAuthorizationStatus = .init(initialValue: musicAuthorizationStatus)
    }
    
    @MainActor
    private func update(with musicAuthorizationStatus: MusicAuthorization.Status) {
        withAnimation {
            self.musicAuthorizationStatus = musicAuthorizationStatus
        }
    }
    
    @MainActor
    private func setPlaylists(_ playlists: MusicItemCollection<Playlist>) {
        withAnimation {
            self.playlists = Array(playlists)
        }
    }
    
    @MainActor
    private func checkAuthorization() async {
        switch musicAuthorizationStatus {
        case .notDetermined:
            let musicAuthorizationStatus = await MusicAuthorization.request()
            update(with: musicAuthorizationStatus)
        case .denied:
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                openURL(settingsURL)
            }
        case .authorized:
            update(with: .authorized)
        default:
            break
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
            print(error.localizedDescription)
            setPlaylists(MusicItemCollection<Playlist>())
        }
    }
}

#Preview {
    ContentView()
}
