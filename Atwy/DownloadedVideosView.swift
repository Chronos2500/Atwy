//
//  DownloadedVideosView.swift
//  Atwy
//
//  Created by Antoine Bollengier on 27.11.22.
//

import SwiftUI
import YouTubeKit

struct DownloadedVideosView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \DownloadedVideo.timestamp, ascending: true)],
        animation: .default)
    private var downloadedVideos: FetchedResults<DownloadedVideo>
    @State private var search: String = ""
    @ObservedObject private var VPM = VideoPlayerModel.shared
    @ObservedObject private var NPM = navigationPathModel
    @ObservedObject private var APIM = APIKeyModel.shared
    @ObservedObject private var network = NetworkReachabilityModel.shared
    @ObservedObject private var PSM = PreferencesStorageModel.shared
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack {
                    DownloadingsHeaderView()
                    ScrollView {
                        //                        List {
                        LazyVStack {
                            let propertyState = PSM.propetriesState[.videoViewMode] as? PreferencesStorageModel.Properties.VideoViewModes
                            let videoViewHeight = propertyState == .halfThumbnail ? 180 : geometry.size.width * 9/16 + 90
                            
                            ForEach(sortedVideos.filter({$0.matchesQuery(search)})) { (video: DownloadedVideo) in
                                let convertResult = video.toYTVideo()
                                
                                Button {
                                    if VideoPlayerModel.shared.currentItem?.videoId != video.videoId {
                                        VideoPlayerModel.shared.loadVideo(video: convertResult)
                                    }
                                    
                                    SheetsModel.shared.showSheet(.watchVideo)
                                } label: {
                                    VideoFromSearchView(video: convertResult, videoThumbnailData: video.thumbnail, channelAvatarData: video.channel?.thumbnail)
                                        .frame(width: geometry.size.width, height: videoViewHeight, alignment: .center)
                                }
                                .listRowSeparator(.hidden)
                            }
                            Color.clear
                                .frame(height: 30)
                        }
                        
                        if VPM.currentItem != nil {
                            Color.clear
                                .frame(height: 50)
                        }
                    }
                }
#if os(macOS)
                .searchable(text: $search, placement: .toolbar)
#else
                .searchable(text: $search, placement: .navigationBarDrawer(displayMode: .always))
#endif
                .autocorrectionDisabled(true)
                .navigationTitle("Downloads")
                .sortingModeSelectorButton(forPropertyType: .downloadsSortingMode)
                .customNavigationTitleWithRightIcon {
                    ShowSettingsButtonView()
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
    
    var sortedVideos: [DownloadedVideo] {
        return self.downloadedVideos.sorted(by: {
            switch (self.PSM.propetriesState[.downloadsSortingMode] as? PreferencesStorageModel.Properties.SortingModes) ?? .oldest {
            case .newest:
                return $0.timestamp > $1.timestamp
            case .oldest:
                return $0.timestamp < $1.timestamp
            case .title:
                return ($0.title ?? "") < ($1.title ?? "")
            case .channelName:
                return ($0.channel?.name ?? "") < ($1.channel?.name ?? "")
            }
        })
    }
}
