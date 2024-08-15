//
//  ContentView.swift
//  AppleMusicalChairs
//
//  Created by Justin on 8/13/24.
//

import SwiftUI
import MediaPlayer

struct ContentView: View {
    @State private var playState: PlayState = .play
    @State private var volume: Double = 0
    @State private var songTimer: Int = 30
    @State private var ifDeviceIsConnected = false
    
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
            Image(.maybeMan)
                .resizable()
                .scaledToFit()
            
            // Song Title
            Text("Maybe Man")
                .font(.title)
            
            // Album Title
            Text("The Maybe Man")
                .font(.caption)
            
            // Song Timer
            Text("\(songTimer) seconds remaining")
                .fontWeight(.light)
                .padding()
            
            // Volume Slider Control
            HStack {
                Image(systemName: "speaker")
                Slider(value: $volume, in: 0...100)
                    .tint(.indigo)
                Image(systemName: speakerImage)
            }
            // Play/Pause Button
            Button(action: {
                if playState == .play {
                    playState = .pause
                } else {
                    playState = .play
                }
            }, label: {
                Image(systemName: playPauseImage)
            })
            .padding()
            .foregroundStyle(.secondary)
            .font(.largeTitle)
            
            Image(systemName: airplayImage)
                .font(ifDeviceIsConnected ? .largeTitle : .title3)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
