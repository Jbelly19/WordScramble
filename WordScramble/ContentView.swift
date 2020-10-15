//
//  ContentView.swift
//  WordScramble
//
//  Created by Josh Belmont on 10/13/20.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var score = 0
    
    func startGame() {
        // Find the URL for start.txt in our app bundle
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            // Load start.txt into a string
            if let startWords = try? String(contentsOf: startWordsURL) {
                // Split the string up into an array of strings, splitting on new lines
                let allWords = startWords.components(separatedBy: "\n")
                
                // Pick one random word or use 'silkworm' as a default
                rootWord = allWords.randomElement() ?? "silkworm"
                
                score = 0
                
                // if we are here, everything worked
                return
            }
        }
        
        // if we are *here* then there was a problem - trigger a crash and report the error
        fatalError("Could not load start.txt from bundle.")
    }
    
    func addNewWord() {
        // lowercase trim the word to make sure we dont add duplicates with different cases
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // exit if the remaining string is empty
        guard answer.count > 0 else {
            // guard lets you check a condition but keeps unrwapped optionals in scope
            return
        }
        
        guard answer.count > 2 else {
            wordError(title: "Too short!", message: "Please use words of length 3 or more")
            return
        }
        
        guard answer != rootWord else {
            wordError(title: "Thats cheating!", message: "Can't use the original word")
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not possible", message: "This isn't a real word.")
            return
        }
        
        updateScore(word: answer)
        usedWords.insert(answer, at: 0)
        newWord = ""
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter){
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func updateScore(word: String){
        switch word.count {
        case 3:
            score += 1
        case 4...6:
            score += 2
        case 7...8:
            score += 3
        default:
            return
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                    .autocapitalization(.none)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                List(usedWords, id: \.self) {
                    Image(systemName: "\($0.count).circle")
                    Text($0)
                }
                Text("Score: \(score)")
            }
            .navigationBarTitle(rootWord)
            .onAppear(perform: startGame)
            .alert(isPresented: $showingError) {
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
            .navigationBarItems(trailing: Button(action: startGame){
                Text("New Word")
            })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
