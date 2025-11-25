//
//  FilterToolsView.swift
//  TvViewer
//
//  Created by Ringo Wathelet on 2025/11/24.
//
import SwiftUI


struct FilterToolsView: View {
    @Environment(Selector.self) var selector
    
    var body: some View {
        @Bindable var selector = selector
        VStack {
            HStack {
                Spacer()
                StationTagMenu()
                Spacer()
            }
            .padding(4)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(radius: 2)
        }
    }
}

struct StationTagMenu: View {
    @Environment(Selector.self) var selector
    
    var body: some View {
        Menu {
            ForEach(StationTag.allCases) { tag in
                Button {
                    selector.tag = tag
                } label: {
                    HStack {
                        Text(tag.displayName)
                        if tag == selector.tag {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Label(selector.tag.displayName, systemImage: "music.note.list")
        }
        .menuStyle(.button)
        .onChange(of: selector.tag) {
            selector.storeSettings()
        }
    }
}
