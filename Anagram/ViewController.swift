//
//  ViewController.swift
//  Anagram
//
//  Created by Robert Johnson on 3/29/17.
//  Copyright © 2017 Robert Johnson. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    typealias Word = String
    
    func arrayFromContentsOfFileWithName(fileName: String) -> Array<Word>? {
        guard let path = Bundle.main.path(forResource: fileName, ofType: "txt") else {
            return nil
        }
        
        do {
            let content = try String(contentsOfFile:path, encoding: String.Encoding.utf8)
            // TODO: Optimize
            return content.characters.split(separator: "\n").map(String.init)
        } catch _ as NSError {
            return nil
        }
    }
    
    func findAnagrams(_ word: Word, in words: Array<Word>,parent: Node?=nil, complete: @escaping (Node) -> Void) {
    // func findAnagrams(_ target: Word, in words: Array<Word>, pad: String = "") -> Node? {
        
        
        DispatchQueue.global(qos: .userInitiated).async {
      
            
            let targetCharacters = word.replacingOccurrences(of: " ", with: "").characters //.sorted()
            
            for candidate in words {
                // Optimization #1
                // In the dictionary file, every letter in the alphabet is also word, for our sake only consider i and a
                if (candidate.characters.count == 1) {
                    if (candidate != "a" && candidate != "i") {
                        continue
                    }
                }
                
                let candidateCharacters = candidate.characters
                
                // Optimization #2
                // If the candidate is longer than the target, continue
                if (candidateCharacters.count > targetCharacters.count) {
                    // print("\(candidate) is too long")
                    continue
                }
                
                var matches = true
                
                // Remove all the letters from the target word that are in the candidate
                // If all are present, we have a match and fire off a new search with the remaining letters in the target. Continue.
                // If not all are present, there is no match. Continue.
                var t = targetCharacters
                for char in candidateCharacters {
                    if let i = t.index(of: char) {
                        t.remove(at: i)
                    } else {
                        matches = false
                        break
                    }
                }
                
                if matches {
                    // print("\(candidate) in \(target)")
                    //node = team
                    
                    let child = Node(value: String(candidate))
                    //child = am
                    
                    //node.add(child: child)
                    parent?.add(child: child)
                    
                    //t = te
                    
                    self.findAnagrams(String(t), in: words, parent: child) { _ in
                        
                    }

                }
            }
            
            DispatchQueue.main.async {
                complete(parent!)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let words = arrayFromContentsOfFileWithName(fileName: "words") {
            let word = "meats"
            let node = Node(value: word)
            findAnagrams(word, in: words, parent: node) { node in
                print("here")
            }
            
        }
        
        print("here")
    }

}

class Node {
    var value: String
    var children: [Node] = []
    weak var parent: Node?
    
    init(value: String) {
        self.value = value
    }
    
    func add(child: Node) {
        children.append(child)
        child.parent = self
    }
}

extension Node: CustomStringConvertible {
    var description: String {
        var text = "\(value)"
        
        if !children.isEmpty {
            text += " {" + children.map { $0.description }.joined(separator: ", ") + "} "
        }
        
        return text
    }
}
