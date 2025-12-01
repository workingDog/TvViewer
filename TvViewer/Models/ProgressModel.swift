//
//  ProgressModel.swift
//  TvViewer
//
//  Created by Ringo Wathelet on 2025/12/01.
//
import SwiftUI


@Observable
@MainActor
class ProgressModel {
    var value: Double = 0
    var completed: Int = 0
}
