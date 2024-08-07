//
//  FitCatsViewModel.swift
//  FitCats
//
//  Created by Milos Ilic on 30.9.24..
//

import Foundation
import Firebase
import FirebaseFirestore
import HealthKit

class FitCatsViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var leagues: [League] = []
    @Published var ranks: [Rank] = []
    
    private let db = Firestore.firestore()
    private let healthStore = HKHealthStore()
    private var stepCountQuery: HKQuery?
    
    init() {
        authorizeHealthKit()
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
    
    // MARK: - Start Step Counting
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
    
    // MARK: - Update Step Count
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
    
    // MARK: - Update Steps in Firebase
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
        
        // Update local model
        DispatchQueue.main.async {
            self.currentUser?.thisWeekSteps = steps
        }
    }
    
    // MARK: - Fetch Data from Firestore
    func fetchUser(by id: String) {
        let userRef = db.collection("users").document(id)
        
        userRef.getDocument { [weak self] (document, error) in
            if let document = document, document.exists {
                do {
                    self?.currentUser = try document.data(as: User.self)
                } catch {
                    print("Error decoding user: \(error)")
                }
            } else {
                print("User document does not exist")
            }
        }
    }
    
    func fetchLeagues() {
        db.collection("leagues").getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                print("Error fetching leagues: \(error)")
                return
            }
            
            let leagues = querySnapshot?.documents.compactMap { document -> League? in
                try? document.data(as: League.self)
            }
            
            self?.leagues = leagues ?? []
        }
    }
    
    func fetchRanks() {
        db.collection("ranks").getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                print("Error fetching ranks: \(error)")
                return
            }
            
            let ranks = querySnapshot?.documents.compactMap { document -> Rank? in
                try? document.data(as: Rank.self)
            }
            
            self?.ranks = ranks ?? []
        }
    }
    
    // MARK: - Accept Friend Request
    func acceptFriendRequest(from friendId: String) {
        guard let currentUserID = currentUser?.id else { return }
        
        let currentUserRef = db.collection("users").document(currentUserID)
        let friendUserRef = db.collection("users").document(friendId)
        
        // Add friend to the user's friends list
        currentUserRef.updateData([
            "friends": FieldValue.arrayUnion([friendUserRef])
        ])
        
        // Add current user to the friend's friends list
        friendUserRef.updateData([
            "friends": FieldValue.arrayUnion([currentUserRef])
        ])
        
        // Remove the friend request from the list
        currentUserRef.updateData([
            "friendRequests": FieldValue.arrayRemove([friendUserRef])
        ])
    }
}
