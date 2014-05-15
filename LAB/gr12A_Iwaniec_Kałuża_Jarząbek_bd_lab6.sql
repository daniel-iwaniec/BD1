-- DROP SEQUENCES
CREATE OR REPLACE PROCEDURE DROP_SEQUENCES AUTHID DEFINER IS
  CURSOR CURSOR_OBJECT IS
    SELECT object_type,'"'||object_name||'"' AS obj_name FROM user_objects WHERE object_type = 'SEQUENCE';
BEGIN
  BEGIN
    FOR OBJECT in CURSOR_OBJECT LOOP
      EXECUTE IMMEDIATE ('DROP '||OBJECT.object_type||' '||OBJECT.obj_name);
    END LOOP;
  END;
END;
/
EXECUTE DROP_SEQUENCES;

CREATE OR REPLACE VIEW osoba_adres AS
SELECT o.imie, o.nazwisko, a.miasto
FROM OSOBY o
JOIN ADRESY a ON (o.id_adresu = a.id_adresu);

SELECT * FROM osoba_adres;

CREATE OR REPLACE VIEW osoba_praca AS
SELECT o.imie, o.nazwisko, CONCAT(CONCAT(CONCAT(CONCAT(a.miasto, ', '), a.ulica), ' '), a.nr) AS "ADRES", p.pensja_br, s.nazwa
FROM OSOBY o
JOIN ADRESY a ON (o.id_adresu = a.id_adresu)
JOIN PRACOWNICY p ON (o.id_osoby = p.id_osoby)
JOIN STANOWISKA s ON (s.id_stanowiska = p.id_stanowiska)
WHERE s.nazwa != 'DYREKTOR'
ORDER BY p.pensja_br ASC;

SELECT * FROM osoba_praca;

CREATE OR REPLACE VIEW osoba_praca_kielce AS
SELECT o.imie, o.nazwisko, p.pensja_br, CONCAT(CONCAT(CONCAT(CONCAT(a.miasto, ', '), a.ulica), ' '), a.nr) AS "ADRES"
FROM OSOBY o
JOIN ADRESY a ON (o.id_adresu = a.id_adresu)
JOIN PRACOWNICY p ON (o.id_osoby = p.id_osoby)
WHERE a.miasto = 'Kielce'
ORDER BY p.pensja_br ASC;

SELECT * FROM osoba_praca_kielce;

CREATE OR REPLACE VIEW osoba_wolna AS
SELECT o.imie, o.nazwisko, CONCAT(CONCAT(CONCAT(CONCAT(a.miasto, ', '), a.ulica), ' '), a.nr) AS "ADRES"
FROM OSOBY o
JOIN ADRESY a ON (o.id_adresu = a.id_adresu)
WHERE o.stan_cywilny = 'wolny'OR o.stan_cywilny = 'wolna';

SELECT * FROM osoba_wolna;

CREATE OR REPLACE VIEW osoba_stanowisko AS
SELECT o.imie, o.nazwisko, s.nazwa, s.opis
FROM OSOBY o
JOIN PRACOWNICY p ON (o.id_osoby = p.id_osoby)
JOIN STANOWISKA s ON (s.id_stanowiska = p.id_stanowiska)
WHERE p.pensja_br > 3500;

SELECT * FROM osoba_stanowisko;

CREATE OR REPLACE VIEW osoba_dochod AS
SELECT p.id_pracownika, o.imie, o.nazwisko, CONCAT(SUM(u.cena), 'zl')  AS "DOCHOD"
FROM OSOBY o
JOIN PRACOWNICY p ON (o.id_osoby = p.id_osoby)
JOIN STANOWISKA s ON (s.id_stanowiska = p.id_stanowiska)
JOIN ZLECENIA z ON (z.id_pracownika = z.id_pracownika)
JOIN USLUGI u ON (z.id_uslugi = u.id_uslugi)
GROUP BY p.id_pracownika, o.imie, o.nazwisko;

SELECT * FROM osoba_dochod;

CREATE OR REPLACE VIEW osoba_zlecenia_ilosc AS
SELECT p.id_pracownika, o.imie, o.nazwisko, COUNT(z.id_zlecenia) AS "ILOSC ZLECEN"
FROM OSOBY o
JOIN PRACOWNICY p ON (o.id_osoby = p.id_osoby)
JOIN STANOWISKA s ON (s.id_stanowiska = p.id_stanowiska)
JOIN ZLECENIA z ON (p.id_pracownika = z.id_pracownika)
GROUP BY p.id_pracownika, o.imie, o.nazwisko
ORDER BY "ILOSC ZLECEN" DESC;

SELECT * FROM osoba_zlecenia_ilosc;

CREATE SEQUENCE osoby_id_autoinc
 START WITH     21
 INCREMENT BY   1
 NOCACHE
 NOCYCLE;

CREATE SEQUENCE adresy_id_autoinc
 START WITH     16
 INCREMENT BY   1
 NOCACHE
 NOCYCLE;

CREATE SEQUENCE klienci_id_autoinc
 START WITH     15
 INCREMENT BY   1
 NOCACHE
 NOCYCLE;

CREATE SEQUENCE pracownicy_id_autoinc
 START WITH     7
 INCREMENT BY   1
 NOCACHE
 NOCYCLE;

CREATE SEQUENCE stanowiska_id_autoinc
 START WITH     5
 INCREMENT BY   1
 NOCACHE
 NOCYCLE;

CREATE SEQUENCE uslugi_id_autoinc
 START WITH     6
 INCREMENT BY   1
 NOCACHE
 NOCYCLE;

