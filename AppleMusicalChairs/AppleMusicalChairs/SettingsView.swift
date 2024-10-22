//
//  SettingsView.swift
//  AppleMusicalChairs
//
//  Created by Justin on 10/17/24.
//

import SwiftUI

struct SettingsView: View {
    @Binding var songTimer: Int
    @Binding var roundTimer: Int
    
    var body: some View {
        Form {
            Section(header: Text("Song Timer")) {
                Stepper(value: $songTimer, in: 1...60) {
                    Text("\(songTimer) seconds")
                }
            }
            
            Section(header: Text("Round Timer")) {
                Stepper(value: $roundTimer, in: 5...30, step: 1) {
                    Text("\(roundTimer) seconds")
                }
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    SettingsView(songTimer: .constant(30), roundTimer: .constant(60))
}

