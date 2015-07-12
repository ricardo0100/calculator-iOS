//
//  CalculatorBrain.swift
//  calculator
//
//  Created by Ricardo Gehrke Filho on 12/07/15.
//  Copyright © 2015 Ricardo Gehrke Filho. All rights reserved.
//

import Foundation

class CalculatorBrain
{
    private enum Op {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
    }
    
    private var knownOps = [String:Op]()
    
    private var opStack = [Op]()
    
    init() {
        knownOps["×"] = Op.BinaryOperation("×") { $0 * $1 }
        knownOps["÷"] = Op.BinaryOperation("÷") { $1 / $0 }
        knownOps["+"] = Op.BinaryOperation("+") { $0 + $1 }
        knownOps["−"] = Op.BinaryOperation("−") { $1 - $0 }
        knownOps["√"] = Op.UnaryOperation("√", sqrt)  //⚠️ Abreviação: { sqrt($0) }: (double) -> double => sqrt
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation);
        }
        return evaluate()
    }
    
    func evaluate() -> Double? {
        let (result, _) = evaluate(opStack)
        return result
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        
        if !ops.isEmpty {
            
            var remainingOps = ops; //⚠️ ops é imutável (let)
            
            let op = remainingOps.removeLast()
            
            //⚠️recursividade
            switch op {
                
            case .Operand(let operand):
                return (operand, remainingOps)
                
            case .UnaryOperation(_, let operation):
                
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
                
            case .BinaryOperation(_, let operation):
                let operation1Evaluation = evaluate(remainingOps)
                
                if let operand1 = operation1Evaluation.result {
                    let operation2Evaluation = evaluate(operation1Evaluation.remainingOps)
                    if let operand2 = operation2Evaluation.result {
                        return (operation(operand1, operand2), operation2Evaluation.remainingOps)
                    }
                }
            }
            
        }
        
        return (nil, ops);
    }
    
}

