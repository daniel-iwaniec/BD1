CREATE OR REPLACE PROCEDURE DROP_ALL AUTHID DEFINER IS
  CURSOR CURSOR_OBJECT IS
    SELECT object_type,'"'||object_name||'"'||decode(object_type, 'TABLE', ' CASCADE CONSTRAINTS', NULL) AS obj_name
    FROM user_objects
    WHERE object_type IN ('TRIGGER', 'TABLE', 'VIEW', 'SEQUENCE', 'PROCEDURE', 'FUNCTION', 'TYPE', 'PACKAGE')
    AND object_name != 'DROP_ALL';
BEGIN
  BEGIN
    FOR OBJECT in CURSOR_OBJECT LOOP
      EXECUTE IMMEDIATE ('DROP '||OBJECT.object_type||' ' ||OBJECT.obj_name);
    END LOOP;
  END;
END;
/
EXECUTE DROP_ALL;
DROP PROCEDURE DROP_ALL;

-- CREATE MIASTO
CREATE TABLE MIASTO (
  id NUMBER(10),
  nazwa VARCHAR2(100) NOT NULL
);
ALTER TABLE MIASTO ADD (
  CONSTRAINT MIASTO_PK PRIMARY KEY (id),
  CONSTRAINT MIASTO_NAZWA_UK UNIQUE (nazwa)
);

CREATE SEQUENCE MIASTO_SEQ;

CREATE OR REPLACE TRIGGER MIASTO_AUTOINCREMENT
BEFORE INSERT ON MIASTO
FOR EACH ROW
BEGIN
  SELECT MIASTO_SEQ.NEXTVAL
  INTO   :new.id
  FROM   dual;
END;
/

-- CREATE ADRES
CREATE TABLE ADRES (
  id NUMBER(10),
  miasto_id NUMBER(10) NOT NULL,
  ulica VARCHAR2(100) NOT NULL,
  nr_domu VARCHAR2(100) NOT NULL,
  nr_mieszkania VARCHAR2(100)
);
ALTER TABLE ADRES ADD (
  CONSTRAINT ADRES_PK PRIMARY KEY (id),
  CONSTRAINT ADRES_MIASTO_FK FOREIGN KEY (miasto_id) REFERENCES MIASTO (id) ON DELETE CASCADE
);

CREATE INDEX ADRES_ULICA_IDX ON ADRES (ulica) COMPUTE STATISTICS;

CREATE SEQUENCE ADRES_SEQ;

CREATE OR REPLACE TRIGGER ADRES_AUTOINCREMENT
BEFORE INSERT ON ADRES
FOR EACH ROW
BEGIN
  SELECT ADRES_SEQ.NEXTVAL
  INTO   :new.id
  FROM   dual;
END;
/

-- CREATE OSOBA
CREATE TABLE OSOBA (
  id NUMBER(10),
  adres_id NUMBER(10) NOT NULL,
  imie VARCHAR2(100) NOT NULL,
  nazwisko VARCHAR2(100) NOT NULL,
  wiek NUMBER(3) NOT NULL,
  stan_cywilny NUMBER(1) NOT NULL,
  telefon VARCHAR2(100),
  pesel NUMBER(11) NOT NULL
);
ALTER TABLE OSOBA ADD (
  CONSTRAINT OSOBA_PK PRIMARY KEY (id),
  CONSTRAINT OSOBA_ADRES_FK FOREIGN KEY (adres_id) REFERENCES ADRES (id) ON DELETE CASCADE,
  CONSTRAINT OSOBA_STAN_CYWILNY_CHK CHECK (stan_cywilny = 0 OR stan_cywilny = 1), -- Emulacja boolean
  CONSTRAINT OSOBA_PESEL_CHK CHECK ( --http://pl.wikipedia.org/wiki/PESEL#Metoda_r.C3.B3wnowa.C5.BCna
    CAST(SUBSTR(CAST((
    (1 * CAST(SUBSTR(CAST(pesel AS VARCHAR2(11)), 1, 1) AS NUMBER)) +
    (3 * CAST(SUBSTR(CAST(pesel AS VARCHAR2(11)), 2, 1) AS NUMBER)) +
    (7 * CAST(SUBSTR(CAST(pesel AS VARCHAR2(11)), 3, 1) AS NUMBER)) +
    (9 * CAST(SUBSTR(CAST(pesel AS VARCHAR2(11)), 4, 1) AS NUMBER)) +
    (1 * CAST(SUBSTR(CAST(pesel AS VARCHAR2(11)), 5, 1) AS NUMBER)) +
    (3 * CAST(SUBSTR(CAST(pesel AS VARCHAR2(11)), 6, 1) AS NUMBER)) +
    (7 * CAST(SUBSTR(CAST(pesel AS VARCHAR2(11)), 7, 1) AS NUMBER)) +
    (9 * CAST(SUBSTR(CAST(pesel AS VARCHAR2(11)), 8, 1) AS NUMBER)) +
    (1 * CAST(SUBSTR(CAST(pesel AS VARCHAR2(11)), 9, 1) AS NUMBER)) +
    (3 * CAST(SUBSTR(CAST(pesel AS VARCHAR2(11)), 10, 1) AS NUMBER)) +
    (1 * CAST(SUBSTR(CAST(pesel AS VARCHAR2(11)), 11, 1) AS NUMBER))) AS VARCHAR(3)), -1) AS NUMBER)
    = 0
  ),
  CONSTRAINT OSOBA_PESEL_UK UNIQUE (pesel)
);

