//
//  FitCatsViewModel.swift
//  FitCats
//
//  Created by Milos Ilic on 30.9.24..
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import HealthKit
import Combine

class FitCatsViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var leagues: [League] = []
    @Published var ranks: [Rank] = []
    @Published var invites: [League] = []
    @Published var activeLeagues: [League] = []
    @Published var completedLeagues: [League] = []
    @Published var leaderboard: [LeaderboardEntry] = []
    @Published var selectedLeague: League?
    @Published var isSignedIn: Bool = false
    @Published var allUsers: [User] = []
    @Published var selectedUser: User?
    @Published var dailySteps: Int = 0
    @Published var weeklySteps: Int = 0
    @Published var thisWeekStartDate: Date = Date()
    @Published var thisWeekEndDate: Date = Date()

    private var cancellables = Set<AnyCancellable>()
    
//    let ranks: [Rank] = [
//        Rank(name: "Cat", imageName: "rank1", color: "#9F8F7F", minSteps: 0, maxSteps: 20999),
//        Rank(name: "Cheetah", imageName: "rank2", color: "#F2CA8F", minSteps: 21000, maxSteps: 41999),
//        Rank(name: "Jaguar", imageName: "rank3", color: "#353535", minSteps: 42000, maxSteps: 62999),
//        Rank(name: "Leopard", imageName: "rank4", color: "#F1DFBB", minSteps: 63000, maxSteps: 83999),
//        Rank(name: "Tiger", imageName: "rank5", color: "#FFAD41", minSteps: 84000, maxSteps: 104999),
//        Rank(name: "Lion", imageName: "rank6", color: "#AB3517", minSteps: 105000, maxSteps: Int.max)
//    ]
    
    private let db = Firestore.firestore()
    private let healthStore = HKHealthStore()
    private var stepCountQuery: HKQuery?
    
    var nextRank: Rank? {
            guard let currentRank = currentUser?.currentRank else { return nil }
            
            // Find the next rank in the ranks array
            return ranks.first { $0.minSteps > currentRank.maxSteps }
        }
    
    var previousRank: Rank? {
         guard let currentRank = currentUser?.currentRank else { return nil }
         
         // Find the last rank before the current rank in terms of step requirements
         return ranks.filter { $0.maxSteps < currentRank.minSteps }.last
     }
    
    // Get current rank based on this week's score
    var currentRank: Rank? {
        ranks.first { $0.minSteps <= currentUser?.thisWeekSteps ?? 0 && (currentUser?.thisWeekSteps ?? 0) <= $0.maxSteps }
    }
    
    // Count of achieving specific rank in the past weeks
    func rankAchievementCount(for rank: Rank) -> Int {
        currentUser?.statistics.ranks.filter { $0 == rank.name }.count ?? 0
    }
    
    init() {
        isSignedIn = UserDefaults.standard.bool(forKey: "isSignedIn")
        authorizeHealthKit()
        fetchAllUsers()
        fetchRanks()
        calculateCurrentWeekDates()
        resetWeeklyStepsIfNeeded()
    }
    
    func fetchAllUsers() {
        db.collection("users").getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                print("Error fetching all users: \(error.localizedDescription)")
                return
            }
            
            // Map documents to User objects
            self?.allUsers = querySnapshot?.documents.compactMap { document in
                try? document.data(as: User.self)
            } ?? []
        }
    }
    
    func fetchRanks() {
        db.collection("ranks").getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                print("Error fetching ranks: \(error.localizedDescription)")
                return
            }
            
            self?.ranks = querySnapshot?.documents.compactMap { document in
                try? document.data(as: Rank.self)
            } ?? []
        }
    }
    
    
    // MARK: - Authentication Methods

    func signUp(username: String, email: String, password: String, completion: @escaping (String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(error.localizedDescription)
                return
            }

            guard let userId = authResult?.user.uid else {
                completion("Failed to retrieve user ID")
                return
            }

            let newUser = User(
                id: userId,
                username: username,
                email: email,
                thisWeekSteps: 0,
                lastWeekSteps: 0,
                currentRank: Rank(name: "Beginner", imageName: "beginner", color: "#FF5733", minSteps: 0, maxSteps: 1000),
                friends: [],
                friendRequests: [],
                leagues: [],
                leagueInvites: [],
                leagueSteps: [],
                statistics: Statistics(totalSteps: 0, stepsPerWeek: [], ranks: [], bestRank: "Beginner")
            )

            do {
                try self.db.collection("users").document(userId).setData(from: newUser) { error in
                    if let error = error {
                        completion(error.localizedDescription)
                    } else {
                        UserDefaults.standard.set(true, forKey: "isSignedIn")
                        self.isSignedIn = true
                        self.currentUser = newUser
                        completion(nil) // Sign up successful
                    }
                }
            } catch {
                completion(error.localizedDescription)
            }
        }
    }

    func signIn(email: String, password: String, completion: @escaping (String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(error.localizedDescription)
                return
            }

            guard let userId = authResult?.user.uid else {
                completion("Failed to retrieve user ID")
                return
            }

            self.fetchUser(by: userId) { error in
                if error == nil {
                    UserDefaults.standard.set(true, forKey: "isSignedIn")
                    self.isSignedIn = true
                    completion(nil) // Sign in successful
                } else {
                    completion(error)
                }
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            UserDefaults.standard.set(false, forKey: "isSignedIn")
            
            // Immediately set currentUser to nil to avoid future Firestore operations
            self.currentUser = nil
            self.isSignedIn = false
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }


    // MARK: - HealthKit Authorization
    private func authorizeHealthKit() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("Health data is not available on this device.")
            return
        }
        
        let stepType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let typesToRead: Set = [stepType]
        
        healthStore.requestAuthorization(toShare: [], read: typesToRead) { [weak self] success, error in
            if success {
                self?.startStepCountQuery()
            } else if let error = error {
                print("HealthKit authorization failed: \(error.localizedDescription)")
            }
        }
    }
    
    // Calculate the start (Monday) and end (Sunday) of the current week
    private func calculateCurrentWeekDates() {
        let calendar = Calendar.current
        let today = Date()
        
        if let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)),
           let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek) {
            thisWeekStartDate = startOfWeek
            thisWeekEndDate = endOfWeek
        }
    }

    // Check if a new week has started and reset weekly steps if needed
    func resetWeeklyStepsIfNeeded() {
        let calendar = Calendar.current
        if let lastWeekEndDate = calendar.date(byAdding: .day, value: 7, to: thisWeekEndDate),
           calendar.isDateInToday(lastWeekEndDate) {
            // Transfer this week's steps to lastWeekSteps
            currentUser?.lastWeekSteps = currentUser?.thisWeekSteps ?? 0
            currentUser?.thisWeekSteps = 0
            // Update the week dates
            calculateCurrentWeekDates()
        }
    }
    
    // Fetch daily steps from HealthKit
    func fetchDailySteps() {
        let stepType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, _ in
            guard let self = self, let sum = result?.sumQuantity() else { return }
            DispatchQueue.main.async {
                self.dailySteps = Int(sum.doubleValue(for: HKUnit.count()))
            }
        }
        healthStore.execute(query)
    }

    // Fetch weekly steps from HealthKit (Monday to Sunday)
    func fetchWeeklySteps() {
        let stepType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let now = Date()
        let calendar = Calendar.current
        
        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) else { return }
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfWeek, end: now, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, _ in
            guard let self = self, let sum = result?.sumQuantity() else { return }
            DispatchQueue.main.async {
                self.weeklySteps = Int(sum.doubleValue(for: HKUnit.count()))
            }
        }
        healthStore.execute(query)
    }
    
    // Timer to fetch steps every 3 seconds
    func startStepUpdates() {
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            self?.fetchDailySteps()
            self?.fetchWeeklySteps()
        }
    }
    
    private func startStepCountQuery() {
        let stepType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        let query = HKStatisticsCollectionQuery(
            quantityType: stepType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: startOfDay,
            intervalComponents: DateComponents(second: 1)
        )
        
        query.initialResultsHandler = { [weak self] _, results, _ in
            self?.updateStepCount(results: results)
        }
        
        query.statisticsUpdateHandler = { [weak self] _, statistics, _, _ in
            if let statistics = statistics {
                self?.updateStepCount(statistics: statistics)
            }
        }
        
        healthStore.execute(query)
        self.stepCountQuery = query
    }
    
    private func updateStepCount(results: HKStatisticsCollection?) {
        guard let results = results else { return }
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        
        results.enumerateStatistics(from: startOfDay, to: now) { [weak self] statistics, _ in
            if let sum = statistics.sumQuantity() {
                let steps = Int(sum.doubleValue(for: HKUnit.count()))
                self?.updateStepsInFirebase(steps: steps)
            }
        }
    }
    
    private func updateStepCount(statistics: HKStatistics) {
        if let sum = statistics.sumQuantity() {
            let steps = Int(sum.doubleValue(for: HKUnit.count()))
            updateStepsInFirebase(steps: steps)
        }
    }
    
    private func updateStepsInFirebase(steps: Int) {
        guard let currentUserID = currentUser?.id else { return }
        
        let userRef = db.collection("users").document(currentUserID)
        userRef.updateData([
            "thisWeekSteps": steps
        ]) { error in
            if let error = error {
                print("Error updating steps in Firebase: \(error)")
            } else {
                print("Steps updated successfully in Firebase")
            }
        }
        
        DispatchQueue.main.async {
            self.currentUser?.thisWeekSteps = steps
        }
    }
    
    // MARK: - Fetch Data from Firestore
    func fetchUser(by id: String, completion: @escaping (String?) -> Void) {
        let userRef = db.collection("users").document(id)
        
        userRef.getDocument { [weak self] (document, error) in
            if let document = document, document.exists {
                do {
                    self?.currentUser = try document.data(as: User.self)
                    completion(nil)
                } catch {
                    completion("Error decoding user: \(error.localizedDescription)")
                }
            } else {
                completion("User document does not exist")
            }
        }
    }
    
    func fetchLeagues() {
        guard let currentUserID = currentUser?.id else { return }
        
        db.collection("leagues").getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                print("Error fetching leagues: \(error)")
                return
            }
            
            let leagues = querySnapshot?.documents.compactMap { document -> League? in
                try? document.data(as: League.self)
            }
            
            self?.invites = leagues?.filter { $0.participants.contains(currentUserID) && $0.isActive } ?? []
            self?.activeLeagues = leagues?.filter { $0.participants.contains(currentUserID) && $0.isActive } ?? []
            self?.completedLeagues = leagues?.filter { $0.participants.contains(currentUserID) && !$0.isActive } ?? []
        }
    }
    
    // MARK: - League Management Methods

    func createLeague(name: String, startDate: Date, endDate: Date, invitedFriends: [String]) {
        guard let currentUserID = currentUser?.id else { return }
        
        let newLeague = League(
            id: UUID().uuidString,
            name: name,
            startDate: startDate,
            endDate: endDate,
            participants: [currentUserID],
            isActive: true,
            createdBy: currentUserID
        )
        
        do {
            try db.collection("leagues").document(newLeague.id).setData(from: newLeague) { [weak self] error in
                if let error = error {
                    print("Error creating league: \(error)")
                    return
                }
                
                // Send invitations to each friend
                self?.sendInvitations(for: newLeague.id, to: invitedFriends)
                self?.fetchLeagues()
            }
        } catch {
            print("Error encoding league: \(error)")
        }
    }
    
    private func sendInvitations(for leagueID: String, to friends: [String]) {
        for friendID in friends {
            let friendRef = db.collection("users").document(friendID)
            friendRef.updateData([
                "leagueInvites": FieldValue.arrayUnion([leagueID])
            ]) { error in
                if let error = error {
                    print("Error sending invite to \(friendID): \(error)")
                } else {
                    print("Invite sent to \(friendID) for league \(leagueID)")
                }
            }
        }
    }
    
    // MARK: - Respond to League Invite
    func respondToInvite(leagueID: String, accept: Bool) {
        guard let currentUserID = currentUser?.id else { return }
        
        let leagueRef = db.collection("leagues").document(leagueID)
        
        if accept {
            // Accept the invitation by adding the user to participants and removing from invites
            leagueRef.updateData([
                "participants": FieldValue.arrayUnion([currentUserID])
            ]) { [weak self] error in
                if let error = error {
                    print("Error accepting invite: \(error)")
                } else {
                    self?.removeLeagueInvite(for: currentUserID, leagueID: leagueID)
                    self?.fetchLeagues()
                }
            }
        } else {
            // Decline the invitation by just removing the invite from the user's leagueInvites
            removeLeagueInvite(for: currentUserID, leagueID: leagueID)
        }
    }
    
    private func removeLeagueInvite(for userID: String, leagueID: String) {
        let userRef = db.collection("users").document(userID)
        
        userRef.updateData([
            "leagueInvites": FieldValue.arrayRemove([leagueID])
        ]) { error in
            if let error = error {
                print("Error removing invite from user \(userID): \(error)")
            } else {
                print("Invite removed for user \(userID)")
            }
        }
    }

    // MARK: - Fetch Leaderboard for League
    func fetchLeaderboard(for league: League) {
        self.selectedLeague = league
        self.leaderboard = []
        
        let usersCollection = db.collection("users")
        
        for participantID in league.participants {
            usersCollection.document(participantID).getDocument { [weak self] (document, error) in
                guard let document = document, document.exists, let user = try? document.data(as: User.self) else { return }
                
                let stepsInLeague = user.leagueSteps.first(where: { $0.league == league.id })?.steps ?? 0
                let entry = LeaderboardEntry(
                    id: user.id,
                    name: user.username,
                    rankImage: user.currentRank.imageName,
                    steps: stepsInLeague
                )
                
                DispatchQueue.main.async {
                    self?.leaderboard.append(entry)
                    self?.leaderboard.sort { $0.steps > $1.steps }
                }
            }
        }
    }
}

