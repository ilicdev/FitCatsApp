import Foundation
import FirebaseFirestore

struct User: Codable, Identifiable {
    var id: String = UUID().uuidString
    var username: String
    var email: String
    var thisWeekSteps: Int
    var lastWeekSteps: Int
    var currentRank: Rank
    var friends: [String] // Store User IDs of friends
    var friendRequests: [String] // Store User IDs of friend requests
    var leagues: [String] // Store League IDs
    var leagueInvites: [String] // Store League Invite IDs
    var leagueSteps: [LeagueSteps]
    var statistics: Statistics
}

struct LeagueSteps: Codable {
    var league: String // Store League ID
    var steps: Int
}

struct Rank: Codable {
    var name: String
    var imageName: String
    var color: String // Store as hex code (e.g., "#FF5733")
    var minSteps: Int
    var maxSteps: Int
}

struct League: Codable, Identifiable {
    var id: String = UUID().uuidString
    var name: String
    var startDate: Date
    var endDate: Date
    var participants: [String] // Store User IDs of participants
    var isActive: Bool
    var createdBy: String // Store User ID of creator
}

struct Statistics: Codable {
    var totalSteps: Int
    var stepsPerWeek: [Int]
    var ranks: [String] // Store Rank IDs
    var bestRank: String // Store Best Rank ID
}


