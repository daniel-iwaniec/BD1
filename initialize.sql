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
    EXCEPTION
    WHEN OTHERS THEN
     ROLLBACK;
  END;
END;
/
EXECUTE DROP_ALL;
DROP PROCEDURE DROP_ALL;

CREATE TABLE Adresy (
Id_adresu NUMBER CONSTRAINT adres_pk PRIMARY KEY,
Miasto VARCHAR2(25) NOT NULL,
Ulica VARCHAR2(30) NOT NULL,
Nr VARCHAR2(10) NOT NULL
);

CREATE TABLE Osoby (
Id_osoby NUMBER CONSTRAINT osoby_pk PRIMARY KEY,
Imie VARCHAR2(15) NOT NULL,
Nazwisko VARCHAR2(30) NOT NULL,
Wiek NUMBER NOT NULL CONSTRAINT ch_wiek CHECK((Wiek>=0) AND (Wiek<=125)),
Stan_cywilny VARCHAR2(12) NOT NULL,
Telefon VARCHAR2(20),
Pesel CHAR(11) NOT NULL CONSTRAINT osoba_uni UNIQUE,
Id_adresu NUMBER NOT NULL,
CONSTRAINT os_ad_fk FOREIGN KEY (Id_adresu) REFERENCES Adresy(Id_adresu)
);

CREATE TABLE Klienci (
Id_klienta NUMBER CONSTRAINT klient_pk PRIMARY KEY,
Id_osoby NUMBER NOT NULL CONSTRAINT kl_unique UNIQUE,
Znizka NUMBER,
CONSTRAINT kl_os_fk FOREIGN KEY (Id_osoby) REFERENCES Osoby(Id_osoby)
);

CREATE TABLE Stanowiska (
Id_stanowiska NUMBER CONSTRAINT stanowisko_pk PRIMARY KEY,
Nazwa VARCHAR2(20) NOT NULL,
Opis VARCHAR2(500)
);

CREATE TABLE Pracownicy (
Id_pracownika NUMBER CONSTRAINT pracownik_pk PRIMARY KEY,
Id_osoby NUMBER NOT NULL CONSTRAINT pr_unique UNIQUE,
Id_stanowiska NUMBER NOT NULL,
Staz NUMBER NOT NULL CONSTRAINT ch_staz CHECK((Staz>=0) AND (Staz<=45)),
Pensja_br NUMBER NOT NULL CONSTRAINT pen_staz CHECK(Pensja_br>=1226),
CONSTRAINT pr_os_fk FOREIGN KEY (Id_osoby) REFERENCES Osoby(Id_osoby),
CONSTRAINT pr_st_fk FOREIGN KEY (Id_stanowiska) REFERENCES Stanowiska(Id_stanowiska)
);

CREATE TABLE Uslugi (
Id_uslugi NUMBER CONSTRAINT uslugi_pk PRIMARY KEY,
Opis VARCHAR2(500),
Cena NUMBER NOT NULL
);

CREATE TABLE Zlecenia (
Id_zlecenia NUMBER CONSTRAINT zlecenie_pk PRIMARY KEY,
Id_uslugi NUMBER NOT NULL,
Id_klienta NUMBER NOT NULL,
Id_pracownika NUMBER NOT NULL,
CONSTRAINT zl_us_fk FOREIGN KEY (Id_uslugi) REFERENCES Uslugi(Id_uslugi),
CONSTRAINT zl_kl_fk FOREIGN KEY (Id_klienta) REFERENCES Klienci(Id_klienta),
CONSTRAINT zl_pr_fk FOREIGN KEY (Id_pracownika) REFERENCES Pracownicy(Id_pracownika)
);