extension FitCatsViewModel {
    
    // Fetch friends' details based on IDs in the current user's friends list
    func filteredFriends(searchText: String) -> [User] {
        guard let friendIDs = currentUser?.friends else { return [] }
        let friends = friendIDs.compactMap { id in
            allUsers.first { $0.id == id }
        }
        return friends.filter { $0.username.contains(searchText) || searchText.isEmpty }
    }
    
    // Fetch users for adding new friends (assuming `allUsers` exists as an array of all User objects)
    func filteredUsers(searchText: String) -> [User] {
        allUsers.filter { user in
            !(currentUser?.friends.contains(user.id) ?? false) && user.username.contains(searchText)
        }
    }
    
    // Assuming `friendRequests` are stored in `leagueInvites` or other array of IDs (for pending requests)
    func filteredRequests(searchText: String) -> [User] {
        let requestIDs = currentUser?.friendRequests ?? []
        let requests = requestIDs.compactMap { id in
            allUsers.first { $0.id == id }
        }
        return requests.filter { $0.username.contains(searchText) || searchText.isEmpty }
    }
    
    // MARK: - Friend Management Methods
    
    func sendFriendRequest(to userID: String) {
        // Logic to send friend request, add userID to `friendRequests`
        guard let currentUserID = currentUser?.id else { return }
        db.collection("users").document(userID).updateData([
            "friendRequests": FieldValue.arrayUnion([currentUserID])
        ])
    }
    
