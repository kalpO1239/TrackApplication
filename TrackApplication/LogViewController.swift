//
//  LogViewController.swift
//  TrackApplication
//
//  Created by Kalp Ostawal on 12/28/24.
//


import UIKit

class LogViewController: UIViewController {
    
    // UI elements (Text fields, Buttons, etc.)
    @IBOutlet weak var milesTextField: UITextField!
    @IBOutlet weak var timeTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func logWorkoutButtonTapped(_ sender: UIButton) {
        // Get values from text fields
        guard let milesText = milesTextField.text, let miles = Double(milesText),
              let timeText = timeTextField.text, let time = Double(timeText) else {
            return
        }
        
        // Save workout data in the WorkoutDataManager
        WorkoutDataManager.shared.addWorkout(miles: miles, time: time)
        
        // Navigate to GraphViewController
        performSegue(withIdentifier: "showGraph", sender: nil)
    }
}
