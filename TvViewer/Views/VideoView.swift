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
        VStack {
            Button("Done") {
                playerManager.showVideo = false
            }
            .buttonStyle(.bordered)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(6)

            VideoPlayer(player: playerManager.player)
                .onAppear { playerManager.player?.play() }
        }
        .onDisappear {
            playerManager.player?.pause()
            playerManager.station = nil
        }
    }
}

