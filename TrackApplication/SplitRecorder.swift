import SwiftUI
import Firebase
import FirebaseAuth

struct SplitRecorder: View {
    @State private var assignment: [String] = []
    @State private var inputs: [String] = []
    @State private var groupId: String?
    @State private var assignmentId: String?
    @EnvironmentObject var workoutDataManager: WorkoutDataManager
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Workout")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
            
            Button(action: fetchAssignment) {
                Text("Fetch")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)

            VStack(spacing: 15) {
                ForEach(assignment.indices, id: \.self) { index in
                    HStack {
                        Text(assignment[index])
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        TextField("Enter value", text: $inputs[index])
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(maxWidth: .infinity)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                }
            }
            
            Button(action: submit) {
                Text("Submit")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.indigo)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
        }
        .padding()
        .frame(maxWidth: 400)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 10)
        .padding()
    }
    
    /// **Fetches the first group from the orgs collection and retrieves the latest assignment for that group.**
    private func fetchAssignment() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not logged in.")
            return
        }
        
        let db = Firestore.firestore()
        let orgRef = db.collection("orgs").document(userId)
        
        orgRef.getDocument { (doc, error) in
            if let error = error {
                print("Error fetching orgs: \(error.localizedDescription)")
                return
            }
            
            guard let data = doc?.data(), let groups = data["groups"] as? [String] else {
                print("No groups found.")
                return
            }
            
            // Function to check if a group has an unresponded assignment
            func checkGroupForUnrespondedAssignment(groupId: String, completion: @escaping (Bool, String?) -> Void) {
                let assignmentsRef = db.collection("assignments")
                assignmentsRef.whereField("groupId", isEqualTo: groupId)
                    .whereField("athleteIds", arrayContains: userId)
                    .order(by: "dueDate", descending: true)
                    .getDocuments { (snapshot, error) in
                        if let error = error {
                            print("Error checking assignments for group \(groupId): \(error.localizedDescription)")
                            completion(false, nil)
                            return
                        }
                        
                        guard let documents = snapshot?.documents, !documents.isEmpty else {
                            completion(false, nil)
                            return
                        }
                        
                        // Check each assignment in the group
                        for document in documents {
                            let assignmentData = document.data()
                            
                            // Check if user is in the athleteIds array
                            guard let athleteIds = assignmentData["athleteIds"] as? [String],
                                  athleteIds.contains(userId) else {
                                continue
                            }
                            
                            let responses = assignmentData["responses"] as? [String: [Int]] ?? [:]
                            
                            // If user hasn't responded to this assignment, we found one
                            if !responses.keys.contains(userId) {
                                completion(true, document.documentID)
                                return
                            }
                        }
                        
                        // No unresponded assignments found in this group
                        completion(false, nil)
                    }
            }
            
            // Check each group in sequence until we find one with an unresponded assignment
            func checkNextGroup(index: Int) {
                guard index < groups.count else {
                    print("No unresponded assignments found in any group.")
                    return
                }
                
                let groupId = groups[index]
                checkGroupForUnrespondedAssignment(groupId: groupId) { hasUnresponded, assignmentId in
                    if hasUnresponded, let assignmentId = assignmentId {
                        // Found a group with an unresponded assignment
                        self.groupId = groupId
                        self.assignmentId = assignmentId
                        
                        // Fetch the assignment details
                        let assignmentRef = db.collection("assignments").document(assignmentId)
                        assignmentRef.getDocument { (doc, error) in
                            if let error = error {
                                print("Error fetching assignment: \(error.localizedDescription)")
                                return
                            }
                            
                            guard let assignmentData = doc?.data() else {
                                print("No assignment data found.")
                                return
                            }
                            
                            if let repsArray = assignmentData["reps"] as? [String] {
                                self.assignment = repsArray
                                self.inputs = Array(repeating: "", count: repsArray.count)
                            }
                        }
                    } else {
                        // Check the next group
                        checkNextGroup(index: index + 1)
                    }
                }
            }
            
            // Start checking from the first group
            checkNextGroup(index: 0)
        }
    }

    /// **Submits the athlete's responses to Firestore.**
    private func submit() {
        guard let userId = Auth.auth().currentUser?.uid, let assignmentId = assignmentId else {
            print("User not logged in or assignment not fetched.")
            return
        }
        
        let parsedInputs = inputs.map { parseTimeInput($0) }
        
        let db = Firestore.firestore()
        let assignmentRef = db.collection("assignments").document(assignmentId)
        
        // First, update the assignment with the responses
        assignmentRef.updateData([
            "responses.\(userId)": parsedInputs
        ]) { error in
            if let error = error {
                print("Error submitting responses: \(error.localizedDescription)")
                return
            }
            
            print("Responses successfully submitted to assignment.")
            
            // Now, also store in the workouts collection
            self.storeInWorkoutsCollection(db: db, userId: userId, assignmentId: assignmentId, responses: parsedInputs)
        }
    }
    
    /// **Stores the workout data in the workouts collection.**
    private func storeInWorkoutsCollection(db: Firestore, userId: String, assignmentId: String, responses: [Int]) {
        // Get the assignment details to extract reps (distances)
        let assignmentRef = db.collection("assignments").document(assignmentId)
        assignmentRef.getDocument { (doc, error) in
            if let error = error {
                print("Error fetching assignment for workout storage: \(error.localizedDescription)")
                return
            }
            
            guard let assignmentData = doc?.data(),
                  let reps = assignmentData["reps"] as? [String] else {
                print("No reps data found in assignment.")
                return
            }
            
            // Calculate total distance in meters
            var totalMeters = 0
            for rep in reps {
                // Extract the numeric value from the rep string (e.g., "400m" -> 400)
                if let meterValue = Int(rep.filter { $0.isNumber }) {
                    totalMeters += meterValue
                }
            }
            
            // Convert meters to miles (1 mile = 1609.34 meters)
            let miles = Double(totalMeters) / 1609.34
            
            // Calculate total time in minutes
            let totalSeconds = responses.reduce(0, +)
            let timeInMinutes = totalSeconds / 60
            
            // Determine title based on time of day
            let hour = Calendar.current.component(.hour, from: Date())
            let title: String
            if hour < 12 {
                title = "Morning Run"
            } else if hour < 17 {
                title = "Afternoon Run"
            } else {
                title = "Evening Run"
            }
            
            // Create workout data
            let workoutData: [String: Any] = [
                "date": Timestamp(date: Date()),
                "miles": miles,
                "title": title,
                "timeInMinutes": timeInMinutes,
                "userId": userId,
                "assignmentId": assignmentId
            ]
            
            // Add to workouts collection
            db.collection("workouts").addDocument(data: workoutData) { error in
                if let error = error {
                    print("Error adding workout: \(error.localizedDescription)")
                } else {
                    print("Workout successfully added to workouts collection!")
                    
                    // Refresh the workout data to update the graph
                    DispatchQueue.main.async {
                        self.workoutDataManager.fetchWorkoutsForUser()
                    }
                }
            }
        }
    }
    
    /// **Parses user input from MM:SS format to total seconds.**
    private func parseTimeInput(_ input: String) -> Int {
        let components = input.split(separator: ":").map { Int($0) }
        if components.count == 2, let minutes = components[0], let seconds = components[1] {
            return minutes * 60 + seconds
        } else if let seconds = Int(input) {
            return seconds
        }
        return 0 // Default case if input is invalid
    }
}

struct SplitRecorder_Previews: PreviewProvider {
    static var previews: some View {
        SplitRecorder()
    }
}
