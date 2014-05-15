CREATE OR REPLACE PROCEDURE DODAJ_PRACOWNIKA (
  osoba_imie IN VARCHAR2,
  osoba_nazwisko IN VARCHAR2,
  osoba_wiek IN NUMBER,
  osoba_stan_cywilny IN VARCHAR2,
  osoba_telefon IN VARCHAR2,
  osoba_pesel IN CHAR,
  adres_miasto IN VARCHAR2,
  adres_ulica IN VARCHAR2,
  adres_nr IN VARCHAR2,
  stanowisko_nazwa IN VARCHAR2,
  stanowisko_opis IN VARCHAR2,
  pracownik_staz IN NUMBER,
  pracownik_pensja_br IN NUMBER
  ) AUTHID DEFINER IS
  adres_id NUMBER := NULL;
  stanowisko_id NUMBER := NULL;
  osoba_id NUMBER;
  pracownik_id NUMBER;
  BEGIN
   -- DELETE - Useful for testing
   SELECT p.id_stanowiska INTO stanowisko_id FROM PRACOWNICY p JOIN OSOBY o ON (o.id_osoby = p.id_osoby) WHERE o.pesel = osoba_pesel;
   DELETE FROM PRACOWNICY p WHERE p.id_osoby = (SELECT o.id_osoby FROM OSOBY o WHERE o.pesel = osoba_pesel);
   IF stanowisko_id IS NOT NULL THEN DELETE FROM STANOWISKA s WHERE s.id_stanowiska = stanowisko_id; END IF;
   SELECT o.id_adresu INTO adres_id FROM OSOBY o WHERE o.pesel = osoba_pesel;
   DELETE FROM OSOBY o WHERE o.pesel = osoba_pesel;
   DELETE FROM ADRESY a WHERE a.id_adresu = adres_id;

   SELECT MAX(id_adresu) INTO adres_id FROM ADRESY;
   adres_id := adres_id + 1;
   INSERT INTO ADRESY (id_adresu, miasto, ulica, nr) VALUES (adres_id, adres_miasto, adres_ulica, adres_nr);

   SELECT MAX(id_stanowiska) INTO stanowisko_id FROM STANOWISKA;
   stanowisko_id := stanowisko_id + 1;
   INSERT INTO STANOWISKA (id_stanowiska, nazwa, opis) VALUES (stanowisko_id, stanowisko_nazwa, stanowisko_opis);

   SELECT MAX(id_osoby) INTO osoba_id FROM OSOBY;
   osoba_id := osoba_id + 1;
   INSERT INTO OSOBY (id_osoby, imie, nazwisko, wiek, stan_cywilny, telefon, pesel, id_adresu)
   VALUES (osoba_id, osoba_imie, osoba_nazwisko, osoba_wiek, osoba_stan_cywilny, osoba_telefon, osoba_pesel, adres_id);

   SELECT MAX(id_pracownika) INTO pracownik_id FROM PRACOWNICY;
   pracownik_id := pracownik_id + 1;
   INSERT INTO PRACOWNICY (id_pracownika, id_osoby, id_stanowiska, staz, pensja_br)
   VALUES (pracownik_id, osoba_id, stanowisko_id, pracownik_staz, pracownik_pensja_br);
  END;
/

EXEC DODAJ_PRACOWNIKA('PracownikImie', 'PracownikNazwisko', 20, 'wolny', '+48786512459', '77040368155', 'Miasto', 'Ulica', '1/1', 'Stanowisko', 'StanowiskoOpis', 2, 3000);

-- Pesel is unique
SELECT * FROM OSOBY o
JOIN ADRESY a ON (a.id_adresu = o.id_adresu)
JOIN PRACOWNICY p ON (p.id_osoby = o.id_osoby)
JOIN STANOWISKA s ON (s.id_stanowiska = p.id_stanowiska)
WHERE o.pesel = '77040368155';

-- CREATE OR REPLACE PROCEDURE MODYFIKUJ_KLIENTA
-- CREATE OR REPLACE PROCEDURE DODAJ_ZAMOWIENIE

-- CREATE OR REPLACE FUNCTION GET_NAZWISKO_NAJWIECEJ_ZLECEN