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
    
    @State private var isPlaylistSheetShowing = false
    private let playlistsKey = "cached_playlists"
    @State private var selection: Playlist?

    var body: some View {
        Group {
            if musicAuthorizationStatus == .authorized {
                NavigationSplitView {
                    List(playlists, id: \.self, selection: $selection) { playlist in
                        PlaylistRowView(playlist: playlist)
                            .contentShape(Rectangle())
                            .background(selection == playlist ? Color.gray.opacity(0.2) : Color.clear)
                    }
                    .listStyle(.plain)
                    .navigationTitle("Playlists")
                    .overlay {
                        if playlists.isEmpty {
                            ContentUnavailableView
                                .init {
                                    Text("Playlists loading...")
                                }
                        }
                    }
                } detail: {
                    if let selectedPlaylist = selection {
                        PlayBackView(playlist: selectedPlaylist)
                            .id(selectedPlaylist.id)
                    } else {
                        ContentUnavailableView {
                            Text("No playlist selected")
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
                if let cachedPlaylists = loadPlaylistsFromCache() {
                    self.playlists = cachedPlaylists
                }
            }
            
            await loadPlaylists()
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
        self.playlists = Array(playlists)
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
            let playlistArray = Array(libraryPlaylists)
            
            self.playlists = playlistArray
            
            // Cache the playlists
            try cachePlaylistsToUserDefaults(playlistArray)
        } catch {
            print(error.localizedDescription)
            setPlaylists(MusicItemCollection<Playlist>())
        }
    }
    
    private func cachePlaylistsToUserDefaults(_ playlists: [Playlist]) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(playlists)
        UserDefaults.standard.set(data, forKey: playlistsKey)
    }
    
    private func loadPlaylistsFromCache() -> [Playlist]? {
        guard let data = UserDefaults.standard.data(forKey: playlistsKey) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode([Playlist].self, from: data)
    }
}

#Preview {
    ContentView()
}
