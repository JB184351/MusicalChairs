//
//  PlayBackView.swift
//  AppleMusicalChairs
//
//  Created by Justin on 8/16/24.
//

import SwiftUI
import MusicKit

struct PlayBackView: View {
    @State private var playState: PlayState = .pause
    @State private var volume: Double = 0
    @State private var songTimer: Int = Int.random(in: 5...30)
    @State private var roundTimer: Int = 10
    @State var song: Track
    
    @State private var ifDeviceIsConnected = false
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.openURL) private var openURL
    @State private var isTimerActive = true
    
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
        switch volume {
        case 0...30:
            "speaker.wave.1"
        case 31...60:
            "speaker.wave.2"
        case 61...100:
            "speaker.wave.3"
        default:
            "speaker.wave.3"
        }
    }
    
    var airplayImage: String {
        if ifDeviceIsConnected {
            "airplayaudio.circle.fill"
        } else {
            "airplayaudio"
        }
    }
    
    var body: some View {
        VStack {
            // Album Cover
            if let artwork = song.artwork {
                ArtworkImage(artwork, height: 200)
            } else {
                Image(systemName: "music.note")
                    .resizable()
                    .frame(width: 200, height: 200)
            }
            
            // Song Title
            Text(song.title)
                .font(.title)
            
            // Album Title
            Text(song.albumTitle ?? "Album Title Not Found")
                .font(.caption)
            
            // Artist Name
            Text(song.artistName)
                .font(.caption)
            
            // Song Timer
            ZStack {
                Text("\(songTimer) seconds remaining")
                    .fontWeight(.light)
                    .padding()
            }
            .onReceive(timer, perform: { time in
                guard isTimerActive else { return }
                
                if songTimer > 0 {
                    songTimer -= 1
                }
            })
            .onChange(of: scenePhase) { oldValue, newValue in
                if scenePhase == .active && playState == .play {
                    isTimerActive = true
                } else {
                    isTimerActive = false
                }
            }
            
            ZStack {
                Text("Next round starts in \(roundTimer) seconds")
                    .fontWeight(.light)
                    .padding()
            }
            .onReceive(timer, perform: { time in
                guard isTimerActive else { return }
                
                if roundTimer > 0 && songTimer == 0 {
                    roundTimer -= 1
                } else if roundTimer == 0 {
                    songTimer = 30
                }
            })
            .onChange(of: scenePhase) { oldValue, newValue in
                if scenePhase == .active{
                    isTimerActive = true
                } else {
                    isTimerActive = false
                }
            }
            
            // Progress View
            ProgressView(value: player.playbackTime, total: song.duration ?? 0.00)
                .progressViewStyle(.linear)
                .tint(.indigo.opacity(0.5))
            
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
            
            // Volume Slider Control
            VolumeSliderView()
                .frame(minWidth: .zero, maxWidth: .infinity)
                .padding(EdgeInsets(top: 50, leading: 0, bottom: 0, trailing: 0))
            
            // Play/Pause Button
            Button(action: {
                handlePlayButton()
            }, label: {
                Image(systemName: playPauseImage)
            })
            .padding()
            .foregroundStyle(.primary)
            .font(.largeTitle)
            
            Image(systemName: airplayImage)
                .font(ifDeviceIsConnected ? .largeTitle : .title3)
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
            } else {
                playState = .play
                await playTrack(song: song)
            }
        }
    }
    
    @MainActor
    public func playTrack(song: Track) async {
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
