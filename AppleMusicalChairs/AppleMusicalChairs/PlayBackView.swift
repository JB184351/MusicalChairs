//
//  PlayBackView.swift
//  AppleMusicalChairs
//
//  Created by Justin on 8/16/24.
//

import SwiftUI
import MusicKit

struct PlayBackView: View {
    @State var playlist: Playlist?
    @State private var playState: PlayState = .pause
    @State private var songTimer: Int = 0
    @State private var roundTimer: Int = 0
    @State private var isTimerActive = false
    @State private var volumeValue = VolumeObserver()
    @State private var isFirstPlay = true
    @State private var isDancing = false
    @State private var showSettings = false
    
    @AppStorage("isShuffled") private var isShuffled = true
    @AppStorage("currentSongTimer") private var currentSongTimer: Int = 30
    @AppStorage("currentRoundTimer") private var currentRoundTimer: Int = 5
    @AppStorage("isSongTimerRandom") private var isSongTimerRandom = false
    @AppStorage("isRoundTimerRandom") private var isRoundTimerRandom = false
    @AppStorage("isSongTimerDisplayed") private var isSongTimerDisplayed = false
    @AppStorage("isRoundTimerDisplayed") private var isRoundTimerDisplayed = false
    @AppStorage("shouldTimerResetOnSkip") private var shouldTimerResetOnSkip = false
    
    @State private var songTitle = ""
    @State private var songArtistName = ""
    @State private var songAlbumTitle = ""
    @State private var songArtwork: Artwork?
    @State private var songDuration = TimeInterval(0)
    
    @Environment(\.colorScheme) private var colorScheme
    
    private let player = ApplicationMusicPlayer.shared
    
