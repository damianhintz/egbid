egbid.ma v1.0.0.21, 23 wrzeœnia 2015
--
Aktualizacja identyfikatorów OT_BUBD_A_EGiB

# Nowe funkcje:

* Aktualizacja identyfikatorów w tabeli OT_BUBD_A_EGiB
* Wyszukiwanie tekstów poza budynkiem

# U¿ycie:

1. Pod³¹czenie zbioru tekstów reprezentuj¹cych identyfikatory budynków.
2. Wybranie ogrodzenia, aby okreœliæ zakres aktualizacji. Wszystkie teksty 
   z pliku referencyjnego znajduj¹ce siê wewn¹trz budynku traktowane s¹ jako 
   jego identyfikatory. Punkt zaczepienia tekstu powinien znajdowaæ siê w œrodku budynku.
3. Uruchomienie polecenia "Aktualizacja OT_BUBD_A_EGiB".

   Aktualizacja tabeli identyfikatorów budynków OT_BUBD_A_EGiB.
   Pod uwagê brane s¹ tylko budynki dla których atrybut x_zrodloDanychG = 'EGiB'.

   UWAGA: w przypadku pe³nej aktualizacji ca³a zawartoœæ tabeli OT_BUBD_A_EGiB jest przedtem usuwana.

# Polecenia:

a) Aktualizacja OT_BUBD_A_EGiB (przyrostowa, pe³na)
 - przyrostowa
   * zachowuje identyfikatory budynków, stare wpisy w tabeli OT_BUBD_A_EGiB pozostaj¹ nienaruszone
   * do tabeli identyfikatorów dopisywane s¹ tylko identyfikatory, które istniej¹ w pliku referencyjnym
     ale nie zosta³y jeszcze dodane do tabeli
 - pe³na
   * usuwa stare identyfikatory (oczyszczanie tabeli OT_BUBD_A_EGiB) i tworzy nowe wpisy na podstawie
     danych zawartych w pliku g³ównym oraz referencyjnym

b) Wyszukiwanie tekstów poza budynkiem
 - znalezienie tekstów dla których prawdopodobnie punkt zaczepienia tekstu jest nieprawid³owy

# Historia

Do zrobienia

* [ ] podrêcznik u¿ytkownika

2015-09-23 v1.0.0.21

* poprawka: nowy format powi¹zania danych u¿ytkownika

2013-04-16 v0.0.1.17

* pierwsza wersja aplikacji
