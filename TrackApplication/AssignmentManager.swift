//
//  AssignmentManager.swift
//  TrackApplication
//
//  Created by Kalp Ostawal on 1/18/25.
//


import FirebaseFirestore
import FirebaseAuth

class AssignmentManager {
    
    static let shared = AssignmentManager()
    
    private init() {}
    
    func createAssignment(title: String, description: String, dueDate: Date, assignedTo: [String]) {
        let db = Firestore.firestore()
        
        let assignmentData: [String: Any] = [
            "title": title,
            "description": description,
            "dueDate": Timestamp(date: dueDate),
            "assignedTo": assignedTo,
            "createdBy": Auth.auth().currentUser?.uid ?? "",
            "createdAt": Timestamp(date: Date())
        ]
        
        db.collection("assignments").addDocument(data: assignmentData) { error in
            if let error = error {
                print("Error adding assignment: \(error.localizedDescription)")
            } else {
                print("Assignment created successfully!")
            }
        }
    }
    
    func getAssignmentsForAthlete(athleteId: String, completion: @escaping ([Assignment]) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("assignments")
            .whereField("assignedTo", arrayContains: athleteId)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching assignments: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                var assignments: [Assignment] = []
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let assignment = Assignment(
                        id: document.documentID,
                        title: data["title"] as? String ?? "",
                        description: data["description"] as? String ?? "",
                        dueDate: (data["dueDate"] as? Timestamp)?.dateValue() ?? Date(),
                        assignedTo: data["assignedTo"] as? [String] ?? [],
                        createdBy: data["createdBy"] as? String ?? ""
                    )
                    assignments.append(assignment)
                }
                completion(assignments)
            }
    }
}

struct Assignment {
    let id: String
    let title: String
    let description: String
    let dueDate: Date
    let assignedTo: [String]
    let createdBy: String
}
