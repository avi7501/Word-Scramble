//
//  ViewController.swift
//  Project 5
//
//  Created by Avinash Muralidharan on 31/08/23.
//

import UIKit

class ViewController: UITableViewController {
    
    var allWords = [String]()
    var usedWords = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        
        if let startWordURL = Bundle.main.url(forResource: "start", withExtension: ".txt"){
            
            if let startWords = try? String(contentsOf: startWordURL){
                allWords  = startWords.components(separatedBy: "\n")
            }
        }
        
        if allWords.isEmpty{
            allWords = ["silkworm"]
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Start New Game", style: .plain, target: self, action: #selector(startGame))
 
    }
    
   @objc func startGame(){
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for:indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
    @objc func promptForAnswer(){
        
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        let submitAction = UIAlertAction(title: "Submit", style: .default){
            [weak self, weak ac] action in
            guard let answer = ac?.textFields?[0].text else {return}
            self?.submit(answer)
        }
        
        ac.addAction(submitAction)
        present(ac,animated: true)
    }
    
    func submit(_ answer :String){
        let lowerAnswer = answer.lowercased()
       
        if isLong(word: lowerAnswer){
            if isNotStartingWord(word: lowerAnswer){
                if isPossible(word: lowerAnswer)
                {
                   
                    if isOriginal(word: lowerAnswer){
                    
                        if isReal(word: lowerAnswer){
                         
                            usedWords.insert(lowerAnswer, at: 0)
                            
                            let indexPath = IndexPath(row: 0, section: 0)
                            tableView.insertRows(at: [indexPath], with: .automatic)
                            
                            return
                        }
                        else{
                            showErrorMessage(errorTitle:"Word not recognised", errorMessage: "You,can't make them up you know!")
                        }
                    }
                    else{
                        showErrorMessage(errorTitle:"Word already used", errorMessage: "Be more original!")
                    }
                }
                else{
                    guard let title = title else { return }
                    showErrorMessage(errorTitle:"Word not possible", errorMessage: "You can't spell that word from \(title.lowercased())")
                }
            }
            else{
                showErrorMessage(errorTitle: "Word is the Starting Word", errorMessage:  "You can't just use the starting word!")
            }
        }
        else{
            showErrorMessage(errorTitle:"Word is too short" , errorMessage: "Need more letters than that!")
        }
        
        
        
    }
    
    func isPossible(word : String) -> Bool{
        guard var tempWord = title?.lowercased() else {return false}

        for letter in word{
            if let position = tempWord.firstIndex(of: letter){
                tempWord.remove(at: position)
            }else{
               return  false
            }
        }
        return true
    }
    
    func isLong(word : String) -> Bool{
        return word.count > 3
    }
    
    func isNotStartingWord(word : String) -> Bool{
        return word != title!
    }
    
    func isOriginal(word : String) -> Bool{
        return !usedWords.contains(word) || !usedWords.contains(word.lowercased())
    }
    func showErrorMessage(errorTitle : String , errorMessage : String){
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac,animated: true)
    }
    func isReal(word : String) -> Bool{
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

        return misspelledRange.location == NSNotFound
    }
}

