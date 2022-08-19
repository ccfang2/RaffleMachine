# Raffle Machine App
This is a simple raffle machine app that draws winners out of participants in a random way.

## Instructions
1. Upload a file containing all participants. Only excel files (.xlsx) are accepted. Format is as follows.

     Number | Name 
     ---|---
     1  | Jimmy
     2  | Tommy
     3  | Amy
     ... | ...
     
2. Upload a file containing all prizes. Only excel files (.xlsx) are accepted. Format is as follows.

     Prize    | Quantity
     ---      | ---
     Car	    | 1
     Fridge   | 1
     Bike	    | 3
     Notebook |	5

3. Click 'Action' to start. Each time a user clicks, one participant is drawn, with an assignment to a prize. Please be aware that prizes are given from bottom to top (e.g., in the example above, notebooks are given at first, and finally the car). A notification pops up when all prizes are taken.

4. If users run the app in Rstudio Window or RStudio Viewer, they can click the reload button at the top of page to reset. If users run the app in a browser (Simply click this [link](https://ccfang2.shinyapps.io/RaffleMachine/)), they just reload the webpage to reset. Each time users start a new raffle, they have to reset the app.

## Limitations
- This raffle machine is built on the rule of randomness. Each participant can at most get one prize, and each prize could not be shared. 
- It fails to consider the case when the quantity of prizes exceeds the total number of participants. However, afaik, this case is quite rare. If it happens, users have to design a different raffle rule which is beyond my discussion here.
- To avoid cheating, this raffle machine produces the same results as long as the uploaded files are unchanged. This also helps when the original raffle results are not saved. Nevertheless, if users do want different results, they can shuffle their original files before uploading or add additional participants.
- Future improvements also include the addition of buttons like 'Back', 'Reset', 'Music on', etc.

## Others
- All images in the app are copy right free.
- This app is built in [Shiny, Rstudio](https://shiny.rstudio.com).

