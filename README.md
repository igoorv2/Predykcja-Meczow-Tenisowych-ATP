# 🎾 Predykcja meczów ATP — Projekt uczenia maszynowego

> Przewidywanie zwycięzcy meczu tenisowego na podstawie danych przedmeczowych.  
> 7 modeli klasyfikacyjnych | Najlepsza dokładność: **65,2%** (Gradient Boosting)

---

## 📋 Opis projektu

Celem projektu była budowa i porównanie modeli klasyfikacyjnych służących do przewidywania zwycięzcy meczu tenisowego w turniejach ATP. Kluczowym założeniem było wykorzystanie **wyłącznie danych dostępnych przed meczem** - co odróżnia projekt od wielu podobnych analiz korzystających z danych pomeczowych (asy, błędy, statystyki serwisu).

---
## 📊 Dane

| Parametr | Wartość |
|----------|---------|
| Źródło | [Tennis ATP — GitHub](https://github.com/JeffSackmann/tennis_atp) |
| Sezony | 2020–2024 |
| Liczba obserwacji | 13 174 meczów |
| Liczba zmiennych (oryginalne) | 49 |
| Liczba zmiennych (po selekcji) | 12 |
| Zmienna wynikowa | Zwycięzca meczu (binarna) |

---

## ⚙️ Inżynieria cech

Kluczowe decyzje metodologiczne:

- **Symetryzacja danych** — dla każdego meczu utworzono dwie obserwacje (zwycięzca jako zawodnik A i B), eliminując stronniczość wynikającą z kolejności zapisu
- **rank_log_diff** — logarytmiczna różnica rankingów, uzasadniona nieliniowym charakterem rankingu ATP
- **form_diff** — różnica formy obliczona przez sliding window z lagiem (zapobieganie data leakage)
- **Wykluczenie zmiennych pomeczowych** — statystyki setów, gemów, asów itp. celowo pominięte

| Zmienna | Opis | Typ |
|---------|------|-----|
| surface | Nawierzchnia kortu | kategoryczna |
| tourney_level | Poziom turnieju ATP | kategoryczna |
| draw_size | Liczba zawodników w turnieju | numeryczna |
| round | Runda turnieju | kategoryczna |
| best_of | Format meczu (3 lub 5 setów) | numeryczna |
| rank_diff | Różnica rankingów (A − B) | numeryczna |
| rank_log_diff | Logarytmiczna różnica rankingów | numeryczna |
| points_diff | Różnica punktów rankingowych | numeryczna |
| age_diff | Różnica wieku zawodników | numeryczna |
| height_diff | Różnica wzrostu zawodników | numeryczna |
| form_diff | Różnica formy (ostatnie 5 meczów) | numeryczna |
| result | Zmienna wynikowa (1 = zawodnik A wygrał) | binarna |

---

## 🤖 Modele i wyniki

<img width="1021" height="366" alt="image" src="https://github.com/user-attachments/assets/6f56ddd3-6e51-4d03-b433-8d21ba956bf5" />

> Wszystkie modele osiągnęły wyniki powyżej poziomu losowego (50%).  
> Literatura wskazuje na pułap ~70% dla tego typu zadania ze względu na losowość sportu.

---

## 📈 Kluczowe wnioski

- **Różnica rankingów** (w postaci logarytmicznej) jest najsilniejszym predyktorem wyniku meczu
- Skuteczność predykcji rośnie wraz ze wzrostem różnicy rankingów — model najgorzej radzi sobie z meczami wyrównanymi
- Modele ensemble (Boosting) nieznacznie przewyższają pozostałe podejścia
- Kalibracja modelu Boosting wykazuje dobrą zgodność predykowanych prawdopodobieństw z rzeczywistymi częstościami

---

## 🎮 Aplikacja interaktywna

Projekt zawiera interaktywną aplikację **R Shiny** umożliwiającą:
- Wprowadzenie parametrów meczu (nawierzchnia, runda, poziom turnieju)
- Podanie danych zawodników (ranking, punkty, wiek, wzrost, forma)
- Automatyczne obliczenie zmiennych różnicowych
- Predykcję wyniku wraz z prawdopodobieństwem

---

## 🛠️ Narzędzia

| Narzędzie | Zastosowanie |
|-----------|-------------|
| R + Quarto | Główne środowisko analizy |
| caret | Budowa i tuning modeli ML |
| ggplot2 | Wizualizacje |
| tidyverse | Przetwarzanie danych |
| shiny | Interaktywna aplikacja |
| gt / pheatmap | Tabele i macierze pomyłek |

---
*Projekt wykonany w celach edukacyjnych. Wyniki nie stanowią rekomendacji bukmacherskich.*