    private var isPlaying: Bool {
        return (player.state.playbackStatus == .playing)
    }
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var speakerImage: String {
        switch volumeValue.volume * 100 {
        case 0...30.999:
            "speaker.wave.1"
        case 31...60.999:
            "speaker.wave.2"
        case 61...100:
            "speaker.wave.3"
        default:
            "speaker.wave.1"
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                DancingChairsView(isDancing: $isDancing)
                .padding()
                .accessibilityHidden(true)
                
                Spacer()
                
                // MARK: - Song Information
                SongInformationView(songArtwork: $songArtwork, songTitle: $songTitle, songAlbumTitle: $songAlbumTitle, songArtistName: $songArtistName)
                    .padding( )
                
                Spacer()
                
                // MARK: - Current Playback/Duration View
                DurationView(playbackTime: player.playbackTime, songDuration: $songDuration)
                
                Spacer()
                
                // MARK: - Volume Slider/SKip Button
                HStack {
                    Image(systemName: "speaker")
                        .accessibilityHidden(true)
                    
                    VolumeSliderView()
                    
                    Image(systemName: speakerImage)
                        .accessibilityHidden(true)
                }
                .frame(height: 15)
                .padding(.horizontal)
                
                Spacer()
                
                // MARK: - Song Timer
                if songTimer > 0 {
                    ZStack {
                        if isSongTimerDisplayed {
                            Text("Will pause in \(songTimer) \(songTimer == 1 ? "second" : "seconds").")
                                .fontWeight(.medium)
                        }
                    }
                    .onReceive(timer, perform: { time in
                        guard isTimerActive else { return }
                        
                        if songTimer > 0 {
                            songTimer -= 1
                            
                            isDancing.toggle()
                            
                            Task {
                                if !isPlaying {
                                    await playTrack()
                                    playState = .play
                                }
                            }
                        }
                    })
                } else {
                    // Round Timer
                    ZStack {
                        if isRoundTimerDisplayed {
                            Text("Next round starts in \(roundTimer) \(roundTimer == 1 ? "second" : "seconds").")
                                .fontWeight(.medium)
                        }
                    }
                    .onReceive(timer, perform: { time in
                        guard isTimerActive else { return }
                        
                        if roundTimer > 0 && songTimer == 0 {
                            player.pause()
                            roundTimer -= 1
                        } else if roundTimer == 0 {
                            resetTimers()
                        }
                    })
                }
                
                Button(action: {
                    Task {
                        await skipToNextSong()
                    }
                }, label: {
                    Text("Skip Song")
                        .frame(maxWidth: .infinity)
                })
                .buttonStyle(.borderedProminent)
                .padding()
                .font(.largeTitle)
                .tint(.purple)
                
                // Play/Pause Button
                Button(action: {
                    handlePlayButton()
                    isFirstPlay = false
                }, label: {
                    Text(playState == .play ? "Pause" : isFirstPlay ? "Play" : "Resume")
                        .frame(maxWidth: .infinity)
                })
                .buttonStyle(.borderedProminent)
                .padding()
                .font(.largeTitle)
                .tint(.red)
                .disabled(songTimer == 0)
                
                // Make Airplay Icon and Settings Icon bigger
                HStack {
                    AirPlayButtonView()
                        .frame(height: 50)
                        .tint(colorScheme == .dark ? .white : .black)
                }
            }
            .onAppear {
                songTimer = Int.random(in: 5...30)
                roundTimer = 5
                
                Task {
                    await loadPlaylistAndSetQueue()
                }
            }
            .onDisappear {
                player.stop()
                player.queue = []
                player.playbackTime = .zero
                player.queue.currentEntry = nil
            }
            .onChange(of: player.queue.currentEntry?.item) {
                switch player.queue.currentEntry?.item {
                case .song(let song):
                    self.songTitle = song.title
                    self.songArtistName = song.artistName
                    if let duration = song.duration, let albumTitle = song.albumTitle {
                        self.songDuration = duration
                        self.songAlbumTitle = albumTitle
                    }
                    self.songArtwork = song.artwork
                default:
                    break
                }
            }
            .onChange(of: playlist) {
                Task {
                    await loadPlaylistAndSetQueue()
                }
            }
            .sheet(isPresented: $showSettings) {
                Task {
                    playState = .play
                    await playTrack()
                    isTimerActive = true
                }
            } content: {
                SettingsView(songTimer: $currentSongTimer, roundTimer: $currentRoundTimer, isSongTimerRandom: $isSongTimerRandom, isRoundTimerRandom: $isRoundTimerRandom, isSongTimerDisplayed: $isSongTimerDisplayed, isRoundTimerDisplayed: $isRoundTimerDisplayed, playlist: $playlist, isShuffled: $isShuffled, shouldTimerResetOnSkip: $shouldTimerResetOnSkip)
            }
            .toolbar {
                Button(action: {
                    showSettings = true
                    player.pause()
                    playState = .pause
                    isTimerActive = false
                }) {
                    Image(systemName: "gear")
                        .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
                        .font(.system(size: 20))
                }
            }
            
        }
    }
    
    private func handlePlayButton() {
        Task {
            if isPlaying {
                player.pause()
                playState = .pause
                isTimerActive = false
            } else {
                playState = .play
                await playTrack()
                isTimerActive = true
            }
        }
    }
    
    @MainActor
    private func playTrack() async {
        do {
            try await player.play()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func skipToNextSong() async {
        if shouldTimerResetOnSkip {
            resetTimers()
        }
        
        do {
            try await player.skipToNextEntry()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func resetTimers() {
        if isSongTimerRandom {
            songTimer = Int.random(in: 5...45)
        } else {
            songTimer = currentSongTimer
        }
        
        if isRoundTimerRandom {
            roundTimer = Int.random(in: 5...15)
        } else {
            roundTimer = currentRoundTimer
        }
    }
    
    @MainActor
    private func loadPlaylistAndSetQueue() async {
        if let playlist = playlist {
            do {
                let detailedPlaylist = try await playlist.with([.entries])
                if let entries = detailedPlaylist.entries {
                    player.state.shuffleMode = isShuffled ? .songs : .off
                    
                    if let firstSong = isShuffled ? entries.randomElement() : entries.first {
                        player.queue = .init(playlist: detailedPlaylist, startingAt: firstSong)
                        
                        songTitle = firstSong.title
                        songArtistName = firstSong.artistName
                        songAlbumTitle = firstSong.albumTitle ?? "Album Title Not Found"
                        songArtwork = firstSong.artwork
                        songDuration = firstSong.duration ?? 0
                    }
                }
            } catch {
                print("Failed to load playlist entries: \(error.localizedDescription)")
            }
        }
    }
}

//#Preview {
//    PlayBackView()
//}