INSERT INTO Adresy VALUES(1,'Kielce','Warszawska','15/9');
INSERT INTO Adresy VALUES(2,'Kielce','Padarewskiego','34a');
INSERT INTO Adresy VALUES(3,'Morawica','Szpitalna','3');
INSERT INTO Adresy VALUES(4,'J�drzej�w','11 listopada','42');
INSERT INTO Adresy VALUES(5,'Busko Zdr�j','Wojska Polskiego','123');
INSERT INTO Adresy VALUES(6,'Kielce','Podklasztorna','16');
INSERT INTO Adresy VALUES(7,'Piekosz�w','Kielecka','5a');
INSERT INTO Adresy VALUES(8,'Kielce','Du�a','42');
INSERT INTO Adresy VALUES(9,'Krak�w','Smocza','102/23');
INSERT INTO Adresy VALUES(10,'Pi�cz�w','Chrobrego','13');
INSERT INTO Adresy VALUES(11,'Rabka','Zakopia�ska','64');
INSERT INTO Adresy VALUES(12,'Kielce','Jagiello�ska','23');
INSERT INTO Adresy VALUES(13,'Skar�ysko Kamienna','Staszowska','1/8');
INSERT INTO Adresy VALUES(14,'Busko Zdr�j','Zdrojowa','4');
INSERT INTO Adresy VALUES(15,'Kielce','1000-lecia P.P.','7');

INSERT INTO Osoby VALUES(1,'Anna','Ciosk',28,'wolna','+48(41)344-54-27','81050854796',4);
INSERT INTO Osoby VALUES(2,'Krzysztof','Kowalski',35,'�onaty','+48(41)354-28-64','73082823846',1);
INSERT INTO Osoby VALUES(3,'Mariusz','Piotrowski',40,'wolna',NULL,'69121868745',3);
INSERT INTO Osoby VALUES(4,'Tadeusz','Maliniak',31,'wolny','+48510232210','78100864875',15);
INSERT INTO Osoby VALUES(5,'Karol','Wojciechowski',50,'wolny','+48(41)378-64-27','59010565847',12);
INSERT INTO Osoby VALUES(6,'Maciej','Radecki',27,'wolny','+48607564218','82112554796',9);
INSERT INTO Osoby VALUES(7,'Pawe�','Gruszczy�ski',29,'�onaty','+48606487537','80031854796',11);
INSERT INTO Osoby VALUES(8,'Pawe�','Laprus',34,'�onaty','+48(41)346-15-78','75101979621',8);
INSERT INTO Osoby VALUES(9,'Robert','S�oma',45,'wolny','+48(41)313-77-66','64072959621',7);
INSERT INTO Osoby VALUES(10,'Kamila','Baran',35,'m�atka',NULL,'74062979621',11);
INSERT INTO Osoby VALUES(11,'Albert','Drozdowski',29,'�onaty',NULL,'80090156812',2);
INSERT INTO Osoby VALUES(12,'Henryk','Bista',32,'wolny','+48786512458','77040368154',4);
INSERT INTO Osoby VALUES(13,'Marek','Makuszy�ski',30,'wolny','+48888123654','79010187769',5);
INSERT INTO Osoby VALUES(14,'Zbigniew','Michta',26,'�onaty','+48511325568','83060650012',13);
INSERT INTO Osoby VALUES(15,'Katarzyna','Michalska',54,'wdowa',NULL,'55111597532',6);
INSERT INTO Osoby VALUES(16,'Ewa','Rajska',24,'wolna','+48(41)348-11-22','85103059971',9);
INSERT INTO Osoby VALUES(17,'Bronis�aw','Borewicz',36,'�onaty','+48505355684','73022867833',2);
INSERT INTO Osoby VALUES(18,'Agata','Chyra',32,'m�atka','+48(41)355-23-47','77040432894',13);
INSERT INTO Osoby VALUES(19,'Bogdan','Smole�',67,'wdowiec','+48607566845','42071556814',14);
INSERT INTO Osoby VALUES(20,'Lucyna','Piotrowska',28,'wolna',NULL,'81033174125',10);

