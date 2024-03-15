//
//  BehaviorSettingsView.swift
//  Atwy
//
//  Created by Antoine Bollengier on 03.01.2024.
//

import SwiftUI

struct BehaviorSettingsView: View {
    @ObservedObject private var PSM = PreferencesStorageModel.shared
    
    @State private var performanceChoice: PreferencesStorageModel.Properties.PerformanceModes
    @State private var liveActivities: Bool
    @State private var automaticPiP: Bool
    @State private var backgroundPlayback: Bool
    
    init() {
        /// Maybe using AppStorage would be better
        if let state = PreferencesStorageModel.shared.propetriesState[.performanceMode] as? PreferencesStorageModel.Properties.PerformanceModes {
            self._performanceChoice = State(wrappedValue: state)
        } else {
            self._performanceChoice = State(wrappedValue: .full)
        }
        if let state = PreferencesStorageModel.shared.propetriesState[.liveActivitiesEnabled] as? Bool {
            self._liveActivities = State(wrappedValue: state)
        } else {
            self._liveActivities = State(wrappedValue: true)
        }
        if let state = PreferencesStorageModel.shared.propetriesState[.automaticPiP] as? Bool {
            self._automaticPiP = State(wrappedValue: state)
        } else {
            self._automaticPiP = State(wrappedValue: true)
        }
        if let state = PreferencesStorageModel.shared.propetriesState[.backgroundPlayback] as? Bool {
            self._backgroundPlayback = State(wrappedValue: state)
        } else {
            self._backgroundPlayback = State(wrappedValue: true)
        }
    }
    var body: some View {
        GeometryReader { geometry in
            List {
                Section("Performance Mode") {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(.ultraThickMaterial)
                        HStack {
                            if performanceChoice == .limited {
                                Spacer()
                            }
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(.orange)
                                .frame(width: geometry.size.width * 0.28, height: geometry.size.height * 0.08)
                                .padding(.horizontal)
                            if performanceChoice != .limited {
                                Spacer()
                            }
                        }
                        HStack {
                            HStack {
                                Spacer()
                                Text("Full")
                                Image(systemName: "hare.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 25, height: 25)
                                Spacer()
                            }
                            .onTapGesture {
                                withAnimation(.spring) {
                                    performanceChoice = .full
                                    PSM.setNewValueForKey(.performanceMode, value: PreferencesStorageModel.Properties.PerformanceModes.full)
                                }
                            }
                            Spacer()
//                            RoundedRectangle(cornerRadius: 50)
//                                .frame(width: 2)
//                                .foregroundStyle(.thickMaterial)
//                                .padding(.vertical)
//                            Spacer()
                            HStack {
                                Spacer()
                                Text("Limited")
                                Image(systemName: "tortoise.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 25, height: 25)
                                Spacer()
                            }
                            .onTapGesture {
                                withAnimation(.spring) {
                                    performanceChoice = .limited
                                    PSM.setNewValueForKey(.performanceMode, value: PreferencesStorageModel.Properties.PerformanceModes.limited)
                                }
                            }
                        }
                    }
                    .frame(width: geometry.size.width * 0.7, height: geometry.size.height * 0.10)
                    .centered()
                    Text("Enabling the limited performance mode will use less CPU and RAM while using the app. It will use other UI components that could make your experience a bit more laggy if the app was working smoothly before but it could make it more smooth if the app was very laggy before.")
                        .foregroundStyle(.gray)
                        .font(.caption)
                }
                Section("Live activities") {
                    VStack {
                        let liveActivitiesBinding: Binding<Bool> = Binding(get: {
                            return self.liveActivities
                        }, set: { newValue in
                            PSM.setNewValueForKey(.liveActivitiesEnabled, value: newValue)
                            if #available(iOS 16.1, *) {
                                if self.liveActivities, !newValue {
                                    DownloadingsProgressActivity.stop()
                                } else if !self.liveActivities, newValue, DownloadingsModel.shared.activeDownloadingsCount != 0 {
                                    DownloadingsProgressActivity.setupOnManager(attributes: .init(), state: .modelState)
                                }
                            }
                            self.liveActivities = newValue
                        })
                        Toggle(isOn: liveActivitiesBinding, label: {
                            Text("Live Activities")
                        })
                        Text("Enabling Live Activities will show a Live Activity giving informations on the current downloadings.")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.caption)
                            .foregroundStyle(.gray)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Section("Picture in Picture") {
                    VStack {
                        let automaticPiPBinding: Binding<Bool> = Binding(get: {
                            return self.automaticPiP
                        }, set: { newValue in
                            self.automaticPiP = newValue
                            PSM.setNewValueForKey(.automaticPiP, value: newValue)
                        })
                        Toggle(isOn: automaticPiPBinding, label: {
                            Text("Automatic PiP")
                        })
                        Text("Enabling automatic Picture in Picture (PiP) will switch to PiP when put the app in background but don't quit it, while playing a video. If the player is playing an audio-only asset the PiP will never launch.")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.caption)
                            .foregroundStyle(.gray)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Section("Background playback") {
                    VStack {
                        let backgroundPlaybackBinding: Binding<Bool> = Binding(get: {
                            return self.backgroundPlayback
                        }, set: { newValue in
                            self.backgroundPlayback = newValue
                            PSM.setNewValueForKey(.backgroundPlayback, value: newValue)
                        })
                        Toggle(isOn: backgroundPlaybackBinding, label: {
                            Text("Background Playback")
                        })
                        Text("Enabling background playback will make the player continue playing the video/audio when you quit the app or shut down the screen. If automatic PiP is enabled, it will be preferred over simple background playback when quitting the app.")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.caption)
                            .foregroundStyle(.gray)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .onAppear {
                if let state = PreferencesStorageModel.shared.propetriesState[.performanceMode] as? PreferencesStorageModel.Properties.PerformanceModes {
                    self.performanceChoice = state
                } else {
                    self.performanceChoice = .full
                }
                if let state = PreferencesStorageModel.shared.propetriesState[.automaticPiP] as? Bool {
                    self.automaticPiP = state
                } else {
                    self.automaticPiP = true
                }
                if let state = PreferencesStorageModel.shared.propetriesState[.backgroundPlayback] as? Bool {
                    self.backgroundPlayback = state
                } else {
                    self.backgroundPlayback = true
                }
            }
        }
        .navigationTitle("Behavior")
    }
}
