//
//  VolumeSliderView.swift
//  AppleMusicalChairs
//
//  Created by Justin on 8/14/24.
//

import SwiftUI
import MediaPlayer

struct VolumeSliderView: UIViewRepresentable {
    func makeUIView(context: Context) -> MPVolumeView {
        let volumeView = MPVolumeView(frame: .zero)
        volumeView.showsVolumeSlider = true
        volumeView.tintColor = .red
        return volumeView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

#Preview {
    VolumeSliderView()
}
