# Predykcja-Meczow-Tenisowych-ATP

# 🎾 ATP Match Prediction – Machine Learning Project

Projekt analizy danych i uczenia maszynowego dotyczący predykcji wyników meczów tenisowych ATP na podstawie danych historycznych z sezonów 2020–2024.

## 📌 Cel projektu

Celem projektu było:
- przygotowanie i eksploracja danych tenisowych ATP,
- stworzenie modeli klasyfikacyjnych przewidujących zwycięzcę meczu,
- porównanie skuteczności różnych algorytmów ML,
- wdrożenie najlepszego modelu w aplikacji Shiny.

---

## 📂 Dataset

Źródło danych:
- ATP Matches Dataset by Jeff Sackmann

Analizowane pliki:
- atp_matches_2020.csv
- atp_matches_2021.csv
- atp_matches_2022.csv
- atp_matches_2023.csv
- atp_matches_2024.csv

Dane zostały połączone w jeden zbiór i poddane preprocessingowi.

---

## ⚙️ Wykorzystane technologie

- R
- caret
- tidyverse
- ggplot2
- rpart
- randomForest
- gbm
- e1071
- shiny

---

## 🧠 Zastosowane modele klasyfikacyjne

W projekcie porównano:

- Decision Tree
- Random Forest
- Gradient Boosting
- Logistic Regression
- kNN
- Naive Bayes
- SVM

---

## 📊 Wyniki modeli

<img width="1001" height="357" alt="image" src="https://github.com/user-attachments/assets/6b5815af-3716-4ed9-8196-f3abfbf7e27d" />

Najlepszy wynik osiągnął model Gradient Boosting.

---

## 📈 Zakres analizy

Projekt obejmuje:
- preprocessing danych,
- analizę korelacji,
- eksploracyjną analizę danych (EDA),
- tuning hiperparametrów,
- walidację modeli,
- analizę macierzy pomyłek,
- ocenę modeli przy użyciu Accuracy oraz ROC.

---

## 🚀 Aplikacja Shiny

Projekt zawiera interaktywną aplikację Shiny umożliwiającą:
- wprowadzanie parametrów zawodników,
- generowanie predykcji wyniku meczu,
- analizę prawdopodobieństwa zwycięstwa.

Uruchomienie aplikacji:

```r
shiny::runApp("app.R")
