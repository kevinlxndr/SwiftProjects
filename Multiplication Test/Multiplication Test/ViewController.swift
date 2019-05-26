//
//  ViewController.swift
//  Multiplication Test
//
//  Created by Kevin Ramsussen on 8/21/18.
//  Copyright © 2018 Kevin Rasmussen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var multiplier: UILabel!
    @IBOutlet weak var result: UILabel!
    @IBOutlet weak var multiplicand: UILabel!
    @IBOutlet weak var blackLine: UILabel!
    @IBOutlet weak var correctLabel: UILabel!
    @IBOutlet weak var answerButtons: UISegmentedControl!
    @IBOutlet weak var hintButton: UIButton!
    
    let maxQuestions : Int = 5
    let maxRange : Int = 5
    let numberOfAnswers : Int = 4
    
    var numberCorrect : Int = 0
    var multiplierNumber : Int = 0
    var multiplicandNumber : Int = 0
    var answer : Int = 0
    var resultNumber : Int = 0
    var count : Int = 0
    var hintCount : Int = 0
    var randomArray : [Int] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        while answerButtons.numberOfSegments < numberOfAnswers{
            answerButtons.insertSegment(withTitle: "", at: answerButtons.numberOfSegments - 1, animated: false)
        }
     
   
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func generateProblems(){
        answerButtons.isEnabled = false
        answerButtons.isSelected = false
        multiplierNumber = Int(arc4random_uniform(14)) + 1
        multiplicandNumber = Int(arc4random_uniform(14)) + 1
        answer = multiplierNumber * multiplicandNumber
        
        multiplier.text = "\(multiplierNumber)"
        multiplicand.text = "\(multiplicandNumber)"
        
        randomArray = []
        
        for i in 1...maxRange{
                randomArray.append(answer + i)
                randomArray.append(answer - i)
        }
        
        var valueStore : Int = 0
        var index : Int = 0
        let firstIndex : Int = Int(arc4random_uniform(UInt32(numberOfAnswers - 1)))
        answerButtons.setTitle("\(answer)", forSegmentAt: firstIndex)
        
        for i in 1...numberOfAnswers {
            index = Int(arc4random_uniform(UInt32(randomArray.count - i)))
            valueStore = randomArray[index]
            randomArray.remove(at: index)
                if answerButtons.titleForSegment(at: i - 1) != String(answer){
                    answerButtons.setTitle("\(valueStore)", forSegmentAt: (i - 1))
                }
        }
        answerButtons.isEnabled = true
        correctLabel.text = "\(numberCorrect)/\(maxQuestions) Correct"
    }
    
    @IBAction func hintAction(_ sender: Any) {
        var i :Int = 0
        if hintCount < numberOfAnswers - 2 {
            
            var tempIndex : Int = Int(arc4random_uniform(UInt32(numberOfAnswers-1)))
            
            while i<1{
                if (answerButtons.titleForSegment(at: tempIndex) != String(answer) && answerButtons.isEnabledForSegment(at: tempIndex) == true) {
                    if answerButtons.selectedSegmentIndex == tempIndex{
                        result.text = "0"
                        answerButtons.selectedSegmentIndex = -1
                    }
                    answerButtons.setEnabled(false, forSegmentAt: tempIndex)
                    i = 1
                }
                else{
                     tempIndex = Int(arc4random_uniform(UInt32(numberOfAnswers-1)))
                }
            }
            
            hintCount += 1
            
            if hintCount == numberOfAnswers - 2{
                hintButton.isHidden = true
                hintButton.isEnabled = false
            }
        }
        i = 0
        

    }
    
    func refreshHint(){
        hintButton.isEnabled = true
        hintButton.isHidden = false
        for i in 0...numberOfAnswers - 1{
            answerButtons.setEnabled(true, forSegmentAt: i)
        }
        hintCount = 0
        answerButtons.selectedSegmentIndex = -1
        
    }
    
    @IBAction func showAnswer(_ sender: UISegmentedControl) {
        result.text = "\(answerButtons.titleForSegment(at: answerButtons.selectedSegmentIndex) ?? "0")"
    }
    @IBAction func startTest(_ sender: Any) {
        if count == 0 {
            generateProblems()
            multiplier.isHidden = false
            multiplicand.isHidden = false
            result.isHidden = false
            blackLine.isHidden = false
            correctLabel.isHidden = false
            answerButtons.isHidden = false
            answerButtons.isEnabled = true
            hintButton.isHidden = false
            hintButton.isEnabled = true
            answerButtons.isSelected = false
            
            result.text = "0"
            
            startButton.setTitle( "Submit", for: .normal)
            refreshHint()
            count += 1
        }
        else if count > 0 && count < maxQuestions{
            if answerButtons.selectedSegmentIndex == -1{
                correctLabel.text = "No Answer Selected"
            }
            else if answerButtons.titleForSegment(at: answerButtons.selectedSegmentIndex) == String(answer){
                numberCorrect += 1
                count += 1
                generateProblems()
                refreshHint()
            }
            else{
                generateProblems()
                count += 1
                refreshHint()
               
            }
            if count <= maxQuestions{
                result.text = "0"
            }

        }
        else {
            if result.text == String(answer){
                numberCorrect += 1
            }
            hintButton.isEnabled = false
            answerButtons.isEnabled = false
            correctLabel.text = "Your grade is \(numberCorrect)/\(maxQuestions) "
            startButton.setTitle("Retake", for: .normal)
            numberCorrect = 0
            count = 0
        }
        
    }
    }
    