CREATE SEQUENCE OSOBA_SEQ;

CREATE OR REPLACE TRIGGER OSOBA_AUTOINCREMENT
BEFORE INSERT ON OSOBA
FOR EACH ROW
BEGIN
  SELECT OSOBA_SEQ.NEXTVAL
  INTO   :new.id
  FROM   dual;
END;
/

-- CREATE PRACOWNIK
CREATE TABLE PRACOWNIK (
  id NUMBER(10),
  osoba_id NUMBER(10) NOT NULL,
  stanowisko VARCHAR2(100) NOT NULL,
  staz_pracy NUMBER(3),
  wynagrodzenie_brutto NUMBER(12,2)
);
ALTER TABLE PRACOWNIK ADD (
  CONSTRAINT PRACOWNIK_PK PRIMARY KEY (id),
  CONSTRAINT PRACOWNIK_OSOBA_FK FOREIGN KEY (osoba_id) REFERENCES OSOBA (id) ON DELETE CASCADE,
  CONSTRAINT PRACOWNIK_OSOBA_ID_UK UNIQUE (osoba_id)
);

CREATE SEQUENCE PRACOWNIK_SEQ;

CREATE OR REPLACE TRIGGER PRACOWNIK_AUTOINCREMENT
BEFORE INSERT ON PRACOWNIK
FOR EACH ROW
BEGIN
  SELECT PRACOWNIK_SEQ.NEXTVAL
  INTO   :new.id
  FROM   dual;
END;
/

-- CREATE KLIENT
CREATE TABLE KLIENT (
  id NUMBER(10),
  osoba_id NUMBER(10) NOT NULL,
  znizka NUMBER(3) DEFAULT 0 -- Wyra¿one procentowo (od 0 do 100 procent)
);
ALTER TABLE KLIENT ADD (
  CONSTRAINT KLIENT_PK PRIMARY KEY (id),
  CONSTRAINT KLIENT_OSOBA_FK FOREIGN KEY (osoba_id) REFERENCES OSOBA (id) ON DELETE CASCADE,
  CONSTRAINT KLIENT_ZNIZKA_CHK CHECK (znizka >= 0 AND znizka <= 100)
);

CREATE SEQUENCE KLIENT_SEQ;

CREATE OR REPLACE TRIGGER KLIENT_AUTOINCREMENT
BEFORE INSERT ON KLIENT
FOR EACH ROW
BEGIN
  SELECT KLIENT_SEQ.NEXTVAL
  INTO   :new.id
  FROM   dual;
END;
/

-- CREATE USLUGA
CREATE TABLE USLUGA (
  id NUMBER(10),
  opis_uslugi VARCHAR2(100) NOT NULL,
  cena_podstawowa NUMBER(12,2) NOT NULL
);
ALTER TABLE USLUGA ADD (
  CONSTRAINT USLUGA_PK PRIMARY KEY (id),
  CONSTRAINT USLUGA_OPIS_USLUGI_UK UNIQUE (opis_uslugi)
);

CREATE SEQUENCE USLUGA_SEQ;

