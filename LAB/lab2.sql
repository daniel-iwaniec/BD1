-- DROP
CREATE OR REPLACE PROCEDURE DROP_ALL AUTHID DEFINER IS
  CURSOR CURSOR_OBJECT IS
    SELECT object_type,'"'||object_name||'"'||decode(object_type, 'TABLE', ' CASCADE CONSTRAINTS', NULL) AS obj_name
    FROM user_objects
    WHERE object_type IN ('TABLE', 'VIEW', 'SEQUENCE');
BEGIN
  BEGIN
    FOR OBJECT in CURSOR_OBJECT LOOP
      EXECUTE IMMEDIATE ('DROP '||OBJECT.object_type||' ' ||OBJECT.obj_name);
    END LOOP;
  END;
END;
/

EXECUTE DROP_ALL;


-- CREATE

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
  nr_domu VARCHAR2(100) NOT NULL, -- Może zawierać litery, np. 12A
  nr_mieszkania VARCHAR2(100) -- jak wyżej
);
ALTER TABLE ADRES ADD (
  CONSTRAINT ADRES_PK PRIMARY KEY (id),
  CONSTRAINT ADRES_MIASTO_FK FOREIGN KEY (miasto_id) REFERENCES MIASTO (id)
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
  CONSTRAINT OSOBA_ADRES_FK FOREIGN KEY (adres_id) REFERENCES ADRES (id),
  CONSTRAINT OSOBA_STAN_CYWILNY_CHK CHECK (stan_cywilny = 0 OR stan_cywilny = 1), -- Emulacja boolean
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
  CONSTRAINT PRACOWNIK_OSOBA_FK FOREIGN KEY (osoba_id) REFERENCES OSOBA (id),
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
  znizka NUMBER(3) DEFAULT 0 -- Wyrażone procentowo (od 0 do 100 procent)
);
ALTER TABLE KLIENT ADD (
  CONSTRAINT KLIENT_PK PRIMARY KEY (id),
  CONSTRAINT KLIENT_OSOBA_FK FOREIGN KEY (osoba_id) REFERENCES OSOBA (id),
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

-- CREATE ZLECENIE
CREATE TABLE ZLECENIE (
  id NUMBER(10),
  usluga_id NUMBER(10) NOT NULL,
  klient_id NUMBER(10) NOT NULL,
  pracownik_id NUMBER(10) NOT NULL
);
ALTER TABLE ZLECENIE ADD (
  CONSTRAINT ZLECENIE_PK PRIMARY KEY (id),
  CONSTRAINT ZLECENIE_USLUGA_FK FOREIGN KEY (usluga_id) REFERENCES USLUGA (id),
  CONSTRAINT ZLECENIE_KLIENT_FK FOREIGN KEY (klient_id) REFERENCES KLIENT (id),
  CONSTRAINT ZLECENIE_PRACOWNIK_FK FOREIGN KEY (pracownik_id) REFERENCES PRACOWNIK (id)
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

INSERT INTO USLUGA (opis_uslugi, cena_podstawowa) VALUES ('Usługa1', 100.00) RETURNING id INTO usluga_id;

INSERT INTO ZLECENIE (usluga_id, klient_id, pracownik_id) VALUES (usluga_id, klient_id, pracownik_id);
COMMIT;
END;
/

-- INSERT ZLECENIE 2
DECLARE
  miasto_id NUMBER := NULL;
  adres_id NUMBER := NULL;
  osoba_id NUMBER := NULL;
  pracownik_id NUMBER := NULL;
  klient_id NUMBER := NULL;
  usluga_id NUMBER := NULL;
BEGIN
SET TRANSACTION ISOLATION LEVEL READ COMMITTED NAME 'CREATE_ZLECENIE2';
INSERT INTO MIASTO (nazwa) VALUES ('Kraków') RETURNING id INTO miasto_id;
INSERT INTO ADRES (miasto_id, ulica, nr_domu, nr_mieszkania) VALUES (miasto_id, 'Ulica 3', '3A', '5B') RETURNING id INTO adres_id;
INSERT INTO OSOBA (adres_id, imie, nazwisko, wiek, stan_cywilny, telefon, pesel) VALUES (adres_id, 'Imie pracownik2', 'Nazwisko pracownik2', 36, 1, '526452834', 91031204121) RETURNING id INTO osoba_id;
INSERT INTO PRACOWNIK (osoba_id, stanowisko, staz_pracy, wynagrodzenie_brutto) VALUES (osoba_id, 'Sprzedawca', 1, 2200.00) RETURNING id INTO pracownik_id;

INSERT INTO MIASTO (nazwa) VALUES ('Gdańsk') RETURNING id INTO miasto_id;
INSERT INTO ADRES (miasto_id, ulica, nr_domu, nr_mieszkania) VALUES (miasto_id, 'Ulica 20', '4A', '9B') RETURNING id INTO adres_id;
INSERT INTO OSOBA (adres_id, imie, nazwisko, wiek, stan_cywilny, telefon, pesel) VALUES (adres_id, 'Imie klient2', 'Nazwisko klient2', 22, 0, '325982932', 33092705122) RETURNING id INTO osoba_id;
INSERT INTO KLIENT (osoba_id, znizka) VALUES (osoba_id, 0) RETURNING id INTO klient_id;

INSERT INTO USLUGA (opis_uslugi, cena_podstawowa) VALUES ('Usługa2', 200.10) RETURNING id INTO usluga_id;

INSERT INTO ZLECENIE (usluga_id, klient_id, pracownik_id) VALUES (usluga_id, klient_id, pracownik_id);
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
INSERT INTO MIASTO (nazwa) VALUES ('Wrocław') RETURNING id INTO miasto_id;
INSERT INTO ADRES (miasto_id, ulica, nr_domu, nr_mieszkania) VALUES (miasto_id, 'Ulica 4', '12A', '23B') RETURNING id INTO adres_id;
INSERT INTO OSOBA (adres_id, imie, nazwisko, wiek, stan_cywilny, telefon, pesel) VALUES (adres_id, 'Imie pracownik3', 'Nazwisko pracownik3', 39, 1, '526773434', 27121818237) RETURNING id INTO osoba_id;
INSERT INTO PRACOWNIK (osoba_id, stanowisko, staz_pracy, wynagrodzenie_brutto) VALUES (osoba_id, 'Kierownik', 4, 3200.00) RETURNING id INTO pracownik_id;

INSERT INTO MIASTO (nazwa) VALUES ('Poznań') RETURNING id INTO miasto_id;
INSERT INTO ADRES (miasto_id, ulica, nr_domu, nr_mieszkania) VALUES (miasto_id, 'Ulica 8', '14A', '26') RETURNING id INTO adres_id;
INSERT INTO OSOBA (adres_id, imie, nazwisko, wiek, stan_cywilny, telefon, pesel) VALUES (adres_id, 'Imie klient3', 'Nazwisko klient3', 25, 0, '399482966', 31060716152) RETURNING id INTO osoba_id;
INSERT INTO KLIENT (osoba_id, znizka) VALUES (osoba_id, 0) RETURNING id INTO klient_id;

INSERT INTO USLUGA (opis_uslugi, cena_podstawowa) VALUES ('Usługa3', 500.12) RETURNING id INTO usluga_id;

INSERT INTO ZLECENIE (usluga_id, klient_id, pracownik_id) VALUES (usluga_id, klient_id, pracownik_id);
COMMIT;
END;
/

-- DELETE ZLECENIE 3
BEGIN
SET TRANSACTION ISOLATION LEVEL READ COMMITTED NAME 'DROP_ZLECENIE3';
-- DELETE HERE
COMMIT;
END;
/

-- UPDATE ZLECENIE 2
BEGIN
SET TRANSACTION ISOLATION LEVEL READ COMMITTED NAME 'UPDATE_ZLECENIE2';
-- UPDATE HERE
COMMIT;
END;
/


-- SELECT

-- SELECT ADRES
SELECT * FROM ADRES;


-- TODO
-- select 1 i 2 zlecenie (widok z tego zapytania i select z widoku potem) (unia, case, podzapytanie itp.)
-- select po indeksowanym polu i explain analyze
-- prompt czy chce explain czy zwykly select
-- INSERT INTO ADRES (miasto_id, ulica, nr_domu, nr_mieszkania) SELECT * FROM (SELECT id, 'Ulica 1' AS ulica, '1A' AS nr_domu, '2B' AS nr_mieszkania FROM MIASTO ORDER BY id DESC) WHERE ROWNUM = 1;
-- check w na pesel i wiek?