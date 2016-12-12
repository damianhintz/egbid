egbid.ma v1.1-beta, 12 grudnia 2016
---
Aktualizacja identyfikatorów OT_BUBD_A_EGiB

# Nowe funkcje:

* Aktualizacja identyfikatorów w tabeli OT_BUBD_A_EGiB
* Wyszukiwanie tekstów poza budynkiem

# Użycie:

1. Podłączenie zbioru tekstów reprezentujących identyfikatory budynków.
2. Wybranie ogrodzenia, aby określić zakres aktualizacji. Wszystkie teksty 
   z pliku referencyjnego znajdujące się wewnątrz budynku traktowane są jako 
   jego identyfikatory. Punkt zaczepienia tekstu powinien znajdować się w środku budynku.
3. Uruchomienie polecenia "Aktualizacja OT_BUBD_A_EGiB".

   Aktualizacja tabeli identyfikatorów budynków OT_BUBD_A_EGiB.
   Pod uwagę brane są tylko budynki dla których atrybut x_zrodloDanychG = 'EGiB'.

   UWAGA: w przypadku pełnej aktualizacji cała zawartość tabeli OT_BUBD_A_EGiB jest przedtem usuwana.

# Polecenia:

a) Aktualizacja OT_BUBD_A_EGiB (przyrostowa, pełna)
 - przyrostowa
   * zachowuje identyfikatory budynków, stare wpisy w tabeli OT_BUBD_A_EGiB pozostają nienaruszone
   * do tabeli identyfikatorów dopisywane są tylko identyfikatory, które istnieją w pliku referencyjnym
     ale nie zostały jeszcze dodane do tabeli
 - pełna
   * usuwa stare identyfikatory (oczyszczanie tabeli OT_BUBD_A_EGiB) i tworzy nowe wpisy na podstawie
     danych zawartych w pliku głównym oraz referencyjnym

b) Wyszukiwanie tekstów poza budynkiem
 - znalezienie tekstów dla których prawdopodobnie punkt zaczepienia tekstu jest nieprawidłowy

# Historia

Do zrobienia

* [ ] podręcznik użytkownika

2016-12-12 v1.1-beta

* aktualizacja: dostosowanie do nowego schematu bazy danych (poz = 1, EGiB -> EGiB_lokalnyId)

2015-09-23 v1.0.0.21

* poprawka: nowy format powiązania danych użytkownika

2013-04-16 v0.0.1.17

* pierwsza wersja aplikacji
