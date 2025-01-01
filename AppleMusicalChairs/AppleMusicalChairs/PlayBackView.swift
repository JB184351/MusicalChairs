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
    @AppStorage("isShuffled") var isShuffled = true
    @State private var playState: PlayState = .pause
    @State private var songTimer: Int = 0
    @State private var roundTimer: Int = 0
    @State private var currentSongTimer: Int = 30
    @State private var currentRoundTimer: Int = 5
    @State private var isTimerActive = false
    @State private var volumeValue = VolumeObserver()
    @State private var isFirstPlay = true
    @State private var isDancing = false
    @State private var showSettings = false
    
    @State private var isSongTimerRandom = false
    @State private var isRoundTimerRandom = false
    @State private var isSongTimerDisplayed = false
    @State private var isRoundTimerDisplayed = false
    
    @State private var songTitle = ""
    @State private var songArtistName = ""
    @State private var songAlbumTitle = ""
    @State private var songArtwork: Artwork?
    @State private var songDuration = TimeInterval(0)
    
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
                HStack(spacing: 50) {
                    Image(systemName: "music.note")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(isDancing ? 15 : -15))
                        .scaleEffect(1.0)
                        .offset(x: isDancing ? 10 : -10, y: 0)
                        .foregroundStyle(.red)
                    
                    Image(systemName: "chair")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(isDancing ? 15 : -15))
                        .scaleEffect(1.0)
                        .offset(x: isDancing ? 10 : -10, y: 0)
                        .foregroundStyle(.red)
                    
                    Image(systemName: "chair")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(isDancing ? 15 : -15))
                        .scaleEffect(1.0)
                        .offset(x: isDancing ? 10 : -10, y: 0)
                        .foregroundStyle(.red)
                    
                    Image(systemName: "music.note")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(isDancing ? 15 : -15))
                        .scaleEffect(1.0)
                        .offset(x: isDancing ? 10 : -10, y: 0)
                        .foregroundStyle(.red)
                }
                .padding()
                
                Spacer()
                
                // MARK: - Song Information
                
                // Album Cover
                HStack(spacing: 20) {
                    if let artwork = songArtwork {
                        ArtworkImage(artwork, height: 100)
                    } else {
                        Image(systemName: "music.note")
                            .resizable()
                            .frame(width: 100, height: 100)
                    }
                    
                    VStack(alignment: .leading) {
                        // Song Title
                        Text(songTitle)
                            .font(.title2)
                            .fontWeight(.bold)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        // Album Title
                        Text(songAlbumTitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        // Artist Name
                        Text(songArtistName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding()
                
                Spacer()
                
                // MARK: - Current Playback/Duration View
                
                // Progress View
                ProgressView(value: player.playbackTime, total: songDuration)
                    .progressViewStyle(.linear)
                    .tint(.red.opacity(0.5))
                    .padding(.horizontal)
                
                // Duration View
                HStack {
                    Text(durationStr(from: player.playbackTime))
                        .font(.caption)
                    
                    Spacer()
                    
                    Text(durationStr(from: songDuration))
                        .font(.caption)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // MARK: - Volume Slider/SKip Button
                
                HStack {
                    Image(systemName: "speaker")
                    
                    VolumeSliderView()
                    
                    Image(systemName: speakerImage)
                }
                .frame(height: 15)
                .padding(.horizontal)
                
                Spacer()
                
                Button {
                    Task {
                        await skipToNextSong()
                    }
                } label: {
                    Label("", systemImage: "forward.fill")
                        .tint(.white)
                }
                
                Spacer()
                
                // Song Timer
                if songTimer > 0 {
                    ZStack {
                        if isSongTimerDisplayed {
                            Text("Will pause in \(songTimer) seconds.")
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
                            Text("Next round starts in \(roundTimer) seconds.")
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
                
                // Make Airplay Icon and Settings Icon bigger
                HStack {
                    AirPlayButtonView()
                        .frame(height: 50)
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
                SettingsView(songTimer: $currentSongTimer, roundTimer: $currentRoundTimer, isSongTimerRandom: $isSongTimerRandom, isRoundTimerRandom: $isRoundTimerRandom, isSongTimerDisplayed: $isSongTimerDisplayed, isRoundTimerDisplayed: $isRoundTimerDisplayed, playlist: $playlist, isShuffled: $isShuffled)
            }
            .toolbar {
                Button(action: {
                    showSettings = true
                    player.pause()
                    playState = .pause
                    isTimerActive = false
                }) {
                    Image(systemName: "gear")
                        .foregroundStyle(.red)
                        .font(.system(size: 18))
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
        do {
            try await player.skipToNextEntry()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func durationStr(from duration: TimeInterval) -> String {
        let seconds = Int(duration)
        let minutes = seconds / 60
        let remainder = seconds % 60
        
        // Format the string to ensure two digits for the remainder (seconds)
        return String(format: "%d:%02d", minutes, remainder)
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
