//
//  VideoView.swift
//  TvViewer
//
//  Created by Ringo Wathelet on 2025/11/27.
//
import SwiftUI
import AVFoundation
import Foundation
import UIKit
import AVKit
import MediaPlayer


struct VideoView: View {
    @Environment(PlayerManager.self) var playerManager
    @Environment(ColorsModel.self) var colorsModel
    
    var body: some View {
        ZStack {
            VideoPlayer(player: playerManager.player)
                .ignoresSafeArea()
            
            VStack (alignment: .trailing){
                AutoHidingVolumeSlider()
                Spacer()
            }
        }
        .onAppear { playerManager.player?.play() }
        .onDisappear {
            playerManager.player?.pause()
            playerManager.station = nil
            playerManager.showVideo = false
        }
    }
}

// control the system volume
struct SystemVolumeSlider: UIViewRepresentable {
    
    func makeUIView(context: Context) -> MPVolumeView {
        let view = MPVolumeView()
        return view
    }

    func updateUIView(_ uiView: MPVolumeView, context: Context) {}
}

struct AutoHidingVolumeSlider: View {
    @Environment(PlayerManager.self) var playerManager
    @Environment(ColorsModel.self) var colorsModel
    
    @State private var isVisible: Bool = true
    @State private var isInteracting: Bool = false

    // idle delay before hiding
    private let hideDelay: Duration = .seconds(3)

    var body: some View {
        HStack {
            Spacer()
            
            SystemVolumeSlider()
                .frame(width: 250, height: 25)
                .padding(8)
                .opacity(isVisible ? 1 : 0.3)
                .animation(.easeOut(duration: 0.3), value: isVisible)
                .onAppear { startIdleWatcher() }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in userIsActive() }
                        .onEnded { _ in userStopped() }
                )
            Button("Done") {
                playerManager.showVideo = false
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private func userIsActive() {
        isInteracting = true
        isVisible = true
    }

    private func userStopped() {
        isInteracting = false
    }

    private func startIdleWatcher() {
        Task {
            while true {
                try? await Task.sleep(for: hideDelay)
                // if not interacting for delay duration → fade out
                if !isInteracting {
                    withAnimation {
                        isVisible = false
                    }
                }
            }
        }
    }
}
