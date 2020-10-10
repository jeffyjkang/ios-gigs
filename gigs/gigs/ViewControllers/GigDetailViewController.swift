//
//  GigDetailViewController.swift
//  gigs
//
//  Created by Jeff Kang on 10/8/20.
//

import UIKit

class GigDetailViewController: UIViewController {
    
    var gigController: GigController!
    var gig: Gig?

    @IBOutlet weak var jobTitleTextField: UITextField!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBAction func saveGig(_ sender: UIBarButtonItem) {
        guard let title = jobTitleTextField.text,
              !title.isEmpty,
              let description = descriptionTextView.text,
              !description.isEmpty else {
            return
        }
        let dueDate = dueDatePicker.date
        
        let gig = Gig(title: title, dueDate: dueDate, description: description)
        
        gigController.createGig(with: gig) { (result) in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            case .failure(let error):
                print("Error saving gigs: \(error)")
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func updateViews() {
        if let gig = gig {
            title = gig.title
            jobTitleTextField.text = gig.title
            dueDatePicker.date = gig.dueDate
            descriptionTextView.text = gig.description
        } else {
            title = "New Gig"
        }
    }

}
