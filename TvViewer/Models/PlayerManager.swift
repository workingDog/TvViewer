//
//  PlayerManager.swift
//  TvViewer
//
//  Created by Ringo Wathelet on 2025/11/24.
//
import Foundation
import SwiftUI
import AVKit
import AVFoundation


@MainActor
@Observable
class PlayerManager {
    
    var player: AVPlayer?
    var station: TVStation?
    var isPlaying = false

    init() { }
    
}
