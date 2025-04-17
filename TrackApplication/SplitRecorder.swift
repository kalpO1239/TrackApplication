import SwiftUI
import Firebase
import FirebaseAuth

struct SplitRecorder: View {
    @State private var groups: [String] = []
    @State private var selectedGroup: String = ""
    @State private var assignment: [String] = []
    @State private var inputs: [String] = []
    @State private var assignmentTitle: String = ""
    @State private var isLoading = false
    @EnvironmentObject var workoutDataManager: WorkoutDataManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ModernBackground()
                
                VStack(spacing: 20) {
                    // Back button
                    HStack {
                        ModernBackButton(action: {
                            presentationMode.wrappedValue.dismiss()
                        })
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Rest of the content
                    groupTabs
                    refreshButton
                    contentView
                    Spacer()
                }
                .padding(.vertical)
            }
            .onAppear {
                fetchUserGroups()
            }
        }
    }
    
    private var mainContent: some View {
        VStack(spacing: 20) {
            groupTabs
            refreshButton
            contentView
            Spacer()
        }
        .padding(.vertical)
    }
    
    private var groupTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(groups, id: \.self) { group in
                    groupTabButton(group: group)
                }
            }
            .padding(.horizontal)
        }
        .padding(.top, 20)
    }
    
    private func groupTabButton(group: String) -> some View {
        Button(action: {
            selectedGroup = group
            fetchAssignment()
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
    
    private var refreshButton: some View {
        HStack {
            Spacer()
            Button(action: fetchAssignment) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(hex: "#5B5E73"))
                    .padding(8)
                    .background(Color(hex: "#ECE3DF").opacity(0.5))
                    .cornerRadius(8)
            }
            .padding(.trailing)
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if isLoading {
            loadingView
        } else if !assignment.isEmpty {
            assignmentView
        } else {
            noAssignmentView
        }
    }
    
    private var loadingView: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle())
            .scaleEffect(1.5)
            .padding()
    }
    
    private var noAssignmentView: some View {
        Text("No assignment found")
            .font(.system(size: 16, weight: .medium, design: .rounded))
            .foregroundColor(Color(hex: "#5B5E73"))
            .padding()
    }
    
    private var assignmentView: some View {
        VStack(spacing: 15) {
            if !assignmentTitle.isEmpty {
                Text(assignmentTitle)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(hex: "#433F4E"))
                    .padding(.bottom, 5)
            }
            
            ForEach(Array(assignment.enumerated()), id: \.offset) { index, _ in
                assignmentRow(index: index)
            }
            
            submitButton
        }
        .padding()
        .background(Color(hex: "#ECE3DF").opacity(0.5))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private func assignmentRow(index: Int) -> some View {
        HStack {
            Text(assignment[index])
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(Color(hex: "#5B5E73"))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            TextField("Enter split", text: $inputs[index])
                .padding()
                .background(Color(hex: "#ECE3DF").opacity(0.5))
                .cornerRadius(8)
                .foregroundColor(Color(hex: "#5B5E73"))
                .accentColor(Color(hex: "#5B5E73"))
                .placeholder(when: inputs[index].isEmpty) {
                    Text("Enter split")
                        .foregroundColor(Color(hex: "#5B5E73").opacity(0.5))
                }
        }
        .padding(.horizontal)
    }
    
    private var submitButton: some View {
        Button(action: submit) {
            Text("Submit")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [
                            Color(hex: "#5B5E73"),
                            Color(hex: "#433F4E")
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(12)
        }
        .padding(.horizontal)
    }
    
    private func fetchUserGroups() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        db.collection("orgs").document(userId).getDocument { (document, error) in
            if let document = document, document.exists {
                if let userGroups = document.data()?["groups"] as? [String] {
                    DispatchQueue.main.async {
                        self.groups = userGroups
                        if !userGroups.isEmpty {
                            self.selectedGroup = userGroups[0]
                            self.fetchAssignment()
                        }
                    }
                }
            }
        }
    }
    
    private func fetchAssignment() {
        guard !selectedGroup.isEmpty,
              let userId = Auth.auth().currentUser?.uid else {
            print("Missing required data: selectedGroup = \(selectedGroup), userId = \(Auth.auth().currentUser?.uid ?? "nil")")
            return
        }
        
        // Reset state before fetching
        DispatchQueue.main.async {
            self.assignment = []
            self.inputs = []
            self.assignmentTitle = ""
            self.isLoading = true
        }
        
        let db = Firestore.firestore()
        print("Fetching assignment for group: \(selectedGroup), userId: \(userId)")
        
        // Fetch assignments where the user is in athleteIds
        db.collection("assignments")
            .whereField("groupId", isEqualTo: selectedGroup)
            .whereField("athleteIds", arrayContains: userId)
            .order(by: "dueDate", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching assignments: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                    return
                }
                
                print("Found \(snapshot?.documents.count ?? 0) assignments")
                
                // Find the first assignment where the user hasn't responded
                let unrespondedAssignment = snapshot?.documents.first { doc in
                    let data = doc.data()
                    if let responses = data["responses"] as? [String: Any],
                       responses.keys.contains(userId) {
                        return false // User has already responded
                    }
                    return true // User hasn't responded
                }
                
                guard let assignmentDoc = unrespondedAssignment else {
                    print("No unresponded assignment found")
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                    return
                }
                
                print("Assignment data: \(assignmentDoc.data())")
                
                guard let fields = assignmentDoc.data()["reps"] as? [String],
                      let title = assignmentDoc.data()["title"] as? String else {
                    print("Missing required fields in assignment data")
                    print("Fields: \(assignmentDoc.data()["reps"] ?? "nil")")
                    print("Title: \(assignmentDoc.data()["title"] ?? "nil")")
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    self.assignment = fields
                    self.assignmentTitle = title
                    self.inputs = Array(repeating: "", count: fields.count)
                    self.isLoading = false
                    print("Successfully loaded assignment: \(title) with \(fields.count) fields")
                }
            }
    }
    
    private func submit() {
        guard let userId = Auth.auth().currentUser?.uid,
              !selectedGroup.isEmpty,
              !assignment.isEmpty else { return }
        
        let db = Firestore.firestore()
        
        // Find the most recent assignment
        db.collection("assignments")
            .whereField("groupId", isEqualTo: selectedGroup)
            .whereField("athleteIds", arrayContains: userId)
            .order(by: "dueDate", descending: true)
            .limit(to: 1)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error finding assignment: \(error.localizedDescription)")
                    return
                }
                
                guard let assignmentDoc = snapshot?.documents.first else {
                    print("Assignment not found")
                    return
                }
                
                let assignmentId = assignmentDoc.documentID
                let assignmentData = assignmentDoc.data()
                
                // Parse the inputs to integers (assuming they are times in seconds)
                let parsedInputs = inputs.map { parseTimeInput($0) }
                
                // Update the responses field in the assignment document
                db.collection("assignments").document(assignmentId).updateData([
                    "responses.\(userId)": parsedInputs
                ]) { error in
                    if let error = error {
                        print("Error submitting responses: \(error.localizedDescription)")
                        return
                    }
                    
                    print("Responses successfully submitted to assignment")
                    
                    // Now store in workouts collection
                    if let reps = assignmentData["reps"] as? [String] {
                        // Calculate total distance in meters
                        var totalMeters = 0
                        for rep in reps {
                            if let meterValue = Int(rep.filter { $0.isNumber }) {
                                totalMeters += meterValue
                            }
                        }
                        
                        // Convert meters to miles (1 mile = 1609.34 meters)
                        let miles = Double(totalMeters) / 1609.34
                        
                        // Calculate total time in minutes
                        let totalSeconds = parsedInputs.reduce(0, +)
                        let timeInMinutes = totalSeconds / 60
                        
                        // Create description in format rep1:time1,...,repn:timen
                        let description = zip(reps, parsedInputs).map { rep, time in
                            let minutes = time / 60
                            let seconds = time % 60
                            return "\(rep) - \(String(format: "%02d:%02d", minutes, seconds))"
                        }.joined(separator: ", ")
                        
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
                            "assignmentId": assignmentId,
                            "description": description
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
                                    // Clear inputs after successful submission
                                    self.inputs = Array(repeating: "", count: self.assignment.count)
                                }
                            }
                        }
                    }
                }
            }
    }
    
    /// Parses user input from MM:SS format to total seconds
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
            .environmentObject(WorkoutDataManager.shared)
    }
}
