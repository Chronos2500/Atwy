//
//  DownloaderProgressActivity.swift
//  Atwy
//
//  Created by Antoine Bollengier on 26.07.2024.
//  Copyright © 2024 Antoine Bollengier (github.com/b5i). All rights reserved.
//  

import ActivityKit
import Foundation

@available(iOS 16.1, *)
struct DownloaderProgressActivity: BackgroundFetchActivity {
    typealias ActivityAttributesType = DownloaderProgressAttributes
    
    let downloader: HLSDownloader
            
    static var isEnabled: Bool {
        return PreferencesStorageModel.shared.liveActivitiesEnabled
    }
            
    static let identifier: String = "Antoine-Bollengier.Atwy.DownloadingsProgressUpdate"
    
    static let fetchInterval: Double = 5
    
    static func taskOperation() {
        DownloadersModel.shared.refreshDownloadingsProgress()
    }
    
    var shouldRescheduleCondition: Bool {
        return self.downloader.downloaderState != .failed && self.downloader.downloaderState != .inactive && self.downloader.downloaderState != .success
    }
    
    func getNewData() -> DownloaderProgressAttributes.DownloaderState {
        return .init(title: downloader.downloadInfo.video.title ?? "No title", channelName: downloader.downloadInfo.video.channel?.name ?? "No name", progress: downloader.percentComplete)
    }
    
    func setupSpecialStep(activity: Activity<ActivityAttributesType>) {
        let observer = DownloadersModel.shared.downloadersChangePublisher.sink(receiveValue: { newState in
            guard shouldRescheduleCondition else {
                Task {
                    await LiveActivitesManager.shared.stopActivity(bgActivity: self)
                }
                return
            }
            
            LiveActivitesManager.shared.updateActivity(withNewState: self.getNewData(), bgActivity: self)
        })
        
        LiveActivitesManager.shared.activitiesObservers.append((self, observer))
    }
}