CREATE OR REPLACE TRIGGER USLUGA_AUTOINCREMENT
BEFORE INSERT ON USLUGA
FOR EACH ROW
BEGIN
  SELECT USLUGA_SEQ.NEXTVAL
  INTO   :new.id
  FROM   dual;
END;
/

-- CREATE ZLECENIE
CREATE TABLE ZLECENIE (
  id NUMBER(10),
  usluga_id NUMBER(10) NOT NULL,
  klient_id NUMBER(10) NOT NULL,
  pracownik_id NUMBER(10) NOT NULL
);
ALTER TABLE ZLECENIE ADD (
  CONSTRAINT ZLECENIE_PK PRIMARY KEY (id),
  CONSTRAINT ZLECENIE_USLUGA_FK FOREIGN KEY (usluga_id) REFERENCES USLUGA (id) ON DELETE CASCADE,
  CONSTRAINT ZLECENIE_KLIENT_FK FOREIGN KEY (klient_id) REFERENCES KLIENT (id) ON DELETE CASCADE,
  CONSTRAINT ZLECENIE_PRACOWNIK_FK FOREIGN KEY (pracownik_id) REFERENCES PRACOWNIK (id) ON DELETE CASCADE
);

CREATE SEQUENCE ZLECENIE_SEQ;

CREATE OR REPLACE TRIGGER ZLECENIE_AUTOINCREMENT
BEFORE INSERT ON ZLECENIE
FOR EACH ROW
BEGIN
  SELECT ZLECENIE_SEQ.NEXTVAL
  INTO   :new.id
  FROM   dual;
END;
/


-- INSERT

-- INSERT ZLECENIE 1
DECLARE
  miasto_id NUMBER := NULL;
  adres_id NUMBER := NULL;
  osoba_id NUMBER := NULL;
  pracownik_id NUMBER := NULL;
  klient_id NUMBER := NULL;
  usluga_id NUMBER := NULL;
BEGIN
SET TRANSACTION ISOLATION LEVEL READ COMMITTED NAME 'CREATE_ZLECENIE1';
INSERT INTO MIASTO (nazwa) VALUES ('Kielce') RETURNING id INTO miasto_id;
INSERT INTO ADRES (miasto_id, ulica, nr_domu, nr_mieszkania) VALUES (miasto_id, 'Ulica 1', '1A', '2B') RETURNING id INTO adres_id;
INSERT INTO OSOBA (adres_id, imie, nazwisko, wiek, stan_cywilny, telefon, pesel) VALUES (adres_id, 'Imie pracownik1', 'Nazwisko pracownik1', 35, 1, '523456234', 77100504448) RETURNING id INTO osoba_id;
INSERT INTO PRACOWNIK (osoba_id, stanowisko, staz_pracy, wynagrodzenie_brutto) VALUES (osoba_id, 'Sprzedawca', 1, 2200.00) RETURNING id INTO pracownik_id;

INSERT INTO MIASTO (nazwa) VALUES ('Warszawa') RETURNING id INTO miasto_id;
INSERT INTO ADRES (miasto_id, ulica, nr_domu, nr_mieszkania) VALUES (miasto_id, 'Ulica 2', '2A', '3B') RETURNING id INTO adres_id;
INSERT INTO OSOBA (adres_id, imie, nazwisko, wiek, stan_cywilny, telefon, pesel) VALUES (adres_id, 'Imie klient1', 'Nazwisko klient1', 20, 0, '325654432', 54042719044) RETURNING id INTO osoba_id;
INSERT INTO KLIENT (osoba_id, znizka) VALUES (osoba_id, 10.00) RETURNING id INTO klient_id;

INSERT INTO USLUGA (opis_uslugi, cena_podstawowa) VALUES ('Us³uga1', 100.00) RETURNING id INTO usluga_id;

INSERT INTO ZLECENIE (usluga_id, klient_id, pracownik_id) VALUES (usluga_id, klient_id, pracownik_id);
COMMIT;
END;
/

-- INSERT ZLECENIE 2
DECLARE
  miasto1_id NUMBER := NULL;
  miasto2_id NUMBER := NULL;
  adres_id NUMBER := NULL;
  osoba_id NUMBER := NULL;
  pracownik_id NUMBER := NULL;
  klient_id NUMBER := NULL;
  usluga_id NUMBER := NULL;
  zlecenie_id NUMBER := NULL;
