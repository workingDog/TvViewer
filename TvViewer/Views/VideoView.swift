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

struct VideoView: View {
    @Environment(PlayerManager.self) var playerManager
    
    var body: some View {
        ZStack {
            VideoPlayer(player: playerManager.player)
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Button("Done") {
                        playerManager.showVideo = false
                    }
                    .buttonStyle(.bordered)
                    .padding(10)
                    Spacer()
                }
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

