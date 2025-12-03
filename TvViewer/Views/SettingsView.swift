//
//  SettingsView.swift
//  TvViewer
//
//  Created by Ringo Wathelet on 2025/11/24.
//
import SwiftUI


struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(Selector.self) var selector
    @Environment(ColorsModel.self) var colorsModel
    
    @Binding var showSettings: Bool
    
    @State private var progressModel = ProgressModel()
    @State private var importer: IPTVImporter?
    
 
    var body: some View {
        @Bindable var selector = selector
        @Bindable var colorsModel = colorsModel
        
        ZStack {
            colorsModel.gradient.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 10) {
                
                VStack(spacing: 1) {
                    HStack {
                        Button("Done") {
                            showSettings = false
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(10)
                        Spacer()
                    }
                    Text("Settings").font(.largeTitle)
                }
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Text("Selection border color ")
                            Image(systemName: "inset.filled.square.dashed")
                                .font(.title)
                                .foregroundStyle(colorsModel.borderColor)
                            ColorPicker("", selection: $colorsModel.borderColor)
                                .labelsHidden()
                            Spacer()
                        }
                        
                        HStack {
                            Text("Countries back color ")
                            Image(systemName: "backpack.fill")
                                .font(.title)
                                .foregroundStyle(colorsModel.countryBackColor)
                            ColorPicker("", selection: $colorsModel.countryBackColor)
                                .labelsHidden()
                            Spacer()
                        }
                        
                        HStack {
                            Text("Stations back color ")
                            Image(systemName: "backpack.fill")
                                .font(.title)
                                .foregroundStyle(colorsModel.stationBackColor)
                            ColorPicker("", selection: $colorsModel.stationBackColor)
                                .labelsHidden()
                            Spacer()
                        }
                        
                        HStack {
                            Text("Background color ")
                            Image(systemName: "backpack.fill")
                                .font(.title)
                                .foregroundStyle(colorsModel.backColor)
                            ColorPicker("", selection: $colorsModel.backColor)
                                .labelsHidden()
                            Spacer()
                        }
                        
                        HStack {
                            Text("Favourite Color ")
                            Image(systemName: "heart.fill")
                                .font(.title)
                                .foregroundStyle(colorsModel.favouriteColor)
                            ColorPicker("", selection: $colorsModel.favouriteColor)
                                .labelsHidden()
                            Spacer()
                        }
                        
                        HStack {
                            Text("Network Color ")
                            Image(systemName: "network")
                                .font(.title)
                                .foregroundStyle(colorsModel.netColor)
                            ColorPicker("", selection: $colorsModel.netColor)
                                .labelsHidden()
                            Spacer()
                        }
                        
                        HStack {
                            Text("Station select sound  ")
                            Image(systemName: "hand.tap.fill")
                                .font(.title)
                                .foregroundStyle(selector.pingSound ? Color.accentColor : .black)
                            Toggle("", isOn: $selector.pingSound)
                            Spacer()
                        }
                        .fixedSize()

                        Divider()
                        
                        HStack {
                            Text("New data ")
                            Button {
                                if let importer {
                                    Task {
                                        do {
                                            try await importer.doImportAll(progressModel)
                                            selector.updateDate = Date()
                                        } catch {
                                            print("----> SettingsView error: \(error)")
                                        }
                                    }
                                }
                            } label: {
                                Image(systemName: progressModel.value > 0.99 ? "square.and.arrow.down.badge.checkmark.fill" : "square.and.arrow.down.fill")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .foregroundStyle(progressModel.value < 1.0 ? .red : Color.accentColor)
                            }
                            Spacer()
                            
                            ProgressView(value: progressModel.value)
                        }
                        .frame(width: 350, height: 35)
                        .padding(.top, 20)
                        
                        Text("Last updated on \n\(selector.updateDate, style: .date)")
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                }
                .padding(5)
            }
            .onDisappear {
                selector.storeSettings()
                colorsModel.storeSettings()
            }
        }
        .onAppear {
            importer = IPTVImporter(context: modelContext)
        }
    }
    
}