BEGIN
SET TRANSACTION ISOLATION LEVEL READ COMMITTED NAME 'CREATE_ZLECENIE2';
INSERT INTO MIASTO (nazwa) VALUES ('Kraków') RETURNING id INTO miasto1_id;
INSERT INTO ADRES (miasto_id, ulica, nr_domu, nr_mieszkania) VALUES (miasto1_id, 'Ulica 3', '3A', '5B') RETURNING id INTO adres_id;
INSERT INTO OSOBA (adres_id, imie, nazwisko, wiek, stan_cywilny, telefon, pesel) VALUES (adres_id, 'Imie pracownik2', 'Nazwisko pracownik2', 36, 1, '526452834', 91031204121) RETURNING id INTO osoba_id;
INSERT INTO PRACOWNIK (osoba_id, stanowisko, staz_pracy, wynagrodzenie_brutto) VALUES (osoba_id, 'Sprzedawca', 1, 2200.00) RETURNING id INTO pracownik_id;

INSERT INTO MIASTO (nazwa) VALUES ('Gdañsk') RETURNING id INTO miasto2_id;
INSERT INTO ADRES (miasto_id, ulica, nr_domu, nr_mieszkania) VALUES (miasto2_id, 'Ulica 20', '4A', '9B') RETURNING id INTO adres_id;
INSERT INTO OSOBA (adres_id, imie, nazwisko, wiek, stan_cywilny, telefon, pesel) VALUES (adres_id, 'Imie klient2', 'Nazwisko klient2', 22, 0, '325982932', 33092705122) RETURNING id INTO osoba_id;
INSERT INTO KLIENT (osoba_id, znizka) VALUES (osoba_id, 0) RETURNING id INTO klient_id;

INSERT INTO USLUGA (opis_uslugi, cena_podstawowa) VALUES ('Us³uga2', 200.10) RETURNING id INTO usluga_id;

INSERT INTO ZLECENIE (usluga_id, klient_id, pracownik_id) VALUES (usluga_id, klient_id, pracownik_id) RETURNING id INTO zlecenie_id;
COMMIT;
-- Bez sensu, ale jest dla dobra przyk³adu
DELETE MIASTO WHERE id IN (SELECT id FROM MIASTO WHERE id = miasto1_id);
DELETE MIASTO WHERE id IN (SELECT id FROM MIASTO WHERE id = miasto2_id);
DELETE USLUGA WHERE id IN (SELECT id FROM USLUGA WHERE id = usluga_id);
COMMIT;
END;
/

-- INSERT ZLECENIE 3
DECLARE
  miasto_id NUMBER := NULL;
  adres_id NUMBER := NULL;
  osoba_id NUMBER := NULL;
  pracownik_id NUMBER := NULL;
  klient_id NUMBER := NULL;
  usluga_id NUMBER := NULL;
BEGIN
SET TRANSACTION ISOLATION LEVEL READ COMMITTED NAME 'CREATE_ZLECENIE3';
INSERT INTO MIASTO (nazwa) VALUES ('Wroc³aw') RETURNING id INTO miasto_id;
INSERT INTO ADRES (miasto_id, ulica, nr_domu, nr_mieszkania) VALUES (miasto_id, 'Ulica 4', '12A', '23B') RETURNING id INTO adres_id;
INSERT INTO OSOBA (adres_id, imie, nazwisko, wiek, stan_cywilny, telefon, pesel) VALUES (adres_id, 'Imie pracownik3', 'Nazwisko pracownik3', 39, 1, '526773434', 27121818237) RETURNING id INTO osoba_id;
INSERT INTO PRACOWNIK (osoba_id, stanowisko, staz_pracy, wynagrodzenie_brutto) VALUES (osoba_id, 'Kierownik', 4, 3200.00) RETURNING id INTO pracownik_id;

INSERT INTO MIASTO (nazwa) VALUES ('Poznañ') RETURNING id INTO miasto_id;
INSERT INTO ADRES (miasto_id, ulica, nr_domu, nr_mieszkania) VALUES (miasto_id, 'Ulica 8', '14A', '26') RETURNING id INTO adres_id;
INSERT INTO OSOBA (adres_id, imie, nazwisko, wiek, stan_cywilny, telefon, pesel) VALUES (adres_id, 'Imie klient3', 'Nazwisko klient3', 25, 0, '399482966', 31060716152) RETURNING id INTO osoba_id;
INSERT INTO KLIENT (osoba_id, znizka) VALUES (osoba_id, 0) RETURNING id INTO klient_id;

