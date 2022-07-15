//
//  ViewController.swift
//  Hangman
//
//  Created by Huy Bui on 2022-07-14.
//

import UIKit

class ViewController: UIViewController {

    var promptWordLabel: UILabel!,
        guessesRemainingStatus: UIBarButtonItem!,
        scoreStatus: UIBarButtonItem!,
        incorrectLettersStatus: UIBarButtonItem!
    
    var words: [String]!
    var word: String! {
        didSet { updatePromptWord() }
    }
    var guessesRemaining: Int! {
        didSet { updateGuessesRemaining() }
    }
    var score: Int! {
        didSet { updateScore() }
    }
    var correctLetters: Set<String>! {
        didSet { updatePromptWord() }
    }
    var incorrectLetters: Set<String>! {
        didSet { updateIncorrectLetters() }
    }
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        
        title = "Hangman"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.isToolbarHidden = false

        // MARK: Prompt word label
        
        promptWordLabel = UILabel()
        promptWordLabel.translatesAutoresizingMaskIntoConstraints = false
        promptWordLabel.textColor = .black
        promptWordLabel.textAlignment = .center
        promptWordLabel.addObserver(self, forKeyPath: #keyPath(UILabel.text), options: .new, context: nil)
        view.addSubview(promptWordLabel)
        
        NSLayoutConstraint.activate([
            promptWordLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            promptWordLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // MARK: Bar button items
        
        // Guesses remaining status
        guessesRemainingStatus = getInfoUIBarButtonItem()
        navigationItem.leftBarButtonItem = guessesRemainingStatus
        
        // Score status
        scoreStatus = getInfoUIBarButtonItem()
        navigationItem.rightBarButtonItem = scoreStatus
        
        // Incorrect letters status
        incorrectLettersStatus = getInfoUIBarButtonItem()
        incorrectLettersStatus.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.thick.rawValue,
            NSAttributedString.Key.strikethroughColor: UIColor.red,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20.0)
        ], for: .disabled)
        
        // Space items
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace.width = 10.0
        
        toolbarItems = [
            incorrectLettersStatus,
            flexibleSpace,
            UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame)), // Restart button
            fixedSpace,
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(inputGuess)) // Input guess button
        ]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let startWordsURL = Bundle.main.url(forResource: "words", withExtension: "txt") {
                if let words = try? String(contentsOf: startWordsURL) {
                    self.words = words.components(separatedBy: "\n");
                }
            }
            
            if self.words.isEmpty {
                self.words = ["broken"]
            }
            
            DispatchQueue.main.async {
                self.startGame()
            }
        }
        
        score = 0
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "text" {
            promptWordLabel.setCharacterSpacing(kernValue: 15)
            promptWordLabel.sizeToFitScreen(maxFontSize: 60, threshold: 25)
        }
    }
    
    @objc func inputGuess() {
        let alertController = UIAlertController(title: nil, message: "Enter your guess", preferredStyle: .alert)
        alertController.addTextField()
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.addAction(UIAlertAction(title: "Enter", style: .default) {
            [weak self] _ in
            guard let input = alertController.textFields?[0].text?.lowercased() else { return }
            
            if input.isEmpty {
                self?.showErrorAlert("Your guess must not be empty")
            } else {
                self?.processGuess(input.lowercased())
            }
        })
        present(alertController, animated: true)
    }
    
    func processGuess(_ guess: String) {
        let word = word.lowercased()
        
        // Single-letter guess
        if guess.count == 1 {
            if word.contains(guess) {
                correctLetters.insert(guess)
                if !(promptWordLabel.text?.contains("_") ?? false) {
                    gameOver()
                    return
                }
            } else {
                incorrectLetters.insert(guess)
            }
        }
        
        // Word guess
        else if guess.count > 1 {
            if guess == word {
                gameOver()
                return
            } else {
                showErrorAlert("Incorrect guess")
            }
        }
        
        guessesRemaining -= 1
        if guessesRemaining == 0 {
            gameOver()
        }
    }
    
    @objc func startGame(_: UIAlertAction? = nil) {
        word = words?.randomElement()
        while word.isEmpty {
            word = words?.randomElement()
        }
        
        guessesRemaining = 7
        correctLetters = Set<String>()
        incorrectLetters = Set<String>()
    }

    func gameOver() {
        var title:String, actionTitle: String,
            message = "The word was \"\(word!)\"."
        
        if guessesRemaining > 0 {
            score += 1
            title = "You won!"
            actionTitle = "Play again"
        } else {
            title = "You ran out of guesses!"
            actionTitle = "Try again"
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: actionTitle, style: .default, handler: startGame))
        present(alertController, animated: true)
    }
    
    func getInfoUIBarButtonItem() -> UIBarButtonItem {
        let infoUIBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
        infoUIBarButtonItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .disabled)
        infoUIBarButtonItem.isEnabled = false
        
        return infoUIBarButtonItem
    }
    
    func showErrorAlert(_ message: String = "An unknown error occured") {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alertController, animated: true)
    }
    
    func updateGuessesRemaining() {
        guessesRemainingStatus.title = "Guesses remaining: \(guessesRemaining!)"
    }
    
    func updateScore() {
        scoreStatus.title = "Score: \(score!)"
    }
    
    func updatePromptWord() {
        var promptWord = ""
        guard let word = word?.lowercased() else { return }
        
        for letterCharacter in word {
            let letter = String(letterCharacter)
            if correctLetters?.contains(letter) ?? false {
                promptWord += letter
            } else {
                promptWord += "_"
            }
        }
        
        promptWordLabel.text = promptWord.uppercased()
    }
    
    func updateIncorrectLetters() {
        var usedLettersStr = ""
        
        for (index, letter) in incorrectLetters.enumerated() {
            if index > 0 {
                usedLettersStr += ", "
            }
            usedLettersStr += "\(letter.uppercased())"
        }
        
        incorrectLettersStatus.title = usedLettersStr
    }
    
    
}

