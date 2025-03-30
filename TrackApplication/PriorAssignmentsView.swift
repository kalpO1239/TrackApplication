import SwiftUI
import Firebase
import FirebaseAuth

struct PriorAssignmentsView: View {
    @State private var groupedAssignments: [String: [(String, String, Timestamp)]] = [:] // [dueDate: [(assignmentId, groupId, dueDateTimestamp)]]
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            VStack {
                Button("Fetch Assignments") {
                    fetchAssignments()
                }
                .padding()
                .buttonStyle(.borderedProminent)

                if isLoading {
                    ProgressView("Loading assignments...")
                        .padding()
                } else {
                    List {
                        ForEach(groupedAssignments.keys.sorted(), id: \.self) { dueDate in
                            Section(header: Text(dueDate)) {
                                ForEach(groupedAssignments[dueDate] ?? [], id: \.0) { assignmentId, groupId, _ in
                                    NavigationLink(destination: AssignmentDetailView(assignmentId: assignmentId, groupId: groupId)) {
                                        // Display the group name and due date
                                        Text("Group: \(groupId), Due: \(dueDate)")
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Prior Assignments")
            .onAppear(perform: fetchAssignments)
        }
    }

    private func fetchAssignments() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("❌ User not logged in.")
            return
        }
        
        print("✅ Fetching assignments for coach ID: \(userId)")
        
        let db = Firestore.firestore()
        db.collection("assignments")
            .whereField("coachId", isEqualTo: userId)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print("❌ Error fetching assignments: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    print("⚠️ No assignments found.")
                    return
                }
                
                var tempGroupedAssignments: [String: [(String, String, Timestamp)]] = [:]
                
                for document in documents {
                    let data = document.data()
                    let assignmentId = document.documentID
                    if let dueDateTimestamp = data["dueDate"] as? Timestamp {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateStyle = .medium
                        dateFormatter.timeStyle = .none
                        let dueDate = dateFormatter.string(from: dueDateTimestamp.dateValue())
                        
                        if let groupId = data["groupId"] as? String {
                            print("📌 Found assignment: \(assignmentId), Due: \(dueDate), Group: \(groupId)")
                            tempGroupedAssignments[dueDate, default: []].append((assignmentId, groupId, dueDateTimestamp))
                        }
                    }
                }
                
                self.groupedAssignments = tempGroupedAssignments
                print("✅ Assignments loaded successfully.")
            }
    }
}

struct AssignmentDetailView: View {
    let assignmentId: String
    let groupId: String
    @State private var responses: [String: [Int]] = [:] // [athleteName: [responseTimes]]
    @State private var reps: [String] = [] // Reps array for column headers
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var groupName: String?
    @State private var dueDate: String?

    var body: some View {
        VStack {
            Text("Responses for Group: \(groupName ?? "Loading...") - Due: \(dueDate ?? "Loading...")")
                .font(.title)
                .padding()

            if isLoading {
                ProgressView("Loading responses...")
            }

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            ScrollView(.horizontal) {
                TableView(responses: responses, reps: reps)
            }

            Button(action: fetchResponses) {
                Text("Fetch Responses")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
        }
        .onAppear(perform: fetchResponses)
    }

    private func fetchResponses() {
        isLoading = true
        errorMessage = nil
        let db = Firestore.firestore()
        let assignmentRef = db.collection("assignments").document(assignmentId)

        assignmentRef.getDocument { (doc, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Error fetching assignment: \(error.localizedDescription)"
                    self.isLoading = false
                }
                return
            }

            guard let assignmentData = doc?.data(),
                  let athleteIds = assignmentData["athleteIds"] as? [String], // Array of athlete IDs
                  let responsesData = assignmentData["responses"] as? [String: [Int]], // Athlete response data
                  let reps = assignmentData["reps"] as? [String] else { // Get the reps array
                DispatchQueue.main.async {
                    self.errorMessage = "No responses or reps found in assignment."
                    self.isLoading = false
                }
                return
            }

            // Fetch the group based on the groupId (name value in the groups collection)
            db.collection("groups").whereField("name", isEqualTo: groupId).getDocuments { (groupSnapshot, error) in
                if let error = error {
                    DispatchQueue.main.async {
                        self.errorMessage = "Error fetching group: \(error.localizedDescription)"
                        self.isLoading = false
                    }
                    return
                }

                guard let groupDocument = groupSnapshot?.documents.first,
                      let members = groupDocument.data()["members"] as? [String: String] else {
                    DispatchQueue.main.async {
                        self.errorMessage = "No members found in group."
                        self.isLoading = false
                    }
                    return
                }

                // Store the group name
                self.groupName = groupDocument.data()["name"] as? String

                // Convert dueDate timestamp to a readable string
                if let dueDateTimestamp = assignmentData["dueDate"] as? Timestamp {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .medium
                    dateFormatter.timeStyle = .none
                    self.dueDate = dateFormatter.string(from: dueDateTimestamp.dateValue())
                }

                // Now construct the responses with athlete names
                var tempResponses: [String: [Int]] = [:]
                for athleteId in athleteIds {
                    // Check if athleteId exists in responses and add it
                    if let responseTimes = responsesData[athleteId] {
                        // Replace athleteId with the athlete's name from the members map
                        let athleteName = members[athleteId] ?? athleteId // Default to athleteId if name is not found
                        tempResponses[athleteName] = responseTimes
                    }
                }

                DispatchQueue.main.async {
                    self.responses = tempResponses
                    self.reps = reps // Store the reps array for column headers
                    self.isLoading = false
                }
            }
        }
    }
}

struct TableView: View {
    let responses: [String: [Int]] // [athleteName: [responseTimes]]
    let reps: [String] // The reps array for column headers

    var body: some View {
        VStack {
            // Column headers: Athlete Name and Reps values
            HStack {
                Text("Athlete Name")
                    .bold()
                    .frame(width: 150, alignment: .leading)
                ForEach(reps, id: \.self) { rep in
                    Text(rep)
                        .bold()
                        .frame(width: 60)
                }
            }
            Divider()

            // Athlete responses rows
            ForEach(responses.keys.sorted(), id: \.self) { athleteName in
                HStack {
                    Text(athleteName)
                        .frame(width: 150, alignment: .leading)
                    ForEach(responses[athleteName] ?? [], id: \.self) { time in
                        Text("\(time)")
                            .frame(width: 60)
                    }
                }
            }
        }
    }
}