INSERT INTO USLUGA (opis_uslugi, cena_podstawowa) VALUES ('U³‚uga3', 500.12) RETURNING id INTO usluga_id;

INSERT INTO ZLECENIE (usluga_id, klient_id, pracownik_id) VALUES (usluga_id, klient_id, pracownik_id);

COMMIT;
-- Bez sensu, ale jest dla dobra przyk³adu
UPDATE KLIENT SET znizka = 5 WHERE id = klient_id;
UPDATE KLIENT SET (znizka) = (
  SELECT znizka FROM (
    SELECT znizka
    FROM KLIENT
  ) WHERE ROWNUM = 1
) WHERE id = klient_id;
COMMIT;
END;
/


-- SELECT

-- SELECT (ten select jest bez sensu, ale chodzi³o o dobry przyk³ad)
CREATE OR REPLACE VIEW DATA_WAREHOUSE AS
SELECT
  id AS "Numer zlecenia",
  opis_uslugi AS "Us³uga",
  to_char(cena_podstawowa, 'fm9999999.90') AS "Cena us³ugi",
  to_char(cena_ze_znizka, 'fm9999999.90') AS "Cena ze zni¿k¹",

  imie_pracownika AS "Imiê pracownika",
  nazwisko_pracownika AS "Nazwisko pracownika",
  pesel_pracownika AS "Pesel pracownika",
  stanowisko AS "Stanowisko pracownika",
  CASE -- terminologia wg http://pl.wikipedia.org/wiki/Stan_cywilny
   WHEN stan_cywilny_pracownika = 0 THEN 'Stan wolny'
   WHEN stan_cywilny_pracownika = 1 THEN 'Ma³¿onek'
  END AS "Stan cywilny pracownika",
  miasto_pracownika || ', ' || ulica_pracownika || ' ' || nr_domu_pracownika ||
  CASE
   WHEN nr_mieszkania_pracownika IS NOT NULL THEN '/' || nr_mieszkania_pracownika
   ELSE ''
  END AS "Adres pracownika",

  imie_klienta AS "Imie klienta",
  nazwisko_klienta AS "Nazwisko klienta",
  pesel_klienta AS "Pesel klienta",
  miasto_klienta || ', ' || ulica_klienta || ' ' || nr_domu_klienta ||
  CASE
   WHEN nr_mieszkania_klienta IS NOT NULL THEN '/' || nr_mieszkania_klienta
   ELSE ''
  END AS "Adres klienta"
