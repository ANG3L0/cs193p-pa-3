# cs193p-pa2

## Objective
You will start this assignment by enhancing your Assignment 1 Calculator to include the changes made in lecture (i.e. CalculatorBrain, etc.). This is the last assignment for which you will have to replicate code from lecture by typing it in.
Now that we’ve added an MVC Model to our Calculator, we’re going to push its capabilities a bit further. You will enhance your Calculator to allow the input of a “variable” into the Calculator’s stack. In addition, you’ll provide a way for the user to better see what has been entered so far.

## Main tasks
1. [ ] All of the changes to the Calculator made in lecture must be applied to your Assignment 1. Get this fully functioning before proceeding to the rest of the Required Tasks. And, as last week, type the changes in, do not copy/paste from anywhere.
2. [ ] Do not change any non-private API in CalculatorBrain and continue to use an enum as its primary internal data structure.
3. [ ] Your UI should always be in sync with your Model (the CalculatorBrain).
4. [ ] The extra credit item from last week to turn displayValue into a Double? (i.e, an Optional rather than a Double) is now required. displayValue should return nil whenever the contents of the display cannot be interpreted as a Double. Setting displayValue to nil should clear the display.
5. [ ] Add the capability to your CalculatorBrain to allow the pushing of variables onto its internal stack. Do so by implementing the following API in your CalculatorBrain ...
      `func pushOperand(symbol: String) -> Double?`
      `var variableValues: Dictionary<String,Double>`
These must do exactly what you would imagine they would: the first pushes a “variable” onto your brain’s internal stack (e.g. pushOperand(“x”) would push a variable named x) and the second lets users of the CalculatorBrain set the value for any variable they wish (e.g. brain.variableValues[“x”] = 35.0). pushOperand should return the result of evaluate() after having pushed the variable (just like the other pushOperand does).
6. [ ] The evaluate() function should use a variable’s value (from the variableValues dictionary) whenever a variable is encountered or return nil if it encounters a variable with no corresponding value.
7. [ ] Implement a new read-only (get only, no set) var to CalculatorBrain to describe the contents of the brain as a String ...
      `var description: String`
  * [ ] Unary operations should be shown using “function” notation. For example, the
input `10 cos` would display in the description as `cos(10)`.
  * [ ] Binary operations should be shown using “infix” notation. For example, the input
3 ↲ 5 - should display as 3-5. Be sure to get the order correct!
  * [ ]  All other stack contents (e.g. operands, variables, constants like π, etc.) should be displayed unadorned. For example, 23.5 ⇒ 23.5, π ⇒ π (not 3.1415!), the variable x ⇒ x (not its value!), etc.
  * [ ]  Any combination of stack elements should be properly displayed. Examples:
10 √ 3 +⇒√(10)+3
 3 ↲ 5 + √ ⇒ √(3+5)
3 ↲ 5 ↲ 4 + + ⇒3+(5+4)or (for Extra Credit)3+5+4 3 ↲ 5 √ + √ 6 ÷ ⇒ √(3+ √(5))÷6
  * [ ] If there are any missing operands, substitute a ? for them, e.g. 3 ↲ + ⇒ ?+3.
  * [ ] If there are multiple complete expressions on the stack, separate them by commas: for example, 3 ↲ 5 + √ π cos ⇒ √(3+5),cos(π). The expressions should be in historical order with the oldest at the beginning of the string and the most recently pushed/performed at the end.
  * [ ] Your description must properly convey the mathematical expression. For example, 3 ↲ 5 ↲ 4 + * must not output 3*5+4—it must be 3*(5+4). In other words, you will need to sometimes add parentheses around binary operations. Having said that, try to minimize parentheses as much as you can (as long as the output is mathematically correct). See Extra Credit if you want to really do this well.
8. [ ] Modify the UILabel you added last week to show your CalculatorBrain’s description instead. It should put an = on the end of it (and be positioned strategically so that the display looks like it’s the result of that =). This = was Extra Credit last week, but it is required this week.
9. [ ] Add two new buttons to your Calculator’s keypad: →M and M. These 2 buttons will set and get (respectively) a variable in the CalculatorBrain called M.
  * [ ] →M sets the value of the variable M in the brain to the current value of the display (if any)
  * [ ] →M should not perform an automatic ↲ (though it should reset “user is in the middle of typing a number”)
  * [ ] Touching M should push an M variable (not the value of M) onto the CalculatorBrain
  * [ ] Touching either button should show the evaluation of the brain (i.e. the result of
evaluate()) in the display
  * [ ] →M and M are Controller mechanics, not Model mechanics (though they both use
the Model mechanic of variables).
  * [ ] This is not a very great “memory” button on our Calculator, but it’s good for testing whether our variable function implemented above is working properly. Examples ...
7 M + √ ⇒ description is √(7+M), display is blank because M is not set
9 →M ⇒ display now shows 4 (the square root of 16), description is still √(7+M) 14 + ⇒ display now shows 18, description is now √(7+M)+14
10. [ ] Make sure your C button from Assignment 1 works properly in this assignment.
11. [ ] When you touch the C button, the M variable should be removed from the variableValues Dictionary in the CalculatorBrain (not set to zero or any other value). This will allow you to test the case of an “unset” variable (because it will make evaluate() return nil and thus your Calculator’s display will be empty if M is ever used without a →M).
12. [ ] Your UI should look good on any size iPhone in both portrait and landscape (don’t worry about iPad until next week). This means setting up Autolayout properly, nothing more. 

## Extra Credit

## Evaluation

#Demos and so forth
TBD

##What could be better?
TBD
