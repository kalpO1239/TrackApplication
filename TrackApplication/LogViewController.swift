import UIKit

class LogViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var milesTextField: UITextField!
    @IBOutlet weak var hoursTextField: UITextField!
    @IBOutlet weak var minutesTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.datePickerMode = .date // Configure date picker for selecting a date
    }
    
    @IBAction func logWorkoutButtonTapped(_ sender: UIButton) {
        guard let title = titleTextField.text, !title.isEmpty,
              let milesText = milesTextField.text, let miles = Double(milesText),
              let hoursText = hoursTextField.text, let hours = Int(hoursText),
              let minutesText = minutesTextField.text, let minutes = Int(minutesText) else {
            return
        }
        
        let totalMinutes = hours * 60 + minutes
        let selectedDate = datePicker.date
        
        // Save workout data in the WorkoutDataManager
        WorkoutDataManager.shared.addWorkout(
            date: selectedDate,
            miles: miles,
            title: title,
            timeInMinutes: totalMinutes
        )
        
        // Navigate to the next screen after saving the workout
        self.performSegue(withIdentifier: "showGraph", sender: nil)
    }
}