FROM (
SELECT * FROM (
  SELECT
    ZLECENIE.id,
    USLUGA.opis_uslugi,
    USLUGA.cena_podstawowa,
    ROUND((USLUGA.cena_podstawowa - ((KLIENT.znizka/100) * USLUGA.cena_podstawowa)), 2) AS cena_ze_znizka,

    PRACOWNIK_OSOBA.imie AS imie_pracownika,
    PRACOWNIK_OSOBA.nazwisko AS nazwisko_pracownika,
    PRACOWNIK_OSOBA.pesel AS pesel_pracownika,
    PRACOWNIK_OSOBA.stan_cywilny AS stan_cywilny_pracownika,
    PRACOWNIK.stanowisko,
    PRACOWNIK_ADRES.ulica AS ulica_pracownika,
    PRACOWNIK_ADRES.nr_domu AS nr_domu_pracownika,
    PRACOWNIK_ADRES.nr_mieszkania AS nr_mieszkania_pracownika,
    PRACOWNIK_MIASTO.nazwa AS miasto_pracownika,

    KLIENT_OSOBA.imie AS imie_klienta,
    KLIENT_OSOBA.nazwisko AS nazwisko_klienta,
    KLIENT_OSOBA.pesel AS pesel_klienta,
    KLIENT_ADRES.ulica AS ulica_klienta,
    KLIENT_ADRES.nr_domu AS nr_domu_klienta,
    KLIENT_ADRES.nr_mieszkania AS nr_mieszkania_klienta,
    KLIENT_MIASTO.nazwa AS miasto_klienta
  FROM ZLECENIE
  JOIN USLUGA ON (ZLECENIE.USLUGA_ID = USLUGA.ID)

  JOIN PRACOWNIK ON (ZLECENIE.PRACOWNIK_ID = PRACOWNIK.ID)
  JOIN OSOBA PRACOWNIK_OSOBA ON (PRACOWNIK.OSOBA_ID = PRACOWNIK_OSOBA.ID)
  JOIN ADRES PRACOWNIK_ADRES ON (PRACOWNIK_OSOBA.ADRES_ID = PRACOWNIK_ADRES.ID)
  JOIN MIASTO PRACOWNIK_MIASTO ON (PRACOWNIK_ADRES.MIASTO_ID = PRACOWNIK_MIASTO.ID)

  JOIN KLIENT ON (ZLECENIE.KLIENT_ID = KLIENT.ID)
  JOIN OSOBA KLIENT_OSOBA ON (KLIENT.OSOBA_ID = KLIENT_OSOBA.ID)
  JOIN ADRES KLIENT_ADRES ON (KLIENT_OSOBA.ADRES_ID = KLIENT_ADRES.ID)
  JOIN MIASTO KLIENT_MIASTO ON (KLIENT_ADRES.MIASTO_ID = KLIENT_MIASTO.ID)

  ORDER BY ZLECENIE.id ASC
) WHERE ROWNUM = 1

UNION ALL

SELECT * FROM (
  SELECT
    ZLECENIE.id,
    USLUGA.opis_uslugi,
    USLUGA.cena_podstawowa,
    ROUND((USLUGA.cena_podstawowa - ((KLIENT.znizka/100) * USLUGA.cena_podstawowa)), 2) AS cena_ze_znizka,

    PRACOWNIK_OSOBA.imie AS imie_pracownika,
    PRACOWNIK_OSOBA.nazwisko AS nazwisko_pracownika,
    PRACOWNIK_OSOBA.pesel AS pesel_pracownika,
    PRACOWNIK_OSOBA.stan_cywilny AS stan_cywilny_pracownika,
    PRACOWNIK.stanowisko,
    PRACOWNIK_ADRES.ulica AS ulica_pracownika,
    PRACOWNIK_ADRES.nr_domu AS nr_domu_pracownika,
    PRACOWNIK_ADRES.nr_mieszkania AS nr_mieszkania_pracownika,
    PRACOWNIK_MIASTO.nazwa AS miasto_pracownika,

    KLIENT_OSOBA.imie AS imie_klienta,
    KLIENT_OSOBA.nazwisko AS nazwisko_klienta,
    KLIENT_OSOBA.pesel AS pesel_klienta,
    KLIENT_ADRES.ulica AS ulica_klienta,
    KLIENT_ADRES.nr_domu AS nr_domu_klienta,
    KLIENT_ADRES.nr_mieszkania AS nr_mieszkania_klienta,
    KLIENT_MIASTO.nazwa AS miasto_klienta
  FROM ZLECENIE
  JOIN USLUGA ON (ZLECENIE.USLUGA_ID = USLUGA.ID)

  JOIN PRACOWNIK ON (ZLECENIE.PRACOWNIK_ID = PRACOWNIK.ID)
  JOIN OSOBA PRACOWNIK_OSOBA ON (PRACOWNIK.OSOBA_ID = PRACOWNIK_OSOBA.ID)
  JOIN ADRES PRACOWNIK_ADRES ON (PRACOWNIK_OSOBA.ADRES_ID = PRACOWNIK_ADRES.ID)
  JOIN MIASTO PRACOWNIK_MIASTO ON (PRACOWNIK_ADRES.MIASTO_ID = PRACOWNIK_MIASTO.ID)

  JOIN KLIENT ON (ZLECENIE.KLIENT_ID = KLIENT.ID)
  JOIN OSOBA KLIENT_OSOBA ON (KLIENT.OSOBA_ID = KLIENT_OSOBA.ID)
  JOIN ADRES KLIENT_ADRES ON (KLIENT_OSOBA.ADRES_ID = KLIENT_ADRES.ID)
  JOIN MIASTO KLIENT_MIASTO ON (KLIENT_ADRES.MIASTO_ID = KLIENT_MIASTO.ID)

  ORDER BY ZLECENIE.id DESC
) WHERE ROWNUM = 1
);

SELECT * FROM DATA_WAREHOUSE;
