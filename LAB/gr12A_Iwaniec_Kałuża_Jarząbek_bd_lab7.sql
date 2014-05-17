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
  record_exists varchar2(1) := 'F';
  BEGIN
   -- DELETE - for testing
   BEGIN
   SELECT 'T' INTO record_exists FROM PRACOWNICY p WHERE p.id_osoby = (SELECT o.id_osoby FROM OSOBY o WHERE o.pesel = osoba_pesel);
   EXCEPTION
    WHEN no_data_found THEN NULL;
   END;

   IF record_exists = 'T' THEN
   SELECT p.id_stanowiska INTO stanowisko_id FROM PRACOWNICY p JOIN OSOBY o ON (o.id_osoby = p.id_osoby) WHERE o.pesel = osoba_pesel;
   DELETE FROM PRACOWNICY p WHERE p.id_osoby = (SELECT o.id_osoby FROM OSOBY o WHERE o.pesel = osoba_pesel);
   IF stanowisko_id IS NOT NULL THEN DELETE FROM STANOWISKA s WHERE s.id_stanowiska = stanowisko_id; END IF;
   SELECT o.id_adresu INTO adres_id FROM OSOBY o WHERE o.pesel = osoba_pesel;
   DELETE FROM OSOBY o WHERE o.pesel = osoba_pesel;
   DELETE FROM ADRESY a WHERE a.id_adresu = adres_id;
   END IF;
   -- remove this part for production!


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

CREATE OR REPLACE PROCEDURE MODYFIKUJ_KLIENTA (
  klient_id IN NUMBER,
  klient_znizka IN NUMBER,
  osoba_imie IN VARCHAR2,
  osoba_nazwisko IN VARCHAR2,
  osoba_wiek IN NUMBER,
  osoba_stan_cywilny IN VARCHAR2,
  osoba_telefon IN VARCHAR2,
  osoba_pesel IN CHAR,
  adres_miasto IN VARCHAR2,
  adres_ulica IN VARCHAR2,
  adres_nr IN VARCHAR2
  ) AUTHID DEFINER IS
  adres_id NUMBER := NULL;
  osoba_id NUMBER;
  BEGIN
   SELECT id_osoby INTO osoba_id FROM KLIENCI WHERE id_klienta = klient_id;
   SELECT id_adresu INTO adres_id FROM OSOBY WHERE id_osoby = osoba_id;

   IF klient_znizka IS NOT NULL THEN
    UPDATE KLIENCI SET znizka = klient_znizka WHERE id_klienta = klient_id;
   END IF;
   IF osoba_imie IS NOT NULL THEN
    UPDATE OSOBY o SET imie = osoba_imie WHERE id_osoby = osoba_id;
   END IF;
   IF osoba_nazwisko IS NOT NULL THEN
    UPDATE OSOBY o SET nazwisko = osoba_nazwisko WHERE id_osoby = osoba_id;
   END IF;
   IF osoba_wiek IS NOT NULL THEN
    UPDATE OSOBY o SET wiek = osoba_wiek WHERE id_osoby = osoba_id;
   END IF;
   IF osoba_stan_cywilny IS NOT NULL THEN
    UPDATE OSOBY o SET stan_cywilny = osoba_stan_cywilny WHERE id_osoby = osoba_id;
   END IF;
   IF osoba_telefon IS NOT NULL THEN
    UPDATE OSOBY o SET telefon = osoba_telefon WHERE id_osoby = osoba_id;
   END IF;
   IF osoba_pesel IS NOT NULL THEN
    UPDATE OSOBY o SET pesel = osoba_pesel WHERE id_osoby = osoba_id;
   END IF;
   IF adres_miasto IS NOT NULL THEN
    UPDATE ADRESY a SET miasto = adres_miasto WHERE id_adresu = adres_id;
   END IF;
   IF adres_ulica IS NOT NULL THEN
    UPDATE ADRESY a SET ulica = adres_ulica WHERE id_adresu = adres_id;
   END IF;
   IF adres_nr IS NOT NULL THEN
    UPDATE ADRESY a SET nr = adres_nr WHERE id_adresu = adres_id;
   END IF;
  END;
/

EXEC MODYFIKUJ_KLIENTA(7, 10, 'Klient1', NULL, 33, NULL, '+48786512459', NULL, 'Miasto1', NULL, '4/4');

SELECT * FROM KLIENCI k
JOIN OSOBY o ON (k.id_osoby = o.id_osoby)
JOIN ADRESY a ON (a.id_adresu = o.id_adresu)
WHERE k.id_klienta = 7;

