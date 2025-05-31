//
//  UserPreferenceCircleView.swift
//  Atwy
//
//  Created by Antoine Bollengier on 26.01.23.
//  Copyright © 2023-2025 Antoine Bollengier. All rights reserved.
//

import SwiftUI

struct UserPreferenceCircleView: View {
    @ObservedProperty(APIKeyModel.shared, \.userAccount, \.$userAccount) private var userAccount
    @ObservedObject private var NM = NetworkReachabilityModel.shared
    var body: some View {
        if let account = userAccount, NM.connected {
            CachedAsyncImage(url: account.avatar.first?.url, content: { image, _ in
                switch image {
                case .success(let imageDisplay):
                    imageDisplay
                        .resizable()
                        .clipShape(Circle())
                default:
                   UnknownAvatarView()
                }
            })
        } else {
            UnknownAvatarView()
        }
    }
}
