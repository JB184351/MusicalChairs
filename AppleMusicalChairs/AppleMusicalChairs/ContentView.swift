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
    @State private var songTimer: Double = 0
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
        
            // Volume Slider Control
            HStack {
                Image(systemName: "speaker")
                Slider(value: $volume, in: 0...100)
                    .tint(.white)
                Image(systemName: speakerImage)
            }
            
            HStack {
                // Go Back a song or something Button
                Button(action: {
                    print("Go back a song or somethin'")
                }) {
                    Image(systemName: "backward")
                }
                .padding()
                .foregroundStyle(.white)
                .font(.title2)
                
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
                .foregroundStyle(.white)
                .font(.largeTitle)
                
                // Go Forward a song or something button
                Button(action: {
                    print("Go forward or somethin'")
                }, label: {
                    Image(systemName: "forward")
                })
                .padding()
                .foregroundStyle(.white)
                .font(.title2)
            }
            
            Image(systemName: airplayImage)
                .font(ifDeviceIsConnected ? .largeTitle : .title3)
            
            
            
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
