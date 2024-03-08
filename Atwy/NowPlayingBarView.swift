//
//  NowPlayingBarView.swift
//
//  Created by Antoine Bollengier (github.com/b5i) on 05.05.23.
//  Copyright © 2023 Antoine Bollengier. All rights reserved.
//  

import SwiftUI
import AVKit

struct NowPlayingBarView: View {
    var sheetAnimation: Namespace.ID
    @Binding var isSheetPresented: Bool
    @State var isSettingsSheetPresented: Bool = false
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject private var VPM = VideoPlayerModel.shared
    @ObservedObject private var PM = PersistenceModel.shared
    var body: some View {
        let isFavorite: Bool = {
            guard let videoId = VPM.video?.videoId else { return false }
            return PM.currentData.favoriteVideoIds.contains(where: {$0 == videoId})
        }()
        
        let downloadLocation: URL? = {
            guard let videoId = VPM.video?.videoId else { return nil }
            return PM.currentData.downloadedVideoIds.first(where: {$0.videoId == videoId})?.storageLocation
        }()
        ZStack {
            Rectangle()
                .fill(.ultraThickMaterial)
                .foregroundColor(.clear.opacity(0.2))
                .overlay {
                    HStack {
                        VStack {
                            if !isSettingsSheetPresented {
                                VideoPlayer(player: VPM.player)
                                    .frame(height: 70)
                                    .onAppear {
#if os(macOS)
                                        if NSApplication.shared.isActive {
                                            withAnimation {
                                                isSheetPresented = true
                                            }
                                        }
#else
                                        if UIApplication.shared.applicationState == .background {
                                            withAnimation {
                                                isSheetPresented = true
                                            }
                                        }
#endif
                                    }
                            } else if let thumbnail = VPM.video?.thumbnails.first {
                                CachedAsyncImage(url: thumbnail.url, content: { image, _ in
                                    switch image {
                                    case .success(let image):
                                        image
                                            .resizable()
                                    default:
                                        Rectangle()
                                            .foregroundColor(colorScheme.backgroundColor)
                                    }
                                })
                            }
                        }
                        .frame(width: 114, height: 64)
                        .frame(alignment: .leading)
                        .matchedGeometryEffect(id: "VIDEO", in: sheetAnimation)
                        Spacer()
                        VStack {
                            if VPM.video != nil {
                                Text(VPM.video?.title ?? "No title")
                                    .truncationMode(.tail)
                                    .foregroundColor(colorScheme.textColor)
                            } else {
                                Text("No title")
                                    .truncationMode(.tail)
                                    .foregroundColor(colorScheme.textColor)
                            }
                        }
                        .padding(.horizontal)
                        Spacer()
                        //                            }
                        Button {
                            withAnimation {
                                VPM.deleteCurrentVideo()
                            }
                        } label: {
                            Image(systemName: "multiply")
                                .resizable()
                                .foregroundColor(colorScheme.textColor)
                                .scaledToFit()
                        }
                        .frame(width: 15, height: 15)
                        .padding(.trailing)
                    }
                }
                .matchedGeometryEffect(id: "BGVIEW", in: sheetAnimation)
        }
        .overlay(alignment: .bottom) {
            Rectangle().fill(.gray.opacity(0.1))
                .frame(height: 1)
        }
        .frame(height: 70)
        .contextMenu {
            if let video = VPM.video {
                VideoContextMenuView(video: video, videoThumbnailData: VPM.videoThumbnailData, isFavorite: isFavorite, isDownloaded: downloadLocation != nil)
            }
        } preview: {
            if let video = VPM.video {
                VideoView(video: video)
            }
        }
        .offset(y: -49)
        .onTapGesture {
            withAnimation {
                isSheetPresented = true
            }
        }
    }
}
