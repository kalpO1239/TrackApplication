import SwiftUI

struct LogView: View {
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var selectedDestination: String = "Select Destination"
    @State private var miles: String = ""
    @State private var selectedRunType: String = "Select Run Type"
    @State private var hours: String = ""
    @State private var minutes: String = ""
    @State private var seconds: String = ""

    // Example options for the dropdowns
    let destinations = ["Park", "Track", "Trail", "Road"]
    let runTypes = ["Long Run", "Interval", "Tempo", "Recovery", "Race"]

    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack(spacing: 20) { // Increased space between sections
                        // Title
                        Section {
                            TextField("Enter Title", text: $title)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        }
                        .padding(.horizontal)

                        // Description
                        Section {
                            TextField("Enter Description", text: $description)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        }
                        .padding(.horizontal)

                        // Destination Dropdown
                        Section {
                            Picker("Destination", selection: $selectedDestination) {
                                ForEach(destinations, id: \.self) { destination in
                                    Text(destination)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                        }
                        .padding(.horizontal)

                        // Miles
                        Section {
                            TextField("Enter Miles (e.g., 5.25)", text: $miles)
                                .keyboardType(.decimalPad)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        }
                        .padding(.horizontal)

                        // Time (hh:mm:ss)
                        Section {
                            HStack {
                                TextField("hh", text: $hours)
                                    .keyboardType(.numberPad)
                                    .frame(width: 50)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .shadow(radius: 5)

                                Text(":")
                                    .font(.headline)

                                TextField("mm", text: $minutes)
                                    .keyboardType(.numberPad)
                                    .frame(width: 50)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .shadow(radius: 5)

                                Text(":")
                                    .font(.headline)

                                TextField("ss", text: $seconds)
                                    .keyboardType(.numberPad)
                                    .frame(width: 50)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .shadow(radius: 5)
                            }
                        }
                        .padding(.horizontal)

                        // Run Type Dropdown
                        Section {
                            Picker("Run Type", selection: $selectedRunType) {
                                ForEach(runTypes, id: \.self) { runType in
                                    Text(runType)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                        }
                        .padding(.horizontal)

                    }
                    .padding(.top) // Padding at the top of the form
                }

                // Submit Button
                Button(action: handleSubmit) {
                    Text("Submit")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .shadow(radius: 5)
                }
                .padding(.bottom) // Ensure the button is above the tab bar
            }
            .navigationTitle("Log a Run")
        }
    }

    // Handle Submit
    func handleSubmit() {
        let formattedTime = "\(hours):\(minutes):\(seconds)"
        
        print("Title: \(title)")
        print("Description: \(description)")
        print("Destination: \(selectedDestination)")
        print("Miles: \(miles)")
        print("Run Type: \(selectedRunType)")
        print("Time: \(formattedTime)")
    }
}





struct TabbedView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            LogView()
                .tabItem {
                    Label("Log", systemImage: "square.and.pencil")
                }

            Text("Activity View Coming Soon") // Placeholder for activity tab
                .tabItem {
                    Label("Activity", systemImage: "chart.bar")
                }
        }
    }
}

#Preview {
    TabbedView()
}
