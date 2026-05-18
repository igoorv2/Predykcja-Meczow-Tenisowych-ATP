library(shiny)
library(shiny)
library(caret)
library(gbm)

load("model_atp.RData")

ui <- fluidPage(
  
  tags$head(
    tags$style(HTML("
      body { 
        background-color: #f5f5f5; 
        font-family: Arial, sans-serif;
      }
      .title-panel {
        background-color: #1F4E79;
        color: white;
        padding: 20px;
        margin-bottom: 20px;
        border-radius: 8px;
        text-align: center;
      }
      .sidebar { 
        background-color: white; 
        padding: 20px; 
        border-radius: 8px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
      }
      .main-panel {
        background-color: white;
        padding: 20px;
        border-radius: 8px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
      }
      .btn-predict {
        background-color: #1F4E79;
        color: white;
        border: none;
        padding: 12px;
        font-size: 16px;
        border-radius: 6px;
        width: 100%;
        cursor: pointer;
      }
      .btn-predict:hover {
        background-color: #2E75B6;
        color: white;
      }
      .info-box {
        background-color: #EBF3FB;
        padding: 15px;
        border-radius: 8px;
        border-left: 5px solid #1F4E79;
        margin-top: 15px;
      }
      .computed-box {
        background-color: #f8f9fa;
        padding: 10px;
        border-radius: 6px;
        border: 1px solid #dee2e6;
        margin-top: 10px;
        font-size: 13px;
        color: #555;
      }
      hr { border-color: #dee2e6; }
    "))
  ),
  
  div(class = "title-panel",
      h2("🎾 Predykcja wyniku meczu ATP"),
      p("Model Gradient Boosting | Dokładność: 65.2% | Dane: ATP 2020-2024")
  ),
  
  sidebarLayout(
    
    sidebarPanel(
      class = "sidebar",
      
      h4("📋 Parametry turnieju", style = "color: #1F4E79;"),
      
      selectInput("surface", "Nawierzchnia kortu:",
                  choices = c("Clay" = "Clay",
                              "Hard" = "Hard", 
                              "Grass" = "Grass")),
      
      selectInput("tourney_level", "Poziom turnieju:",
                  choices = c("Grand Slam (G)" = "G",
                              "Masters 1000 (M)" = "M",
                              "ATP 500 (A)" = "A",
                              "ATP 250 (D)" = "D",
                              "ATP Finals (F)" = "F")),
      
      selectInput("draw_size", "Liczba zawodników w turnieju:",
                  choices = c(28, 32, 48, 56, 64, 96, 128),
                  selected = 64),
      
      selectInput("round", "Runda turnieju:",
                  choices = c("1. runda (R128)" = "R128",
                              "1. runda (R64)" = "R64",
                              "2. runda (R32)" = "R32",
                              "3. runda (R16)" = "R16",
                              "Ćwierćfinał (QF)" = "QF",
                              "Półfinał (SF)" = "SF",
                              "Finał (F)" = "F")),
      
      selectInput("best_of", "Format meczu:",
                  choices = c("Best of 3" = 3,
                              "Best of 5" = 5),
                  selected = 3),
      
      hr(),
      
      h4("🔵 Zawodnik A", style = "color: #1F4E79;"),
      
      numericInput("rank_a", "Ranking ATP:",
                   value = 5, min = 1, max = 2000, step = 1),
      
      numericInput("points_a", "Punkty rankingowe:",
                   value = 8000, min = 0, max = 20000, step = 100),
      
      numericInput("age_a", "Wiek (lata):",
                   value = 24, min = 15, max = 45, step = 0.1),
      
      numericInput("height_a", "Wzrost (cm):",
                   value = 185, min = 160, max = 220, step = 1),
      
      sliderInput("form_a", "Forma — % wygranych w ost. 5 meczach:",
                  min = 0, max = 1, value = 0.6, step = 0.2),
      
      hr(),
      
      h4("🔴 Zawodnik B", style = "color: #c0392b;"),
      
      numericInput("rank_b", "Ranking ATP:",
                   value = 42, min = 1, max = 2000, step = 1),
      
      numericInput("points_b", "Punkty rankingowe:",
                   value = 1800, min = 0, max = 20000, step = 100),
      
      numericInput("age_b", "Wiek (lata):",
                   value = 29, min = 15, max = 45, step = 0.1),
      
      numericInput("height_b", "Wzrost (cm):",
                   value = 188, min = 160, max = 220, step = 1),
      
      sliderInput("form_b", "Forma - % wygranych w ost. 5 meczach:",
                  min = 0, max = 1, value = 0.4, step = 0.2),
      
      hr(),
      
      h5("⚙️ Zmienne obliczone automatycznie:", 
         style = "color: #555; font-size: 13px;"),
      
      div(class = "computed-box",
          uiOutput("computed_vars")
      ),
      
      br(),
      
      actionButton("predict_btn", "🎾 Przewiduj wynik!",
                   class = "btn-predict")
    ),
    
    mainPanel(
      class = "main-panel",
      
      uiOutput("placeholder"),
      
      uiOutput("wynik_box"),
      
      uiOutput("prob_section"),
      
      uiOutput("params_summary"),
      
      div(class = "info-box",
          h5("ℹ️ Informacje o modelu:"),
          p("📊 Model: Gradient Boosting (GBM)"),
          p("🎯 Dokładność na zbiorze testowym: 65.2%"),
          p("📁 Dane treningowe: mecze ATP 2020–2024 (13 174 obserwacji)"),
          p("⚠️ Uwaga: model wykorzystuje wyłącznie dane przedmeczowe. 
           Czynniki losowe (kontuzje, pogoda, presja) nie są uwzględnione.")
      )
    )
  )
)

server <- function(input, output) {
  
  obliczone <- reactive({
    list(
      rank_diff = input$rank_a - input$rank_b,
      rank_log_diff = log(input$rank_a) - log(input$rank_b),
      points_diff = input$points_a - input$points_b,
      age_diff = input$age_a - input$age_b,
      height_diff = input$height_a - input$height_b,
      form_diff = input$form_a - input$form_b
    )
  })
  
  output$computed_vars <- renderUI({
    o <- obliczone()
    HTML(paste0(
      "rank_diff = ", o$rank_diff, "<br>",
      "rank_log_diff = ", round(o$rank_log_diff, 3), "<br>",
      "points_diff = ", o$points_diff, "<br>",
      "age_diff = ", round(o$age_diff, 1), "<br>",
      "height_diff = ", o$height_diff, "<br>",
      "form_diff = ", round(o$form_diff, 1)
    ))
  })
  
  output$placeholder <- renderUI({
    if (input$predict_btn == 0) {
      div(
        style = "text-align: center; padding: 60px; color: #aaa;",
        h3("👈 Uzupełnij parametry i kliknij 'Przewiduj wynik!'")
      )
    }
  })
  
  predykcja <- eventReactive(input$predict_btn, {
    
    o <- obliczone()
    
    nowy_mecz <- data.frame(
      surface = factor(input$surface,
                             levels = levels(dane_model$surface)),
      tourney_level = factor(input$tourney_level,
                             levels = levels(dane_model$tourney_level)),
      draw_size = as.numeric(input$draw_size),
      round = factor(input$round,
                             levels = levels(dane_model$round)),
      best_of = as.numeric(input$best_of),
      rank_diff = o$rank_diff,
      rank_log_diff = o$rank_log_diff,
      points_diff = o$points_diff,
      age_diff = o$age_diff,
      height_diff = o$height_diff,
      form_diff = o$form_diff
    )
    
    klasa <- predict(model_boost, newdata = nowy_mecz, type = "raw")
    prob  <- predict(model_boost, newdata = nowy_mecz, type = "prob")
    
    list(klasa = as.character(klasa), prob = prob)
  })
  
  output$wynik_box <- renderUI({
    req(input$predict_btn > 0)
    req(predykcja())
    
    wynik <- predykcja()$klasa
    prob <- predykcja()$prob
    
    if (wynik == "player1_win") {
      prob_val <- round(prob$player1_win * 100, 1)
      div(
        style = "background-color: #d4edda; padding: 25px; 
                 border-radius: 10px; border-left: 6px solid #28a745;
                 margin-bottom: 20px;",
        h2("✅ Wygrywa Zawodnik A!", style = "color: #28a745; margin:0;"),
        h4(paste0("Prawdopodobieństwo: ", prob_val, "%"),
           style = "color: #28a745; margin-top: 8px;")
      )
    } else {
      prob_val <- round(prob$player2_win * 100, 1)
      div(
        style = "background-color: #f8d7da; padding: 25px;
                 border-radius: 10px; border-left: 6px solid #dc3545;
                 margin-bottom: 20px;",
        h2("✅ Wygrywa Zawodnik B!", style = "color: #dc3545; margin:0;"),
        h4(paste0("Prawdopodobieństwo: ", prob_val, "%"),
           style = "color: #dc3545; margin-top: 8px;")
      )
    }
  })
  
  output$prob_section <- renderUI({
    req(input$predict_btn > 0)
    req(predykcja())
    
    prob <- predykcja()$prob
    p1 <- round(prob$player1_win * 100, 1)
    p2 <- round(prob$player2_win * 100, 1)
    
    div(
      h4("📊 Prawdopodobieństwa zwycięstwa:"),
      
      div(style = "margin-bottom: 10px;",
          p(strong("Zawodnik A:"), paste0(" ", p1, "%"),
            style = "margin-bottom: 4px;"),
          div(style = paste0(
            "background-color: #28a745; height: 24px; width: ", 
            p1, "%; border-radius: 4px;"))
      ),
      
      div(style = "margin-bottom: 20px;",
          p(strong("Zawodnik B:"), paste0(" ", p2, "%"),
            style = "margin-bottom: 4px;"),
          div(style = paste0(
            "background-color: #dc3545; height: 24px; width: ", 
            p2, "%; border-radius: 4px;"))
      )
    )
  })
  
  output$params_summary <- renderUI({
    req(input$predict_btn > 0)
    
    o <- obliczone()
    
    div(
      h4("📋 Parametry wprowadzone do modelu:"),
      tableOutput("params_table"),
      br()
    )
  })
  
  output$params_table <- renderTable({
    req(input$predict_btn > 0)
    o <- obliczone()
    
    data.frame(
      Zmienna = c("surface", "tourney_level", "draw_size", 
                  "round", "best_of", "rank_diff",
                  "rank_log_diff", "points_diff", 
                  "age_diff", "height_diff", "form_diff"),
      Wartość = c(input$surface, input$tourney_level,
                  input$draw_size, input$round, input$best_of,
                  o$rank_diff, round(o$rank_log_diff, 3),
                  o$points_diff, round(o$age_diff, 1),
                  o$height_diff, round(o$form_diff, 1)),
      Źródło = c("wybór", "wybór", "wybór", "wybór", "wybór",
                 "auto (A-B)", "auto log(A)-log(B)", 
                 "auto (A-B)", "auto (A-B)", 
                 "auto (A-B)", "auto (A-B)")
    )
  })
}

shinyApp(ui = ui, server = server)