INSERT INTO Klienci VALUES(1,1,0);
INSERT INTO Klienci VALUES(2,3,0);
INSERT INTO Klienci VALUES(3,5,0);
INSERT INTO Klienci VALUES(4,7,0);
INSERT INTO Klienci VALUES(5,9,0);
INSERT INTO Klienci VALUES(6,10,0);
INSERT INTO Klienci VALUES(7,12,0);
INSERT INTO Klienci VALUES(8,14,0);
INSERT INTO Klienci VALUES(9,16,0);
INSERT INTO Klienci VALUES(10,18,0);
INSERT INTO Klienci VALUES(11,20,0);
INSERT INTO Klienci VALUES(12,2,0);
INSERT INTO Klienci VALUES(13,4,0);
INSERT INTO Klienci VALUES(14,6,0);

INSERT INTO Stanowiska VALUES(1,'DYREKTOR','Kieruje ca�� firm�.');
INSERT INTO Stanowiska VALUES(2,'SPRZEDAWCA','Jego zadaniem jest sprzeda� artyku��w produkowanych w firmie, oraz dow�z sprz�tu.');
INSERT INTO Stanowiska VALUES(3,'SERWISANT','Jego zadaniem jest naprawa gwarancyjna sprz�tu sprzedawanego w firmie.');
INSERT INTO Stanowiska VALUES(4,'KONSULTANT','Jest to doradca klienta; Do jego obowi�zk�w nale�y r�wnie� obs�uga kredyt�w.');

INSERT INTO Pracownicy VALUES(1,8,1,8,8000);
INSERT INTO Pracownicy VALUES(2,11,2,6,3500);
INSERT INTO Pracownicy VALUES(3,13,2,5,3200);
INSERT INTO Pracownicy VALUES(4,15,3,5,5000);
INSERT INTO Pracownicy VALUES(5,17,3,3,4000);
INSERT INTO Pracownicy VALUES(6,19,4,2,2500);

INSERT INTO Uslugi VALUES(1,'Naprawa sprz�tu w serwisie',200);
INSERT INTO Uslugi VALUES(2,'Konsultacja',50);
INSERT INTO Uslugi VALUES(3,'Doradztwo w domu klienta',120);
INSERT INTO Uslugi VALUES(4,'Dow�z sprz�tu',300);
INSERT INTO Uslugi VALUES(5,'Sprzeda�',45);

INSERT INTO Zlecenia VALUES(1,1,5,5);
INSERT INTO Zlecenia VALUES(2,5,7,2);
INSERT INTO Zlecenia VALUES(3,3,3,6);
INSERT INTO Zlecenia VALUES(4,4,12,3);
INSERT INTO Zlecenia VALUES(5,1,8,5);
INSERT INTO Zlecenia VALUES(6,1,10,4);
INSERT INTO Zlecenia VALUES(7,2,7,6);
INSERT INTO Zlecenia VALUES(8,5,3,2);
INSERT INTO Zlecenia VALUES(9,4,2,2);
INSERT INTO Zlecenia VALUES(10,3,6,6);
INSERT INTO Zlecenia VALUES(11,2,8,6);
INSERT INTO Zlecenia VALUES(12,4,1,2);
INSERT INTO Zlecenia VALUES(13,4,11,3);
INSERT INTO Zlecenia VALUES(14,3,14,6);
INSERT INTO Zlecenia VALUES(15,3,3,6);
INSERT INTO Zlecenia VALUES(16,5,14,3);
INSERT INTO Zlecenia VALUES(17,4,13,3);
INSERT INTO Zlecenia VALUES(18,2,12,6);
INSERT INTO Zlecenia VALUES(19,2,11,6);
INSERT INTO Zlecenia VALUES(20,2,10,6);
INSERT INTO Zlecenia VALUES(21,3,9,6);
INSERT INTO Zlecenia VALUES(22,5,8,3);
INSERT INTO Zlecenia VALUES(23,1,7,4);
INSERT INTO Zlecenia VALUES(24,2,6,6);
INSERT INTO Zlecenia VALUES(25,2,5,6);
INSERT INTO Zlecenia VALUES(26,4,5,2);
INSERT INTO Zlecenia VALUES(27,5,4,2);
INSERT INTO Zlecenia VALUES(28,3,3,6);
INSERT INTO Zlecenia VALUES(29,3,2,6);
INSERT INTO Zlecenia VALUES(30,1,1,5);