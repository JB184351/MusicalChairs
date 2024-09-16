//
//  PlayBackView.swift
//  AppleMusicalChairs
//
//  Created by Justin on 8/16/24.
//

import SwiftUI
import MusicKit

struct PlayBackView: View {
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.openURL) private var openURL
    
    @State var song: Track
    @State private var playState: PlayState = .pause
    @State private var songTimer: Int = Int.random(in: 5...30)
    @State private var roundTimer: Int = 10
    @State private var isTimerActive = false
    @State private var volumeValue = VolumeObserver()
    @State private var scale = 1.0
    @State private var isFirstPlay = true
    @State private var isDancing = false
    
    private let player = ApplicationMusicPlayer.shared
    
    private var isPlaying: Bool {
        return (player.state.playbackStatus == .playing)
    }
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var playPauseImage: String {
        switch playState {
        case .play:
            "pause.fill"
        case .pause:
            "play.fill"
        }
    }
    
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
        VStack {
            HStack(spacing: 50) {
                Image(systemName: "music.note")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(isDancing ? 15 : -15))
                    .scaleEffect(1.0)
                    .offset(x: isDancing ? 10 : -10, y: 0)
                
                Image(systemName: "chair")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(isDancing ? 15 : -15))
                    .scaleEffect(1.0)
                    .offset(x: isDancing ? 10 : -10, y: 0)
                
                Image(systemName: "chair")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(isDancing ? 15 : -15))
                    .scaleEffect(1.0)
                    .offset(x: isDancing ? 10 : -10, y: 0)
                
                Image(systemName: "music.note")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(isDancing ? 15 : -15))
                    .scaleEffect(1.0)
                    .offset(x: isDancing ? 10 : -10, y: 0)
            }
            .padding()
            
            Spacer()
            
            // Album Cover
            HStack(spacing: 20) {
                if let artwork = song.artwork {
                    ArtworkImage(artwork, height: 100)
                } else {
                    Image(systemName: "music.note")
                        .resizable()
                        .frame(width: 100, height: 100)
                }
                
                VStack(alignment: .leading) {
                    // Song Title
                    Text(song.title)
                        .font(.title)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Album Title
                    Text(song.albumTitle ?? "Album Title Not Found")
                        .font(.caption)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Artist Name
                    Text(song.artistName)
                        .font(.caption)
                }
            }
            .padding()
            
            Spacer()
            
            // Progress View
            ProgressView(value: player.playbackTime, total: song.duration ?? 1.00)
                .progressViewStyle(.linear)
                .tint(.red.opacity(0.5))
            
            // Duration View
            HStack {
                Text(durationStr(from: player.playbackTime))
                    .font(.caption)
                
                Spacer()
                
                if let duration = song.duration {
                    Text(durationStr(from: duration))
                        .font(.caption)
                }
            }
            
            Spacer()
            
            // Volume Slider Control
            HStack {
                Image(systemName: "speaker")
                
                VolumeSliderView()
                
                Image(systemName: speakerImage)
            }
            .frame(height: 15)
            
            Spacer()
            
            // Song Timer
            if songTimer > 0 {
                ZStack {
                    Text("Will pause in \(songTimer) seconds.")
                        .fontWeight(.medium)
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
                    Text("Next round starts in \(roundTimer) seconds.")
                        .fontWeight(.medium)
                }
                .onReceive(timer, perform: { time in
                    guard isTimerActive else { return }
                    
                    if roundTimer > 0 && songTimer == 0 {
                        player.pause()
                        roundTimer -= 1
                    } else if roundTimer == 0 {
                        songTimer = Int.random(in: 5...30)
                        roundTimer = 10
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
            .scaleEffect(scale)
            .animation(.linear(duration: 1), value: scale)
            
            AirPlayButtonView()
                .frame(height: 50)
        }
        .padding()
        .onAppear {
            player.queue = [song]
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
    
    private func durationStr(from duration: TimeInterval) -> String {
        let seconds = Int(duration)
        let minutes = seconds / 60
        let remainder = seconds % 60
        
        // Format the string to ensure two digits for the remainder (seconds)
        return String(format: "%d:%02d", minutes, remainder)
    }
    
}

//#Preview {
//    PlayBackView()
//}
