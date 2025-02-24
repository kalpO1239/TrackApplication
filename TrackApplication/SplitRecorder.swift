import SwiftUI

struct SplitRecorder: View {
    let assignment: [String] // Left column values
    @State private var inputs: [String]
    
    init(assignment: [String]) {
        self.assignment = assignment
        _inputs = State(initialValue: Array(repeating: "", count: assignment.count))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Workout")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)
            
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
    
    private func submit() {
        let parsedInputs = inputs.map { parseTimeInput($0) }
        print("Submitted values: \(parsedInputs)")
        //send to coach
        //send to log
    }
    
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
        SplitRecorder(assignment: ["400m", "800m", "Mile"])
    }
}
