SELECT imie, nazwisko, wiek FROM OSOBY;

SELECT nazwisko, telefon FROM OSOBY ORDER BY nazwisko ASC;

SELECT imie, wiek FROM OSOBY ORDER BY wiek DESC;

SELECT ulica FROM adresy WHERE miasto = 'Kielce';

SELECT nazwisko, imie, telefon FROM OSOBY WHERE telefon IS NULL ORDER BY nazwisko ASC;

SELECT nazwisko, imie, telefon FROM OSOBY WHERE telefon IS NOT NULL ORDER BY imie DESC;

SELECT imie, nazwisko, wiek FROM OSOBY WHERE wiek > 30;

SELECT imie, nazwisko, wiek FROM OSOBY WHERE wiek < 40;

SELECT imie, nazwisko, wiek FROM OSOBY WHERE wiek >= 25 AND wiek <= 35;

SELECT nazwisko, imie FROM OSOBY WHERE nazwisko LIKE 'P%' OR nazwisko LIKE 'S%';

SELECT nazwisko, imie FROM OSOBY WHERE regexp_like(nazwisko, '^[A-K]{1}');

SELECT nazwisko, imie FROM OSOBY WHERE NOT regexp_like(nazwisko, '^[A-K]{1}');

SELECT imie, nazwisko, stan_cywilny FROM OSOBY WHERE stan_cywilny != 'wolny' AND stan_cywilny != 'wolna';

SELECT imie, nazwisko, pesel AS "Numer identyfikacyjny" FROM OSOBY;

SELECT nazwisko, imie, telefon, wiek FROM OSOBY WHERE nazwisko = 'Piotrowska' OR nazwisko = 'Piotrowski';

SELECT nazwisko, imie, wiek, telefon FROM OSOBY WHERE wiek > 30 AND telefon IS NULL;

SELECT nazwisko, imie, wiek, telefon FROM OSOBY WHERE wiek < 40 AND regexp_like(nazwisko, '^[P-S]{1}');

SELECT o.imie, o.nazwisko, a.miasto
FROM OSOBY o
JOIN ADRESY a ON (o.id_adresu = a.id_adresu)
WHERE a.miasto != 'Kielce';