//
//  VolumeSliderView.swift
//  AppleMusicalChairs
//
//  Created by Justin on 8/14/24.
//

import SwiftUI
import MediaPlayer
import UIKit

struct VolumeSliderView: UIViewRepresentable {
    func makeUIView(context: Context) -> MPVolumeView {
        let volumeView = MPVolumeView(frame: .zero)
        volumeView.showsVolumeSlider = true
        volumeView.tintColor = .systemIndigo
        return volumeView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

#Preview {
    VolumeSliderView()
}
