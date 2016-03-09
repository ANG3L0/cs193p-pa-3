# cs193p-pa3

## Objective
Make a split-view graphing calculator.

## Main tasks
1. [x] You must begin this assignment with your Assignment 2 code, not with any in-class demo code that has been posted. Learning to create new MVCs and segues requires experiencing it, not copy/pasting it or editing an existing storyboard that already has segues in it.
2. [ ] Rename the ViewController class you’ve been working on in Assignments 1 and 2 to be CalculatorViewController.
3. [ ] Add a new button to your calculator’s user-interface which, when touched, segues to a new MVC (that you will have to write) which graphs the program in the CalculatorBrain at the time the button was touched using the memory location M as the independent variable. For example, if the CalculatorBrain contains sin(M), you’d draw a sine wave. Subsequent input to the Calculator must have no effect on the graph (until the graphing button is touched again).
4. [ ] Neither of your MVCs in this assignment is allowed to have CalculatorBrain appear anywhere in its non-private API.
5. [ ] On iPad and in landscape on iPhone 6+ devices, the graph must be (or be able to be) on screen at the same time as your existing Calculator’s user-interface (i.e. in a split view). On other iPhones the graph should “push” onto the screen via a navigation controller.
6. [ ] Anytime a graph is on screen, a description of what it is being drawn should also be shown on screen somewhere sensible, e.g., if sin(M) is what is being graphed, then the string “sin(M)” should be on screen somewhere.
7. [ ] As part of your implementation, you are required write a generic x vs. y graphing UIView. In other words, the UIView that does the graphing should be designed in such a way that it is completely independent of the Calculator (and could be reused in some other completely different application that wanted to draw an x vs. y graph).
8. [ ] The graphing view must not own (i.e. store) the data it is graphing. It must use delegation to obtain the data as it needs it.
9. [ ] Your graphing calculator must be able to graph discontinuous functions properly (i.e. it must only draw lines to or from points which, for a given value of M, the program being graphed evaluates to a Double (i.e. not nil) that .isNormal or .isZero).
10. [ ] Your graphing view must be @IBDesignable and its scale must be @IBInspectable. The graphing view’s axes should appear in the storyboard at the inspected scale.
11. [ ] Your graphing view must support the following three gestures:
    a. [ ] Pinching (zooms the entire graph, including the axes, in or out on the graph)
    b. [ ] Panning (moves the entire graph, including the axes, to follow the touch around)
    c. [ ] Double-tapping (moves the origin of the graph to the point of the double tap) 

## Pain points for this assignment AKA "stuff to learn"
Here is a partial list of concepts this assignment is intended to let you gain practice with or otherwise demonstrate your knowledge of.
1. Understanding MVC boundaries
2. Creating a new subclass of UIViewController
3. Universal Application (i.e. different UIs on iPad and iPhone in the same application) Split View Controller
4. Navigation Controller
5. Segues
6. Property List
7. Subclassing UIView
8. UIViewContentMode.Redraw
9. Delegation
10. Drawing with UIBezierPath and/or Core Graphics CGFloat/CGPoint/CGSize/CGRect
11. Gestures
12. contentScaleFactor (pixels vs. points)


## Evaluation
In all of the assignments this quarter, writing quality code that builds without warnings or errors, and then testing the resulting application and iterating until it functions properly is the goal.
Here are the most common reasons assignments are marked down:
• Project does not build.
• Project does not build without warnings.
• One or more items in the Required Tasks section was not satisfied.
• Afundamentalconceptwasnotunderstood.
• Code is visually sloppy and hard to read (e.g. indentation is not consistent, etc.).
• Yoursolutionisdifficult(orimpossible)forsomeonereadingthecodeto understand due to lack of comments, poor variable/method names, poor solution structure, long methods, etc.
• UI is a mess. Things should be lined up and appropriately spaced to “look nice.”
• Public and private API is not properly delineated.
Often students ask “how much commenting of my code do I need to do?” The answer is that your code must be easily and completely understandable by anyone reading it. You can assume that the reader knows the SDK, but should not assume that they already know the (or a) solution to the problem.


## Extra Credit
1. [ ] Figure out how to use Instruments to analyze the performance of panning and pinching in your graphing view. What makes dragging the graph around so sluggish? Explain in comments in your code what you found and what you might do about it.
2. [ ] Use the information you found above to improve panning performance. Do NOT turn your code into a mess to do this. Your solution should be simple and elegant. There is a strong temptation when optimizing to sacrifice readability or to violate MVC boundaries, but you are NOT allowed to do that for this Extra Credit!
3. [ ] Preserve origin and scale between launchings of the application. Where should this be done to best respect MVC, do you think?
4. [ ] Upon rotation (or any bounds change), maintain the origin of your graph with respect to the center of your graphing view rather than with respect to the upper left corner.
5. [ ] Add a popover to your new MVC that reports the minimum and maximum y-value (and other stats if you wish) in the region of the graph currently being shown. This will require you to create yet another new MVC and segue to it using a popover segue. It will also require some new public API in your generic graph view to report stats about the region of the graph it has drawn.
6. [ ] Have your Calculator react to size class changes by laying out the user-interface differently in different size class environments (i.e. buttons in a different grid layout or even add more operations in one arrangement or the other). Doing this must not break anything else!


##Demos and so forth
TBD

##What could be better?
TBD
