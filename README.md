egbid.ma v1.0.0.21, 23 wrze�nia 2015
--
Aktualizacja identyfikator�w OT_BUBD_A_EGiB

# Nowe funkcje:

* Aktualizacja identyfikator�w w tabeli OT_BUBD_A_EGiB
* Wyszukiwanie tekst�w poza budynkiem

# U�ycie:

1. Pod��czenie zbioru tekst�w reprezentuj�cych identyfikatory budynk�w.
2. Wybranie ogrodzenia, aby okre�li� zakres aktualizacji. Wszystkie teksty 
   z pliku referencyjnego znajduj�ce si� wewn�trz budynku traktowane s� jako 
   jego identyfikatory. Punkt zaczepienia tekstu powinien znajdowa� si� w �rodku budynku.
3. Uruchomienie polecenia "Aktualizacja OT_BUBD_A_EGiB".

   Aktualizacja tabeli identyfikator�w budynk�w OT_BUBD_A_EGiB.
   Pod uwag� brane s� tylko budynki dla kt�rych atrybut x_zrodloDanychG = 'EGiB'.

   UWAGA: w przypadku pe�nej aktualizacji ca�a zawarto�� tabeli OT_BUBD_A_EGiB jest przedtem usuwana.

# Polecenia:

a) Aktualizacja OT_BUBD_A_EGiB (przyrostowa, pe�na)
 - przyrostowa
   * zachowuje identyfikatory budynk�w, stare wpisy w tabeli OT_BUBD_A_EGiB pozostaj� nienaruszone
   * do tabeli identyfikator�w dopisywane s� tylko identyfikatory, kt�re istniej� w pliku referencyjnym
     ale nie zosta�y jeszcze dodane do tabeli
 - pe�na
   * usuwa stare identyfikatory (oczyszczanie tabeli OT_BUBD_A_EGiB) i tworzy nowe wpisy na podstawie
     danych zawartych w pliku g��wnym oraz referencyjnym

b) Wyszukiwanie tekst�w poza budynkiem
 - znalezienie tekst�w dla kt�rych prawdopodobnie punkt zaczepienia tekstu jest nieprawid�owy

# Historia

Do zrobienia

* [ ] podr�cznik u�ytkownika

2015-09-23 v1.0.0.21

* poprawka: nowy format powi�zania danych u�ytkownika

2013-04-16 v0.0.1.17

* pierwsza wersja aplikacji
