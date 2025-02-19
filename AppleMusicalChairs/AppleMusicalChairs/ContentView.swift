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
    @Environment(\.colorScheme) private var colorScheme
    @State var musicAuthorizationStatus: MusicAuthorization.Status
    @State private var arePlaylistsShowing = false
    @State var playlists = [Playlist]()
    @State private var musicSubscription: MusicSubscription?
    @State private var offerOptions: MusicSubscriptionOffer.Options = .default
    @State private var selection: Playlist? = nil
    @State private var isPlaylistSheetShowing = false
    @State private var isSubscriptionSheetShowing = false
    @State private var isLoadingPlaylists = true
    
    private let playlistsKey = "cached_playlists"
    private var shouldOffersMusicSubscription: Bool {
        guard let currentmusicSubscription = musicSubscription else { return true }
        return !currentmusicSubscription.canPlayCatalogContent
    }
    
    var body: some View {
        Group {
            if musicAuthorizationStatus == .authorized {
                NavigationStack {
                    List(playlists, id: \.self, selection: $selection) { playlist in
                        NavigationLink(destination: PlayBackView(playlist: playlist)) {
                            PlaylistRowView(playlist: playlist)
                        }
                    }
                    .listStyle(.plain)
                    .navigationTitle("Playlists")
                    .overlay {
                        if playlists.isEmpty {
                            if isLoadingPlaylists {
                                ProgressView("Loading Playlists...")
                            } else {
                                ContentUnavailableView {
                                    Label {
                                        Text(shouldOffersMusicSubscription ? "Apple Music Subscription Required" : "No Playlists Found")
                                    } icon: {
                                        Image(colorScheme == .dark ? "Apple_Music_Icon" : "Apple_Music_Icon_Dark")
                                            .resizable()
                                            .frame(width: 90, height: 90)
                                            .shadow(color: .gray.opacity(0.3), radius: 16)
                                            .padding(.bottom, 12)
                                    }
                                    .padding(.bottom, 24)
                                    
                                } actions: {
                                    if shouldOffersMusicSubscription {
                                        Button {
                                            isSubscriptionSheetShowing = true
                                        } label: {
                                            Text("Subscribe to Apple Music")
                                                .font(.title3)
                                                .padding(4)
                                        }
                                        .buttonStyle(.borderedProminent)
                                        .tint(.red)
                                        
                                    } else {
                                        Button("Create a Playlist") {
                                            openMusicApp()
                                        }
                                        .buttonStyle(.borderedProminent)
                                        .tint(.red)
                                    }
                                }
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
                await checkSubscriptionStatus()
                
                if let cachedPlaylists = loadPlaylistsFromCache() {
                    self.playlists = cachedPlaylists
                } else {
                    await loadPlaylists()
                }
                
                try? await Task.sleep(for: .seconds(2))
                isLoadingPlaylists = false
            }
        }
        .musicSubscriptionOffer(isPresented: $isSubscriptionSheetShowing, options: offerOptions)
        .refreshable {
            isLoadingPlaylists = true
            await loadPlaylists()
            isLoadingPlaylists = false
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
    private func checkSubscriptionStatus() async {
        do {
            musicSubscription = try await MusicSubscription.current
            if shouldOffersMusicSubscription {
                isSubscriptionSheetShowing = true
            }
        } catch {
            print("Failed to fetch subscription status: \(error)")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                isSubscriptionSheetShowing = true
            }
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
            let playlistArray = Array(libraryPlaylists)
            
            self.playlists = playlistArray
            
            // Cache the playlists
            try cachePlaylistsToUserDefaults(playlistArray)
        } catch {
            print(error.localizedDescription)
            setPlaylists(MusicItemCollection<Playlist>())
        }
    }
    
    private func openMusicApp() {
        if let musicURL = URL(string: "music://") {
            openURL(musicURL)
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
