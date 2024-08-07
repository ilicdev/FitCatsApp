import FirebaseFirestore

class FirebaseUploader {
    private let db = Firestore.firestore()
    
    // Function to upload users
    func uploadUser(user: User, completion: @escaping (Error?) -> Void) {
        do {
            let userRef = db.collection("users").document(user.id)
            try userRef.setData(from: user) { error in
                completion(error)
            }
        } catch let error {
            completion(error)
        }
    }
    
    // Function to upload leagues
    func uploadLeague(league: League, completion: @escaping (Error?) -> Void) {
        do {
            let leagueRef = db.collection("leagues").document(league.id)
            try leagueRef.setData(from: league) { error in
                completion(error)
            }
        } catch let error {
            completion(error)
        }
    }
    
    // Function to upload ranks
    func uploadRank(rank: Rank, completion: @escaping (Error?) -> Void) {
        do {
            let rankRef = db.collection("ranks").document() // Auto-generated ID for rank
            try rankRef.setData(from: rank) { error in
                completion(error)
            }
        } catch let error {
            completion(error)
        }
    }
    
    // Function to upload multiple users, leagues, and ranks
    func uploadData(users: [User], leagues: [League], ranks: [Rank]) {
        let dispatchGroup = DispatchGroup()
        
        for user in users {
            dispatchGroup.enter()
            uploadUser(user: user) { error in
                if let error = error {
                    print("Error uploading user \(user.username): \(error)")
                } else {
                    print("User \(user.username) uploaded successfully.")
                }
                dispatchGroup.leave()
            }
        }
        
        for league in leagues {
            dispatchGroup.enter()
            uploadLeague(league: league) { error in
                if let error = error {
                    print("Error uploading league \(league.name): \(error)")
                } else {
                    print("League \(league.name) uploaded successfully.")
                }
                dispatchGroup.leave()
            }
        }
        
        for rank in ranks {
            dispatchGroup.enter()
            uploadRank(rank: rank) { error in
                if let error = error {
                    print("Error uploading rank \(rank.name): \(error)")
                } else {
                    print("Rank \(rank.name) uploaded successfully.")
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            print("All data has been uploaded successfully.")
        }
    }
}
