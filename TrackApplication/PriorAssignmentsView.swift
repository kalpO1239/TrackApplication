import SwiftUI
import Firebase
import FirebaseAuth

struct PriorAssignmentsView: View {
    @State private var groupedAssignments: [String: [(String, String)]] = [:] // [dueDate: [(assignmentId, groupId)]]
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
                                ForEach(groupedAssignments[dueDate] ?? [], id: \.0) { assignmentId, groupId in
                                    NavigationLink(destination: AssignmentDetailView(assignmentId: assignmentId)) {
                                        Text("Assignment ID: \(assignmentId)")
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
                
                var tempGroupedAssignments: [String: [(String, String)]] = [:]
                
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
                            tempGroupedAssignments[dueDate, default: []].append((assignmentId, groupId))
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
    @State private var responses: [String: [Int]] = [:] // [athleteId: [responseTimes]]
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            Text("Responses for Assignment ID: \(assignmentId)")
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
                TableView(responses: responses)
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
                  let responsesData = assignmentData["responses"] as? [String: [Int]] else {
                DispatchQueue.main.async {
                    self.errorMessage = "No responses found in assignment."
                    self.isLoading = false
                }
                return
            }

            // Using athleteIds to filter responses
            var tempResponses: [String: [Int]] = [:]

            for athleteId in athleteIds {
                // Check if athleteId exists in responses and add it
                if let responseTimes = responsesData[athleteId] {
                    tempResponses[athleteId] = responseTimes
                }
            }

            DispatchQueue.main.async {
                self.responses = tempResponses
                self.isLoading = false
            }
        }
    }
}

struct TableView: View {
    let responses: [String: [Int]] // [athleteId: [responseTimes]]

    var body: some View {
        VStack {
            HStack {
                Text("Athlete ID")
                    .bold()
                    .frame(width: 100, alignment: .leading)
                ForEach(Array(responses.values.first ?? []), id: \.self) { _ in
                    Text("Time")
                        .bold()
                        .frame(width: 60)
                }
            }
            Divider()

            ForEach(responses.keys.sorted(), id: \.self) { athleteId in
                HStack {
                    Text(athleteId)
                        .frame(width: 100, alignment: .leading)
                    ForEach(responses[athleteId] ?? [], id: \.self) { time in
                        Text("\(time)")
                            .frame(width: 60)
                    }
                }
            }
        }
    }
}
