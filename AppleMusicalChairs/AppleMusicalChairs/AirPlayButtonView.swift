//
//  AirPlayButtonView.swift
//  AppleMusicalChairs
//
//  Created by Justin on 9/12/24.
//

import SwiftUI
import AVKit

struct AirPlayButtonView: UIViewRepresentable {
    func makeUIView(context: Context) -> some UIView {
        let routerPickerView = AVRoutePickerView()
        return routerPickerView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

#Preview {
    AirPlayButtonView()
}
