//
//  DurationView.swift
//  AppleMusicalChairs
//
//  Created by Justin on 2/5/25.
//

import SwiftUI

struct DurationView: View {
    var playbackTime: TimeInterval
    @Binding var songDuration: TimeInterval
    
    var body: some View {
        // Progress View
        ProgressView(value: playbackTime, total: songDuration)
            .progressViewStyle(.linear)
            .tint(.red.opacity(0.5))
            .padding(.horizontal)
            .accessibilityHidden(true)
        
        // Duration View
        HStack {
            Text(durationStr(from: playbackTime))
                .font(.caption)
            
            Spacer()
            
            Text(durationStr(from: songDuration))
                .font(.caption)
        }
        .padding(.horizontal)
        .accessibilityElement(children: .ignore)
    }
    
    private func durationStr(from duration: TimeInterval) -> String {
        let seconds = Int(duration)
        let minutes = seconds / 60
        let remainder = seconds % 60
        
        // Format the string to ensure two digits for the remainder (seconds)
        return String(format: "%d:%02d", minutes, remainder)
    }

}
