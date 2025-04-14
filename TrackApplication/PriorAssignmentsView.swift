import SwiftUI
import Firebase
import FirebaseAuth

struct PriorAssignmentsView: View {
    @State private var groupedAssignments: [String: [(String, String, Timestamp, String)]] = [:] // [dueDate: [(assignmentId, groupId, dueDateTimestamp, title)]]
    @State private var isLoading = false
    @State private var groups: [String] = []
    @State private var selectedGroup: String = ""

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ModernBackground()
                
                VStack(spacing: 20) {
                    // Groups Tabs
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(groups, id: \.self) { group in
                                Button(action: {
                                    selectedGroup = group
                                    fetchAssignments()
                                }) {
                                    Text(group)
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 16)
                                        .background(
                                            selectedGroup == group ?
                                            AnyView(
                                                LinearGradient(
                                                    colors: [
                                                        Color(hex: "#5B5E73"),
                                                        Color(hex: "#433F4E")
                                                    ],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            ) : AnyView(Color(hex: "#ECE3DF").opacity(0.5))
                                        )
                                        .foregroundColor(selectedGroup == group ? .white : Color(hex: "#433F4E"))
                                        .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 20)

                    if isLoading {
                        loadingView
                    } else if groupedAssignments.isEmpty {
                        emptyStateView
                    } else {
                        assignmentsListView
                    }
                }
            }
            .onAppear {
                fetchCoachGroups()
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.5)
                .tint(Color(hex: "#5B5E73"))
            
            Text("Loading assignments...")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(Color(hex: "#5B5E73"))
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(Color(hex: "#5B5E73").opacity(0.5))
            
            Text("No assignments found")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(Color(hex: "#5B5E73"))
            
            Text("Assignments will appear here once created")
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(Color(hex: "#5B5E73").opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
    
    private var assignmentsListView: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(groupedAssignments.keys.sorted(), id: \.self) { dueDate in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(dueDate)
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(hex: "#433F4E"))
                            .padding(.horizontal)
                        
                        ForEach(groupedAssignments[dueDate] ?? [], id: \.0) { assignmentId, groupId, _, title in
                            NavigationLink(destination: AssignmentDetailView(assignmentId: assignmentId, groupId: groupId)) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(title)
                                            .font(.system(size: 16, weight: .medium, design: .rounded))
                                            .foregroundColor(Color(hex: "#5B5E73"))
                                        
                                        Text("Group: \(groupId)")
                                            .font(.system(size: 14, design: .rounded))
                                            .foregroundColor(Color(hex: "#5B5E73").opacity(0.7))
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(Color(hex: "#5B5E73").opacity(0.5))
                                }
                                .padding()
                                .background(Color(hex: "#ECE3DF").opacity(0.5))
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }

