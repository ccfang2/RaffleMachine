rm(list = ls())
library(shiny)
library(openxlsx)

## Only run examples in interactive R sessions
ui <- fluidPage(
  # Title
  titlePanel(p(span("Raffle", style="color:blue"), 
               span("Machine", style="color:red"),
               span("App", style="color:green"))),
  
  fluidRow(
    column(4,
      p("This is a simple raffle machine app that draws winners out of participants! Enjoy!"),
      # Upload a file of participants
      fileInput("file1", 
                label = p("Select file (.xlsx) of participants",
                          p(a("Click here for format", href = "https://github.com/ccfang2/RaffleMachine"))),
                accept = ".xlsx"),
      # Upload a file of available prizes
      fileInput("file2", 
                label = p("Select file (.xlsx) of available prizes",
                          p(a("Click here for format", href = "https://github.com/ccfang2/RaffleMachine"))),
                accept = ".xlsx"),
      # Buttons to start and restart
      p("Click", span("Action", style="color:blue"), "to start. Each time you click, one 
      participant is drawn. Prizes are taken from bottom to top. You are notified 
        when all prizes are taken. Click", 
        span(img(src = "reset.png", height=20, width=20)), "on the top of page to reset."),
      actionButton("draw",
                   label = div("Action",style="color:blue")),
      br(),
      br(),
      br(),
      img(src = "rstudio.png", height = 70, width = 200),
      br(),
      p("This App is built by", 
      a("Shiny, RStudio", href = "http://shiny.rstudio.com"))
    ),
    column(8,
      img(src = "raffle1.jpg", height = 110, width = 180),
      img(src = "raffle2.jpg", height = 110, width = 180),
      img(src = "raffle3.jpg", height = 110, width = 180),
      br(),
      br(),
      h1(textOutput("winner"),align="center",style="color:maroon"),
      br(),
      br(),
      h6(tableOutput("winners")),
    )
  )
)

server <- function(input, output, session) {
  # Inititating reactive values, these will `reset` for each session
  values <- reactiveValues()
  values$count <- 0

  # Define a reactive function to read in participant list
  data1 <- reactive({
    ext <- tools::file_ext(input$file1$datapath)
    req(input$file1)
    validate(need(ext == "xlsx", "Please upload an xlsx file"))
    return(read.xlsx(input$file1$datapath, TRUE))
  })
  
  # Define a reactive function to read in prizes list
  data2 <- reactive({
    ext <- tools::file_ext(input$file2$datapath)
    req(input$file2)
    validate(need(ext == "xlsx", "Please upload an xlsx file"))
    return(read.xlsx(input$file2$datapath, TRUE))
  })

  # Reactive expression will only be executed when the button is clicked
  winner_fct <- eventReactive(input$draw,{
    ptcpt <- data1()
    prize <- data2()
    set.seed(111)
    ptcpt<- ptcpt[sample(nrow(ptcpt)),]
    prize_vec <- rev(rep(unlist(prize[,1]),unlist(prize[,2])))
    if(values$count < length(prize_vec)){
       values$count <- values$count + 1
       winner <- c(ptcpt[values$count,1],ptcpt[values$count,2],prize_vec[values$count])
       winners <- cbind(rev(ptcpt[1:values$count,1]),rev(ptcpt[1:values$count,2]),rev(prize_vec[1:values$count]))
       colnames(winners) <- c("Number","Name","Prize")
       return(list(winner=winner, winners=winners))
      }
    else{
      winners <- cbind(rev(ptcpt[1:values$count,1]),rev(ptcpt[1:values$count,2]),rev(prize_vec[1:values$count]))
      colnames(winners) <- c("Number","Name","Prize")
      return(list(winner= "All Prizes are Taken, Sorry!", 
                  winners=winners))
    }
  })
  
  output$winner <- renderText({
    if (winner_fct()$winner[1]=="All Prizes are Taken, Sorry!") {
      paste(winner_fct()$winner[1])
    }
    else {
      paste(winner_fct()$winner[2], " (#",winner_fct()$winner[1]," )",
            " wins ", winner_fct()$winner[3], ", Congratulations!", sep="")
      }
  }) 
  
  output$winners <- renderTable({
    winner_fct()$winners
    },
    striped = TRUE,
    hover = TRUE,
    bordered = TRUE,
    width = "550px",
    caption = "List of Winners",
    caption.placement = getOption("xtable.caption.placement", "top"))
}

shinyApp(ui, server)