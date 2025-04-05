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
    @State private var sortColumnIndex: Int? = nil
    @State private var sortAscending: Bool = true
    
    var sortedAthletes: [String] {
        guard let columnIndex = sortColumnIndex else {
            return responses.keys.sorted()
        }
        
        if columnIndex == -1 { // Athlete Name column
            return responses.keys.sorted { sortAscending ? $0 < $1 : $0 > $1 }
        }
        
        // For time columns
        return responses.keys.sorted { athlete1, athlete2 in
            let time1 = responses[athlete1]?[safe: columnIndex] ?? Int.max
            let time2 = responses[athlete2]?[safe: columnIndex] ?? Int.max
            return sortAscending ? time1 < time2 : time1 > time2
        }
    }
    
    var body: some View {
        VStack {
            // Column headers: Athlete Name and Reps values
            HStack {
                Button(action: { toggleSort(-1) }) { // -1 represents Athlete Name column
                    HStack {
                        Text("Athlete Name")
                            .bold()
                        if sortColumnIndex == -1 {
                            Image(systemName: sortAscending ? "arrow.up" : "arrow.down")
                        }
                    }
                }
                .frame(width: 150, alignment: .leading)
                
                // Display reps as column headers in their original order
                ForEach(reps.indices, id: \.self) { index in
                    Button(action: { toggleSort(index) }) {
                        HStack {
                            Text(reps[index])
                                .bold()
                            if sortColumnIndex == index {
                                Image(systemName: sortAscending ? "arrow.up" : "arrow.down")
                            }
                        }
                    }
                    .frame(width: 60)
                }
            }
            Divider()

            // Athlete responses rows
            ForEach(sortedAthletes, id: \.self) { athleteName in
                HStack {
                    Text(athleteName)
                        .frame(width: 150, alignment: .leading)
                    
                    // Display response times for each rep in order
                    ForEach(reps.indices, id: \.self) { index in
                        if let times = responses[athleteName] {
                            Text("\(times[safe: index] ?? 0)")
                                .frame(width: 60)
                        }
                    }
                }
            }
        }
    }
    
    private func toggleSort(_ columnIndex: Int) {
        if sortColumnIndex == columnIndex {
            sortAscending.toggle()
        } else {
            sortColumnIndex = columnIndex
            sortAscending = true
        }
    }
}

// Helper extension for safe array indexing
extension Array {
    subscript(safe index: Int) -> Element? {
        return index >= 0 && index < count ? self[index] : nil
    }
}