CREATE OR REPLACE PROCEDURE DODAJ_ZAMOWIENIE (
  klient_osoba_imie IN VARCHAR2,
  klient_osoba_nazwisko IN VARCHAR2,
  klient_osoba_wiek IN NUMBER,
  klient_osoba_stan_cywilny IN VARCHAR2,
  klient_osoba_telefon IN VARCHAR2,
  klient_osoba_pesel IN CHAR,
  klient_adres_miasto IN VARCHAR2,
  klient_adres_ulica IN VARCHAR2,
  klient_adres_nr IN VARCHAR2,
  klient_znizka IN NUMBER,
  usluga_opis VARCHAR2,
  usluga_cena NUMBER,
  pracownik_id NUMBER
  ) AUTHID DEFINER IS
  adres_id NUMBER := NULL;
  osoba_id NUMBER;
  zlecenie_id NUMBER;
  klient_id NUMBER;
  usluga_id NUMBER;
  record_exists varchar2(1) := 'F';
  BEGIN
   -- DELETE - for testing
   BEGIN
   SELECT 'T' INTO record_exists FROM ZLECENIA z WHERE z.id_klienta =
    (SELECT k.id_klienta FROM KLIENCI k WHERE k.id_osoby =
     (SELECT o.id_osoby FROM OSOBY o WHERE o.pesel = klient_osoba_pesel)
    );
  EXCEPTION
    WHEN no_data_found THEN null;
  END;

   IF record_exists = 'T' THEN
   SELECT z.id_zlecenia INTO zlecenie_id FROM ZLECENIA z WHERE z.id_klienta = (SELECT k.id_klienta FROM KLIENCI k WHERE k.id_osoby = (SELECT o.id_osoby FROM OSOBY o WHERE o.pesel = klient_osoba_pesel));
   SELECT z.id_klienta INTO klient_id FROM ZLECENIA z WHERE z.id_klienta = (SELECT k.id_klienta FROM KLIENCI k WHERE k.id_osoby = (SELECT o.id_osoby FROM OSOBY o WHERE o.pesel = klient_osoba_pesel));
   SELECT z.id_uslugi INTO usluga_id FROM ZLECENIA z WHERE z.id_klienta = (SELECT k.id_klienta FROM KLIENCI k WHERE k.id_osoby = (SELECT o.id_osoby FROM OSOBY o WHERE o.pesel = klient_osoba_pesel));

   DELETE FROM ZLECENIA z WHERE z.id_zlecenia = zlecenie_id;
   DELETE FROM USLUGI u WHERE u.id_uslugi = usluga_id;

   DELETE FROM KLIENCI k WHERE k.id_klienta = klient_id;
   SELECT o.id_adresu INTO adres_id FROM OSOBY o WHERE o.pesel = klient_osoba_pesel;
   DELETE FROM OSOBY o WHERE o.pesel = klient_osoba_pesel;
   DELETE FROM ADRESY a WHERE a.id_adresu = adres_id;
   END IF;
   -- remove this part for production!


   SELECT MAX(id_adresu) INTO adres_id FROM ADRESY;
   adres_id := adres_id + 1;
   INSERT INTO ADRESY (id_adresu, miasto, ulica, nr) VALUES (adres_id, klient_adres_miasto, klient_adres_ulica, klient_adres_nr);

   SELECT MAX(id_osoby) INTO osoba_id FROM OSOBY;
   osoba_id := osoba_id + 1;
   INSERT INTO OSOBY (id_osoby, imie, nazwisko, wiek, stan_cywilny, telefon, pesel, id_adresu)
   VALUES (osoba_id, klient_osoba_imie, klient_osoba_nazwisko, klient_osoba_wiek, klient_osoba_stan_cywilny, klient_osoba_telefon, klient_osoba_pesel, adres_id);

   SELECT MAX(id_klienta) INTO klient_id FROM KLIENCI;
   klient_id := klient_id + 1;
   INSERT INTO KLIENCI (id_klienta, id_osoby, znizka) VALUES (klient_id, osoba_id, klient_znizka);

   SELECT MAX(id_uslugi) INTO usluga_id FROM USLUGI;
   usluga_id := usluga_id + 1;
   INSERT INTO USLUGI (id_uslugi, opis, cena) VALUES (usluga_id, usluga_opis, usluga_cena);

   SELECT MAX(id_zlecenia) INTO zlecenie_id FROM ZLECENIA;
   zlecenie_id := zlecenie_id + 1;
   INSERT INTO ZLECENIA (id_zlecenia, id_uslugi, id_klienta, id_pracownika) VALUES (zlecenie_id, usluga_id, klient_id, pracownik_id);
  END;
/

EXEC DODAJ_ZAMOWIENIE('KlientImie6', 'KlientNazwisko6', 20, 'wolny', '+48607566856', '74062979622', 'Miasto6', 'Ulica6', '6/616', 0, 'Usluga6', 1506, 7);

CREATE OR REPLACE FUNCTION getBestEmployee
RETURN VARCHAR2 IS
   CURSOR PracownicyCursor IS SELECT id_pracownika FROM PRACOWNICY;

   pracownik_id NUMBER;
   ilosc_zlecen_max NUMBER := 0;
   ilosc_zlecen NUMBER := 0;
   best_empolyee_id NUMBER := -1;
   best_empolyee_surname VARCHAR2(30);
BEGIN
   OPEN PracownicyCursor;
   LOOP
      FETCH PracownicyCursor INTO pracownik_id;
      EXIT WHEN PracownicyCursor%NOTFOUND;

      --dbms_output.put_line(pracownik_id);

      SELECT COUNT(z.id_zlecenia) INTO ilosc_zlecen
      FROM ZLECENIA z
      WHERE z.id_pracownika = pracownik_id;

      --dbms_output.put_line(ilosc_zlecen);

      IF ilosc_zlecen > ilosc_zlecen_max THEN
       ilosc_zlecen_max := ilosc_zlecen;
       best_empolyee_id := pracownik_id;
      END IF;
   END LOOP;

   CLOSE PracownicyCursor;
   IF best_empolyee_id = -1 THEN
    raise_application_error(-20001, 'There are no employees.');
   END IF;

   SELECT o.nazwisko INTO best_empolyee_surname FROM OSOBY o
   JOIN PRACOWNICY p ON (o.id_osoby = p.id_osoby)
   WHERE p.id_pracownika = best_empolyee_id;
   RETURN best_empolyee_surname;
END;
/

SELECT imie, nazwisko FROM OSOBY
WHERE nazwisko = getBestEmployee();
