//
//  DancingChairsView.swift
//  AppleMusicalChairs
//
//  Created by Justin on 2/4/25.
//

import SwiftUI

struct DancingChairsView: View {
    @Binding var isDancing: Bool
    
    var body: some View {
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
    }
}
