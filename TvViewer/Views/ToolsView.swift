//
//  ToolsView.swift
//  TvViewer
//
//  Created by Ringo Wathelet on 2025/11/24.
//
import SwiftUI
import AVKit


struct ToolsView: View {
    @Environment(Selector.self) var selector
    @Environment(ColorsModel.self) var colorsModel
    
    @State private var showSettings: Bool = false
    
    var body: some View {
        @Bindable var selector = selector
        VStack {
            HStack {
                AirPlayButton()
                    .frame(width: 50, height: 50)
                    .padding(5)
                Spacer()
                
                tools().frame(width: 222).padding(.horizontal)
                
                Spacer()
                
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gear")
                }
                .font(.system(size: 26))
                .padding(5)
                
            }
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(radius: 2)
            .padding(.horizontal)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(showSettings: $showSettings)
                .environment(selector)
                .environment(colorsModel)
                .presentationDetents([.large])
        }
    }
    
    @ViewBuilder
    func tools() -> some View {
        HStack(spacing: 30) {
            ForEach([ViewTypes.favourites, ViewTypes.countries, ViewTypes.stations], id: \.self) { view in
                Button {
                    selector.view = view
                } label: {
                    if view == .favourites {
                        Image(systemName: "heart.fill").padding(5)
                            .font(.title)
                            .foregroundStyle(colorsModel.favouriteColor)
                            .frame(height: 45)
                            .background(selector.view == view ? Color.primary : Color.clear)
                            .contentShape(Rectangle())
                            .overlay {
                                Image(systemName: "heart")
                                    .font(.title)
                                    .foregroundStyle(.black)
                            }
                    } else {
                        Image(systemName: symbol(for: view)).padding(5)
                            .font(.title)
                            .foregroundStyle(iconColor(for: view))
                            .frame(height: 45)
                            .background(selector.view == view ? Color.primary : Color.clear)
                            .contentShape(Rectangle())
                    }
                }
                .buttonStyle(.plain)
                .glassEffect()
            }
        }
        .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 9))
    }
    
    private func symbol(for view: ViewTypes) -> String {
        switch view {
            case .favourites: "heart.fill"
            case .countries: "globe"
            case .stations: "tv.badge.wifi"
        }
    }
    
    private func iconColor(for view: ViewTypes) -> Color {
        switch view {
            case .favourites: colorsModel.favouriteColor
            case .countries: .primary
            case .stations: .primary
        }
    }
}

struct AirPlayButton: UIViewRepresentable {
    func makeUIView(context: Context) -> AVRoutePickerView {
        let view = AVRoutePickerView()
 //       view.prioritizesVideoDevices = false    // set to true for Apple TV
        view.activeTintColor = .systemBlue      // highlighted color
        view.tintColor = .gray                  // normal color
        view.prioritizesVideoDevices = false    // audio only
        return view
    }
    
    func updateUIView(_ uiView: AVRoutePickerView, context: Context) { }
    
    func makeCoordinator() -> Coordinator { Coordinator() }
    
    class Coordinator {}
}