CREATE SEQUENCE zlecenia_id_autoinc
 START WITH     31
 INCREMENT BY   1
 NOCACHE
 NOCYCLE;

CREATE OR REPLACE TRIGGER osoba_AUTOINCREMENT
BEFORE INSERT ON OSOBY
FOR EACH ROW
BEGIN
  SELECT osoby_id_autoinc.NEXTVAL
  INTO   :new.id_osoby
  FROM   dual;
END;
/

CREATE OR REPLACE TRIGGER adres_AUTOINCREMENT
BEFORE INSERT ON ADRESY
FOR EACH ROW
BEGIN
  SELECT adresy_id_autoinc.NEXTVAL
  INTO   :new.id_adresu
  FROM   dual;
END;
/

CREATE OR REPLACE TRIGGER klient_AUTOINCREMENT
BEFORE INSERT ON KLIENCI
FOR EACH ROW
BEGIN
  SELECT klienci_id_autoinc.NEXTVAL
  INTO   :new.id_klienta
  FROM   dual;
END;
/

CREATE OR REPLACE TRIGGER pracownik_AUTOINCREMENT
BEFORE INSERT ON PRACOWNICY
FOR EACH ROW
BEGIN
  SELECT pracownicy_id_autoinc.NEXTVAL
  INTO   :new.id_pracownika
  FROM   dual;
END;
/

CREATE OR REPLACE TRIGGER stanowisko_AUTOINCREMENT
BEFORE INSERT ON STANOWISKA
FOR EACH ROW
BEGIN
  SELECT stanowiska_id_autoinc.NEXTVAL
  INTO   :new.id_stanowiska
  FROM   dual;
END;
/

CREATE OR REPLACE TRIGGER usluga_AUTOINCREMENT
BEFORE INSERT ON USLUGI
FOR EACH ROW
BEGIN
  SELECT uslugi_id_autoinc.NEXTVAL
  INTO   :new.id_uslugi
  FROM   dual;
END;
/

CREATE OR REPLACE TRIGGER zlecenia_AUTOINCREMENT
BEFORE INSERT ON ZLECENIA
FOR EACH ROW
BEGIN
  SELECT zlecenia_id_autoinc.NEXTVAL
  INTO   :new.id_zlecenia
  FROM   dual;
END;
/

DELETE FROM OSOBY WHERE id_osoby = 21 OR id_osoby = 22;

INSERT INTO OSOBY (imie, nazwisko, wiek, stan_cywilny, telefon, pesel, id_adresu) VALUES ('Imie pracownik1', 'Nazwisko pracownik1', 35, 1, '523456236', 771005046, 1);
INSERT INTO OSOBY (id_osoby, imie, nazwisko, wiek, stan_cywilny, telefon, pesel, id_adresu) VALUES (23, 'Imie pracownik2', 'Nazwisko pracownik2', 36, 0, '523456237', 771005047, 2);

DELETE FROM ADRESY WHERE id_adresu = 16 OR id_adresu = 17;

INSERT INTO ADRESY (miasto, ulica, nr) VALUES ('Miasto1', 'Ulica1', '1/1');
INSERT INTO ADRESY (miasto, ulica, nr) VALUES ('Miasto2', 'Ulica2', '2/2');

DELETE FROM ZLECENIA WHERE id_zlecenia = 31 OR id_zlecenia = 32;
DELETE FROM KLIENCI WHERE id_klienta = 15 OR id_klienta = 16;

INSERT INTO KLIENCI (id_osoby, znizka) VALUES (8, 0);
INSERT INTO KLIENCI (id_osoby, znizka) VALUES (15, 0);

DELETE FROM PRACOWNICY WHERE id_pracownika = 7 OR id_pracownika = 8;

INSERT INTO PRACOWNICY (id_osoby, id_stanowiska, staz, pensja_br) VALUES (6, 1, 1, 2000);
INSERT INTO PRACOWNICY (id_osoby, id_stanowiska, staz, pensja_br) VALUES (7, 2, 2, 5000);

DELETE FROM STANOWISKA WHERE id_stanowiska = 5 OR id_stanowiska = 6;

INSERT INTO STANOWISKA (nazwa, opis) VALUES ('Stanowisko1', 'Opis stanowiska1');
INSERT INTO STANOWISKA (nazwa, opis) VALUES ('Stanowisko2', 'Opis stanowiska2');

DELETE FROM USLUGI WHERE id_uslugi = 6 OR id_uslugi = 7;

INSERT INTO USLUGI (opis, cena) VALUES ('Opis uslugi1', 500);
INSERT INTO USLUGI (opis, cena) VALUES ('Opis uslugi2', 1000);

INSERT INTO ZLECENIA (id_uslugi, id_klienta, id_pracownika) VALUES (6, 15, 7);
INSERT INTO ZLECENIA (id_uslugi, id_klienta, id_pracownika) VALUES (7, 16, 8);

CREATE SEQUENCE parzyste_seq
 START WITH     2
 INCREMENT BY   2
 NOCACHE
 NOCYCLE;

CREATE SEQUENCE siodemki_seq
 START WITH     7
 INCREMENT BY   7
 NOCACHE
 NOCYCLE;

SELECT parzyste_seq.NEXTVAL FROM DUAL;
SELECT parzyste_seq.NEXTVAL FROM DUAL;
SELECT parzyste_seq.NEXTVAL FROM DUAL;
SELECT parzyste_seq.CURRVAL FROM DUAL;

SELECT siodemki_seq.NEXTVAL FROM DUAL;
SELECT siodemki_seq.NEXTVAL FROM DUAL;
SELECT siodemki_seq.NEXTVAL FROM DUAL;
SELECT siodemki_seq.CURRVAL FROM DUAL;