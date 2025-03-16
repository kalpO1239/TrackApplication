import FirebaseFirestore
import FirebaseAuth

class GroupManager: ObservableObject {
    @Published var groups: [Group] = []
    private let db = Firestore.firestore()

    func createGroup(name: String, coachId: String, code: String) {
        let newGroup = Group(name: name, coachId: coachId, code: code, athleteIds: [])
        let docRef = db.collection("groups").document()

        do {
            try docRef.setData(from: newGroup)
            print("Group created successfully!")
        } catch {
            print("Error creating group: \(error.localizedDescription)")
        }
    }

    func joinGroup(groupCode: String, athleteId: String) {
        db.collection("groups")
            .whereField("code", isEqualTo: groupCode)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error finding group: \(error.localizedDescription)")
                    return
                }

                guard let document = snapshot?.documents.first else {
                    print("Group not found")
                    return
                }

                // Decode the group from Firestore document
                var group: Group?
                do {
                    group = try document.data(as: Group.self)
                } catch {
                    print("Error decoding group: \(error.localizedDescription)")
                    return
                }

                // Check if group is successfully decoded
                guard var group = group else {
                    print("Error: Group data is invalid")
                    return
                }

                // Append the athleteId to the athleteIds array
                group.athleteIds.append(athleteId)

                // Update Firestore document with the new athleteIds
                do {
                    try document.reference.setData(from: group)
                    print("Athlete added to group!")
                } catch {
                    print("Error updating group: \(error.localizedDescription)")
                }
            }
    }
}

struct Group: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var coachId: String
    var code: String
    var athleteIds: [String]
}
