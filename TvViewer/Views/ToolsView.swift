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
                
                Picker("", selection: $selector.view) {
                    ForEach(ViewTypes.allCases) { tool in
                        Text(tool.rawValue).tag(tool)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 250)
                .padding(.horizontal)
                
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
      //      .glassEffect(.regular.tint(colorsModel.backColor).interactive(), in: RoundedRectangle(cornerRadius: 12))
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

