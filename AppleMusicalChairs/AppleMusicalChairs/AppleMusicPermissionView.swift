//
//  AppleMusicPermissionView.swift
//  AppleMusicalChairs
//
//  Created by Justin on 8/16/24.
//

import SwiftUI
import MusicKit

struct AppleMusicPermissionView: View {
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        VStack(spacing: 130) {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: "music.note.list")
                    .resizable()
                    .frame(width: 90, height: 90)
                    .shadow(color: .gray.opacity(0.3), radius: 16)
                    .padding(.bottom, 12)
                
                Text("Apple Music Integration")
                    .font(.title2).bold()
                
                Text("Need Apple Music to play Musical Chairs!")
                    .foregroundStyle(.secondary)
            }
            
            Button("Connect Apple Music") {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    openURL(settingsURL)
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            
        }
        .padding(30)
        
    }
    
}

#Preview {
    AppleMusicPermissionView()
}