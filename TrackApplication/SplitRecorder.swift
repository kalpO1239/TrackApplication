

import SwiftUI
import Firebase
import FirebaseAuth

struct SplitRecorder: View {
    @State private var assignment: [String] = []
    @State private var inputs: [String] = []
    @State private var groupId: String?
    @State private var assignmentId: String?
    
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
            
            guard let data = doc?.data(), let groups = data["groups"] as? [String], let firstGroup = groups.first else {
                print("No groups found.")
                return
            }
            
            self.groupId = firstGroup
            

            // Fetch the latest assignment for this group where athleteIds contains the userId
            let assignmentsRef = db.collection("assignments")
            assignmentsRef.whereField("groupId", isEqualTo: firstGroup)
                .whereField("athleteIds", arrayContains: userId)
                .order(by: "dueDate", descending: true) // Fetch latest assignment
                .limit(to: 1)
                .getDocuments { (snapshot, error) in
                    if let error = error {
                        print("Error fetching assignments: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let assignmentDoc = snapshot?.documents.first else {
                        print("No assignments found.")
                        return
                    }
                    
                    let assignmentData = assignmentDoc.data()
                    if let repsArray = assignmentData["reps"] as? [String] {
                        self.assignment = repsArray
                        self.inputs = Array(repeating: "", count: repsArray.count)
                        self.assignmentId = assignmentDoc.documentID
                    }
                }
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
        
        assignmentRef.updateData([
            "responses.\(userId)": parsedInputs
        ]) { error in
            if let error = error {
                print("Error submitting responses: \(error.localizedDescription)")
            } else {
                print("Responses successfully submitted.")
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
