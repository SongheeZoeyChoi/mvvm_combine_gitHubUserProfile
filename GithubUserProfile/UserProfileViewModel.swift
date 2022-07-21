//
//  UserProfileViewModel.swift
//  GithubUserProfile
//
//  Created by Songhee Choi on 2022/07/21.
//

import UIKit
import Combine

final class UserProfileViewModel {
    
    init(network: NetworkService, selectedUser: UserProfile? = nil) {
        self.network = network
        self.selectedUser = CurrentValueSubject(selectedUser)
    }
    
    let network: NetworkService
    var subscriptions = Set<AnyCancellable>()
    
    // Data -> Output
//    @Published private(set) var user: UserProfile?
    let selectedUser: CurrentValueSubject<UserProfile?, Never>
    
    var name: String {
        return selectedUser.value?.name ?? "n/a"
    }
    
    var login: String {
        return selectedUser.value?.login ?? "n/a"
    }
    
    var followers: String {
        guard let followers = selectedUser.value?.followers else { return "" }
        return "follower: \(followers)"
    }
    
    var following: String {
        guard let following = selectedUser.value?.following else { return "" }
        return "following: \(following)"
    }
    
    var imageURL: URL? {
        return selectedUser.value?.avatarUrl
    }
    
    // User Action -> Input
    func search(keyword: String) {
        let resource = Resource<UserProfile>(base: "https://api.github.com/", path: "users/\(keyword)", params: [:], header: ["Content-Type": "application/json"])
        
        network.load(resource)
            .receive(on: RunLoop.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    self.selectedUser.send(nil)
                    print("error: \(error)")
                case .finished: break
                }
            } receiveValue: { user in
                self.selectedUser.send(user)
            }.store(in: &subscriptions)
    }
}