    private func fetchCoachGroups() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("❌ User not logged in.")
            return
        }
        
        let db = Firestore.firestore()
        db.collection("groups")
            .whereField("coachId", arrayContains: userId)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print("❌ Error fetching groups: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    print("⚠️ No groups found.")
                    return
                }
                
                let groupNames = documents.compactMap { $0.data()["name"] as? String }
                DispatchQueue.main.async {
                    self.groups = groupNames
                    if !groupNames.isEmpty {
                        self.selectedGroup = groupNames[0]
                        self.fetchAssignments()
                    }
                }
            }
    }

    private func fetchAssignments() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("❌ User not logged in.")
            return
        }
        
        isLoading = true
        print("✅ Fetching assignments for coach ID: \(userId) in group: \(selectedGroup)")
        
        let db = Firestore.firestore()
        
        // First, let's verify the group exists and get its data
        db.collection("groups")
            .whereField("name", isEqualTo: selectedGroup)
            .getDocuments { (groupSnapshot, groupError) in
                if let groupError = groupError {
                    print("❌ Error fetching group: \(groupError.localizedDescription)")
                    self.isLoading = false
                    return
                }
                
                guard let groupDoc = groupSnapshot?.documents.first else {
                    print("⚠️ No group found with name: \(self.selectedGroup)")
                    self.isLoading = false
                    return
                }
                
                print("📌 Found group document: \(groupDoc.documentID)")
                print("📌 Group data: \(groupDoc.data())")
                
                // Now fetch assignments
                db.collection("assignments")
                    .whereField("coachId", arrayContains: userId)
                    .whereField("groupId", isEqualTo: self.selectedGroup)
                    .getDocuments { (snapshot, error) in
                        if let error = error {
                            print("❌ Error fetching assignments: \(error.localizedDescription)")
                            print("❌ Error details: \(error)")
                            self.isLoading = false
                            return
                        }
                        
                        self.processAssignments(snapshot: snapshot)
                    }
            }
    }
    
    private func processAssignments(snapshot: QuerySnapshot?) {
        guard let documents = snapshot?.documents else {
            print("⚠️ No assignments found or error in snapshot")
            self.isLoading = false
            return
        }
        
        print("📌 Found \(documents.count) assignments")
        
        var tempGroupedAssignments: [String: [(String, String, Timestamp, String)]] = [:]
        
        for document in documents {
            let data = document.data()
            print("📌 Assignment data: \(data)")
            
            let assignmentId = document.documentID
            if let dueDateTimestamp = data["dueDate"] as? Timestamp,
               let title = data["title"] as? String {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .none
                let dueDate = dateFormatter.string(from: dueDateTimestamp.dateValue())
                
                if let groupId = data["groupId"] as? String {
                    print("📌 Found assignment: \(assignmentId), Due: \(dueDate), Group: \(groupId)")
                    tempGroupedAssignments[dueDate, default: []].append((assignmentId, groupId, dueDateTimestamp, title))
                }
            }
        }
        
        DispatchQueue.main.async {
            self.groupedAssignments = tempGroupedAssignments
            self.isLoading = false
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
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ModernBackground()
                
                VStack(spacing: 20) {
                    // Header with back button and group info
                    HStack {
                        ModernBackButton(action: {
                            presentationMode.wrappedValue.dismiss()
                        })
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(groupName ?? "Loading...")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(hex: "#433F4E"))
                            
                            Text("Due: \(dueDate ?? "Loading...")")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(Color(hex: "#5B5E73"))
                        }
                    }
                    .padding(.horizontal)
                    
                    // Refresh button
                    Button(action: {
                        fetchResponses()
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 14, weight: .medium))
                            Text("Refresh")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                        }
                        .foregroundColor(Color(hex: "#5B5E73"))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color(hex: "#ECE3DF").opacity(0.5))
                        .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    
                    if isLoading {
                        loadingView
                    } else if let error = errorMessage {
                        errorView(message: error)
                    } else {
                        TableView(
                            responses: responses,
                            reps: reps,
                            groupName: groupName ?? "Loading..."
                        )
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            fetchResponses()
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.5)
                .tint(Color(hex: "#5B5E73"))
            
            Text("Loading responses...")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(Color(hex: "#5B5E73"))
        }
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundColor(Color(hex: "#5B5E73").opacity(0.5))
            
            Text(message)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(Color(hex: "#5B5E73"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(Color(hex: "#5B5E73").opacity(0.5))
            
            Text("No responses found")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(Color(hex: "#5B5E73"))
            
            Text("Responses will appear here once submitted")
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(Color(hex: "#5B5E73").opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
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
    @State private var selectedAthlete: String? = nil
    let groupName: String
    
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
        VStack(spacing: 0) {
            // Column headers
            HStack(spacing: 0) {
                Button(action: { toggleSort(-1) }) {
                    HStack {
                        Text("Athlete")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                        if sortColumnIndex == -1 {
                            Image(systemName: sortAscending ? "arrow.up" : "arrow.down")
                                .font(.system(size: 12))
                        }
                    }
                    .foregroundColor(Color(hex: "#433F4E"))
                }
                .frame(width: 100, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(reps.indices, id: \.self) { index in
                            Button(action: { toggleSort(index) }) {
                                HStack {
                                    Text(reps[index])
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    if sortColumnIndex == index {
                                        Image(systemName: sortAscending ? "arrow.up" : "arrow.down")
                                            .font(.system(size: 12))
                                    }
                                }
                                .foregroundColor(Color(hex: "#433F4E"))
                            }
                            .frame(width: 50)
                            .padding(.vertical, 8)
                        }
                    }
                }
            }
            .background(Color(hex: "#ECE3DF").opacity(0.5))
            
            // Athlete responses rows
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(sortedAthletes, id: \.self) { athleteName in
                        VStack(spacing: 0) {
                            Button(action: {
                                withAnimation {
                                    selectedAthlete = selectedAthlete == athleteName ? nil : athleteName
                                }
                            }) {
                                HStack(spacing: 0) {
                                    Text(athleteName)
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(Color(hex: "#5B5E73"))
                                        .frame(width: 100, alignment: .leading)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 0) {
                                            ForEach(reps.indices, id: \.self) { index in
                                                Text("\(responses[athleteName]?[safe: index] ?? 0)")
                                                    .font(.system(size: 14, design: .rounded))
                                                    .foregroundColor(Color(hex: "#5B5E73"))
                                                    .frame(width: 50)
                                                    .padding(.vertical, 8)
                                            }
                                        }
                                    }
                                }
                                .background(
                                    selectedAthlete == athleteName ?
                                    Color(hex: "#ECE3DF").opacity(0.3) :
                                    Color.clear
                                )
                            }
                            
                            if selectedAthlete == athleteName {
                                VStack(alignment: .leading, spacing: 8) {
                                    ForEach(reps.indices, id: \.self) { index in
                                        HStack {
                                            Text("Rep \(reps[index]):")
                                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                                .foregroundColor(Color(hex: "#433F4E"))
                                            Text("\(responses[athleteName]?[safe: index] ?? 0) seconds")
                                                .font(.system(size: 14, design: .rounded))
                                                .foregroundColor(Color(hex: "#5B5E73"))
                                        }
                                    }
                                }
                                .padding()
                                .background(Color(hex: "#ECE3DF").opacity(0.2))
                                .transition(.opacity)
                            }
                        }
                    }
                }
            }
        }
        .background(Color(hex: "#ECE3DF").opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
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

