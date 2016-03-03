//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Angelo Wong on 2/26/16.
//  Copyright © 2016 Stanford. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    private enum Op: CustomStringConvertible {
        case Operand(Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        case ClearOperation(String)
        case PiOperation(String)
        case Variable(String)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _ ):
                    return symbol
                case .ClearOperation(let symbol):
                    return symbol
                case .PiOperation(let symbol):
                    return symbol
                case .Variable(let symbol):
                    return symbol
                }
            }
        }
    }
    
    private var opStack = [Op]()
    
    private var knownOps = [String:Op]()
    
    var variableValues = [String:Double]()
    
    init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        learnOp(Op.BinaryOperation("×", *))
        learnOp(Op.BinaryOperation("÷") { $1 / $0 })
        learnOp(Op.BinaryOperation("+", +))
        learnOp(Op.BinaryOperation("-") { $1 - $0 })
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("cos", cos))
        learnOp(Op.UnaryOperation("ᐩ/-", -))
        learnOp(Op.ClearOperation("C"))
        learnOp(Op.PiOperation("π"))
//        learnOp(Op.Variable("x="))
    }
    
    //pass back and forth the program operation stack
    typealias PropertyList = AnyObject
    
    var program: PropertyList { //guaranteed to be a PropertyList
        get {
            return opStack.map{ $0.description }
        }
        set {
            if let opSymbols = newValue as? Array<String> {
                var newOpStack = [Op]()
                for opSymbol in opSymbols {
                    if let op = knownOps[opSymbol] {
                        newOpStack.append(op)
                    } else if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue {
                        newOpStack.append(.Operand(operand))
                    }
                }
                opStack = newOpStack
            }
        }
    }
    
    var description: String {
        var describeString: [String] = []
        var described = describe(opStack)

        if let firstDescriptor = described.descriptor {
            describeString.append(firstDescriptor)
        }
        while !described.remainingOps.isEmpty {
            described = describe(described.remainingOps)
            if let anotherDescriptor = described.descriptor {
                describeString.append(anotherDescriptor)
            }
        }
        return describeString.reverse().joinWithSeparator(",") ?? " "
    }
    
    private func describe(ops: [Op]) -> (remainingOps: [Op], descriptor: String?) {
        if !ops.isEmpty{
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Variable(let symbol):
                return (remainingOps, symbol)
            case .Operand(let operand):
                return (remainingOps, "\(operand)")
            case .UnaryOperation(let symbol, _):
                let described = describe(remainingOps)
                return (described.remainingOps, "\(symbol)(\(described.descriptor ?? "?"))")
            case .BinaryOperation(let symbol, _):
                let op1Described = describe(remainingOps)
                let op2Described = describe(op1Described.remainingOps)
                var binaryDescription: String
                binaryDescription = "(\(op2Described.descriptor ?? "?") \(symbol) \(op1Described.descriptor ?? "?"))"
                return (op2Described.remainingOps, binaryDescription)
            case .ClearOperation(_):
                return (ops, nil)
            case .PiOperation(_):
                return (remainingOps, "π")
            }
        }
        return (ops, nil)
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Variable(let operand):
                if let variableValue = variableValues[operand] {
                    return (variableValue, remainingOps)
                }
                return (nil, remainingOps)
            case .Operand(let operand):
                return (operand, remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        print("op1: \(operand1); op2: \(operand2)")
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            case .ClearOperation(_):
                opStack = []
                variableValues = [:]
                return (0, [])
            case .PiOperation(_):
                return (M_PI, remainingOps) //no .removeLast() since we need to wait for an operation to operate on pi
            }
        }
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        print("\(opStack) = \(result) with \(remainder) left over")
        return result
    }
    
    func pushOperand(operand: Double?) -> Double? {
        if let validOperand = operand {
            opStack.append(Op.Operand(validOperand))
        }
        return evaluate()
    }
    
    func pushOperand(variableSymbol: String) -> Double? {
        opStack.append(Op.Variable(variableSymbol))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    
}