    func acceptFriendRequest(from userID: String) {
        guard let currentUserID = currentUser?.id else { return }
        
        // Add to friends list
        db.collection("users").document(currentUserID).updateData([
            "friends": FieldValue.arrayUnion([userID]),
            "friendRequests": FieldValue.arrayRemove([userID])
        ])
        
        // Add current user to the sender's friends list
        db.collection("users").document(userID).updateData([
            "friends": FieldValue.arrayUnion([currentUserID])
        ])
    }
    
    func declineFriendRequest(from userID: String) {
        guard let currentUserID = currentUser?.id else { return }
        
        // Remove from friend requests
        db.collection("users").document(currentUserID).updateData([
            "friendRequests": FieldValue.arrayRemove([userID])
        ])
    }
    
    func removeFriend(friendID: String) {
        guard let currentUserID = currentUser?.id else { return }
        
        // Remove friend from current user's friend list
        db.collection("users").document(currentUserID).updateData([
            "friends": FieldValue.arrayRemove([friendID])
        ])
        
        // Remove current user from friend's friend list
        db.collection("users").document(friendID).updateData([
            "friends": FieldValue.arrayRemove([currentUserID])
        ])
    }
}


struct LeaderboardEntry: Identifiable {
    var id: String
    var name: String
    var rankImage: String
    var steps: Int
}

