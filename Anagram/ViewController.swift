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
    
    func findAnagrams(_ node: Node, in words: Array<Word>, complete: @escaping (Node) -> Void) {
    // func findAnagrams(_ target: Word, in words: Array<Word>, pad: String = "") -> Node? {
        
        
        DispatchQueue.global(qos: .userInitiated).async {
      
            let target = node.value
            let targetCharacters = target.replacingOccurrences(of: " ", with: "").characters //.sorted()
            
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
                    
                    let child = Node(value: String(candidate))
                    node.add(child: child)
                    let newTarget = Node(value: String(t))
                    self.findAnagrams(newTarget, in: words) { _ in
                        
                    }

                }
            }
            
            DispatchQueue.main.async {
                complete(node)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let words = arrayFromContentsOfFileWithName(fileName: "words") {
            
            let node = Node(value: "meat")
            findAnagrams(node, in: words) { node in
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
