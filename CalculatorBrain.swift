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
        case UnaryOperation(String, Double -> Double, ((Double)->String?)?)
        case BinaryOperation(String, (Double, Double) -> Double, ((Double,Double)->String?)?)
        case ClearOperation(String)
        case PiOperation(String)
        case Variable(String)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol, _, _):
                    return symbol
                case .BinaryOperation(let symbol, _, _):
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
        
        var precedence: Int {
            switch self {
            case .BinaryOperation(let symbol, _, _):
                switch symbol {
                case "+": fallthrough
                case "-":
                    return 0
                case "×": fallthrough
                case "÷":
                    return 1
                default:
                    return Int.max
                }
            default:
                return Int.max
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
        //recursion stack for some N number of ops in the describeString array
        //can terminate without exploring the entire array
        //Ex: [A,B,C,D,E] -> CDE gets returned to top level and terminates.
        //Solution: Loop through the array until all elements are processed.
        var describeString: [String] = []
        var described = describe(opStack, TOS: true)

        if let firstDescriptor = described.descriptor {
            describeString.append(firstDescriptor)
        }
        while !described.remainingOps.isEmpty {
            described = describe(described.remainingOps, TOS: true)
            if let anotherDescriptor = described.descriptor {
                describeString.append(anotherDescriptor)
            }
        }
        return describeString.reverse().joinWithSeparator(",") ?? " "
    }
    
    private func describe(ops: [Op], TOS: Bool) -> (remainingOps: [Op], descriptor: String?, prevOp: Op?) {
        if !ops.isEmpty{
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Variable(let symbol):
                return (remainingOps, symbol, op)
            case .Operand(let operand):
                return (remainingOps, "\(operand)", op)
            case .UnaryOperation(let symbol, _):
                let described = describe(remainingOps, TOS: false)
                let retStr = op.precedence > described.prevOp?.precedence ?
                    "\(symbol)(\(described.descriptor ?? "?"))" :
                    "\(symbol)\(described.descriptor ?? "?")"
                return (described.remainingOps, retStr, op)
            case .BinaryOperation(let symbol, _):
                let op1Described = describe(remainingOps, TOS: false)
                let op2Described = describe(op1Described.remainingOps, TOS: false)
                var binaryDescription: String
                var prefix: String
                var suffix: String
                let opPrecedence = op.precedence
                let op1Precedence = op1Described.prevOp?.precedence
                let op2Precedence = op2Described.prevOp?.precedence
                if opPrecedence > op2Precedence {
                    prefix = "(\(op2Described.descriptor ?? "?"))"
                } else {
                    prefix = "\(op2Described.descriptor ?? "?")"
                }
                if opPrecedence > op1Precedence {
                    suffix = "(\(op1Described.descriptor ?? "?"))"
                } else if opPrecedence < op1Precedence {
                    suffix = "\(op1Described.descriptor ?? "?")"
                } else {
                    //if top of stack, we are merging 2 operands: e.g.:
                    //(1+2+3)*4, 4/5
                    //Without this condition, this would show as:
                    //(1+2+3)*4/4/5 instead of:
                    //(1+2+3)*4/(4/5)--both stacks have same precedence, but merging them implies
                    //an implicit parenthesis, but only for operations where order matters.
                    //That's to say in prev example:
                    //(1+2+3)*4*4/5 is completely OK.
                    if !TOS {
                        suffix = "\(op1Described.descriptor ?? "?")"
                    } else {
                        if symbol == "-" || symbol == "÷" {
                            suffix = "(\(op1Described.descriptor ?? "?"))"
                        } else {
                            suffix = "\(op1Described.descriptor ?? "?")"
                        }
                    }
                }
                binaryDescription = "\(prefix)\(symbol)\(suffix)"
                return (op2Described.remainingOps, binaryDescription, op)
            case .ClearOperation(_):
                return (ops, nil, op)
            case .PiOperation(_):
                return (remainingOps, "π", op)
            }
        }
        return (ops, nil, nil)
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

    func evaluateAndReportErrors() -> String? {
        let (result, remainder) = evaluate(opStack)
        let errmsg = ""
        return errmsg
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
    
    func opStackRemoveLast() {
        opStack.removeLast()
    }
    
}