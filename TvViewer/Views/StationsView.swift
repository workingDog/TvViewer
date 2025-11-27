//
//  StationsView.swift
//  TvViewer
//
//  Created by Ringo Wathelet on 2025/11/24.
//
import SwiftUI
import WebKit
import AVFoundation
import Foundation
import UIKit
import AVKit


struct StationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(PlayerManager.self) var playerManager
    @Environment(ColorsModel.self) var colorsModel
    @Environment(Selector.self) var selector
    
    var station: TVStation
    
    @State private var showConfirm = false
    @State private var showWeb = false
    
    @State private var logoIcon: UIImage?
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    if station.isFavourite {
                        // Ask for confirmation before changing it
                        showConfirm = true
                    } else {
                        station.isFavourite = true
                        SwiftDataHelper.updateOrInsert(station: station, in: modelContext)
                    }
                } label: {
                    Image(systemName: station.isFavourite ? "heart.fill" : "heart.slash")
                        .resizable()
                        .foregroundStyle(colorsModel.favouriteColor)
                        .frame(width: 30, height: 30)
                        .padding(5)
                }.buttonStyle(.borderless)
                
                    .confirmationDialog("Remove from favourites", isPresented: $showConfirm) {
                        Button("Yes") {
                            station.isFavourite = false
                            SwiftDataHelper.findAndRemove(station: station, in: modelContext)
                        }
                        Button("No", role: .cancel) { }
                    } message: { Text("Really remove this station from favourites?") }
                
                Spacer()
                
                Text(station.categories.first ?? StationTag.general.rawValue)
                
                Spacer()
                
                Button {
                    showWeb = true
                } label: {
                    Image(systemName: "network")
                        .resizable()
                        .foregroundColor(colorsModel.netColor)
                        .frame(width: 30, height: 30)
                        .padding(5)
                }.buttonStyle(.borderless)
            }
            
            Group {
                if let img = logoIcon {
                    Image(uiImage: img).resizable()
                } else {
                    Image(uiImage: TVLogo.defaultImg()).resizable()
                }
            }
            .scaledToFit()
            .frame(width: 44, height: 44)
            
            
            Text(station.name)
                .lineLimit(1)
                .padding(5)
        }
        .contentShape(RoundedRectangle(cornerRadius: 12))
        .onTapGesture {
            if selector.pingSound {
                playClick()
            }
            playerManager.isPlaying = false
            // tap on same station to unselect it
            if playerManager.station == station {
                playerManager.station = nil
            } else {
                playerManager.station = station
                if let stream = station.streams.first?.url, let url = URL(string: stream) {
                    let item = AVPlayerItem(url: url)
                    playerManager.player = AVPlayer(playerItem: item)
                    playerManager.isPlaying = true
                    playerManager.showVideo = true
                }
            }
        }
        .background(colorsModel.stationBackColor)
    //    .glassEffect(.regular.tint(colorsModel.stationBackColor).interactive(), in: RoundedRectangle(cornerRadius: 12)) // for iOS26+
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .fullScreenCover(isPresented: $showWeb) {
            WebViewScreen(showWeb: $showWeb, station: station)
        }
        .task {
            logoIcon = await station.logoImage()
        }
    }
    
    func playClick() {
        var id: SystemSoundID = 0
        if let url = Bundle.main.url(forResource: "click3", withExtension: "wav") {
            AudioServicesCreateSystemSoundID(url as CFURL, &id)
            AudioServicesPlaySystemSound(id)
        }
    }
    
}

struct WebViewScreen: View {
    @Binding var showWeb: Bool
    let station: TVStation
    
    var body: some View {
        VStack {
            Button("Done") {
                showWeb = false
            }
            .buttonStyle(.bordered)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(6)
            
            Divider()
            
            if let weburl = station.website, let url = URL(string: weburl),
               UIApplication.shared.canOpenURL(url) {
                if #available(iOS 26.0, *) {
                    WebView(url: url)
                } else {
                    OldWebView(urlString: weburl)
                }
            } else {
                Text("No homepage available").font(Font.largeTitle.bold())
                Spacer()
            }
        }
    }
}

struct OldWebView: UIViewRepresentable {
    let urlString: String
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Only reload if URL changed
        if let newURL = URL(string: urlString), uiView.url != newURL {
            uiView.load(URLRequest(url: newURL))
        }
    }
    
    func makeCoordinator() -> Coordinator { Coordinator() }
    
    final class Coordinator: NSObject, WKNavigationDelegate { }
}
