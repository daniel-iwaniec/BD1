SELECT o.imie, o.nazwisko, a.miasto
FROM OSOBY o
JOIN ADRESY a ON (o.id_adresu = a.id_adresu)
WHERE a.miasto = 'Kielce';

SELECT o.imie, o.nazwisko, a.miasto
FROM ADRESY a
JOIN OSOBY o ON (a.id_adresu = o.id_adresu)
WHERE a.miasto = 'Kielce';

SELECT o.imie, o.nazwisko, s.opis
FROM OSOBY o
JOIN PRACOWNICY p ON (o.id_osoby = p.id_osoby)
JOIN STANOWISKA s ON (s.id_stanowiska = p.id_stanowiska)
JOIN ZLECENIA z ON (p.id_pracownika = z.id_pracownika)
JOIN KLIENCI k ON (z.id_klienta = k.id_klienta)
JOIN OSOBY ok ON (k.id_osoby = ok.id_osoby)
JOIN ADRESY a ON (ok.id_adresu = a.id_adresu)
WHERE a.miasto = 'Busko Zdrój';

SELECT o.imie, o.nazwisko, s.opis
FROM OSOBY o
JOIN PRACOWNICY p ON (o.id_osoby = p.id_osoby)
JOIN STANOWISKA s ON (s.id_stanowiska = p.id_stanowiska)
JOIN ZLECENIA z ON (p.id_pracownika = z.id_pracownika)
JOIN KLIENCI k ON (z.id_klienta = k.id_klienta)
JOIN OSOBY ok ON (k.id_osoby = ok.id_osoby)
JOIN ADRESY a ON (ok.id_adresu = a.id_adresu)
WHERE a.miasto LIKE 'Busko Zdrój';

SELECT o.imie, o.nazwisko, SUM(u.cena)
FROM OSOBY o
JOIN PRACOWNICY p ON (o.id_osoby = p.id_osoby)
JOIN ZLECENIA z ON (p.id_pracownika = z.id_pracownika)
JOIN USLUGI u ON (u.id_uslugi = z.id_uslugi)
GROUP BY o.imie, o.nazwisko;

SELECT o.imie, o.nazwisko, SUM(u.cena) AS "Dochód"
FROM OSOBY o
JOIN PRACOWNICY p ON (o.id_osoby = p.id_osoby)
JOIN ZLECENIA z ON (p.id_pracownika = z.id_pracownika)
JOIN USLUGI u ON (u.id_uslugi = z.id_uslugi)
GROUP BY o.imie, o.nazwisko
ORDER BY "Dochód" ASC;

SELECT a.miasto, COUNT(o.id_osoby) AS "Iloœæ osób", SUM(u.cena) AS "Zarobek"
FROM OSOBY o
JOIN ADRESY a ON (o.id_adresu = a.id_adresu)
JOIN KLIENCI k ON (o.id_osoby = k.id_osoby)
JOIN ZLECENIA z ON (k.id_klienta = z.id_klienta)
JOIN USLUGI u ON (z.id_uslugi = u.id_uslugi)
GROUP BY a.miasto
ORDER BY "Iloœæ osób" ASC;

SELECT a.miasto, COUNT(o.id_osoby) AS "Iloœæ osób", SUM(u.cena) AS "Zarobek"
FROM OSOBY o
JOIN ADRESY a ON (o.id_adresu = a.id_adresu)
JOIN KLIENCI k ON (o.id_osoby = k.id_osoby)
JOIN ZLECENIA z ON (k.id_klienta = z.id_klienta)
JOIN USLUGI u ON (z.id_uslugi = u.id_uslugi)
GROUP BY a.miasto
ORDER BY "Zarobek" DESC;

SELECT o.imie, o.nazwisko
FROM OSOBY o
JOIN KLIENCI k ON (o.id_osoby = k.id_osoby)
JOIN ZLECENIA z ON (k.id_klienta = z.id_klienta)
JOIN PRACOWNICY p ON (z.id_pracownika = p.id_pracownika)
JOIN STANOWISKA s ON (p.id_stanowiska = s.id_stanowiska)
WHERE s.nazwa = 'KONSULTANT'
GROUP BY o.imie, o.nazwisko
ORDER BY o.imie ASC;

SELECT o.imie, o.nazwisko
FROM OSOBY o
JOIN KLIENCI k ON (o.id_osoby = k.id_osoby)
JOIN ZLECENIA z ON (k.id_klienta = z.id_klienta)
JOIN PRACOWNICY p ON (z.id_pracownika = p.id_pracownika)
JOIN STANOWISKA s ON (p.id_stanowiska = s.id_stanowiska)
WHERE s.nazwa = 'KONSULTANT'
GROUP BY o.imie, o.nazwisko
ORDER BY o.nazwisko ASC;

SELECT ok.nazwisko, u.opis, u.cena
FROM OSOBY o
JOIN ADRESY a ON (o.id_adresu = a.id_adresu)
JOIN PRACOWNICY p ON (o.id_osoby = p.id_osoby)
JOIN ZLECENIA z ON (p.id_pracownika = z.id_pracownika)
JOIN KLIENCI k ON (k.id_klienta = z.id_klienta)
JOIN OSOBY ok ON (k.id_osoby = ok.id_osoby)
JOIN USLUGI u ON (z.id_uslugi = u.id_uslugi)
WHERE a.miasto = 'Kielce';

SELECT ok.nazwisko, u.opis, u.cena
FROM OSOBY o
JOIN ADRESY a ON (o.id_adresu = a.id_adresu)
JOIN PRACOWNICY p ON (o.id_osoby = p.id_osoby)
JOIN ZLECENIA z ON (p.id_pracownika = z.id_pracownika)
JOIN KLIENCI k ON (k.id_klienta = z.id_klienta)
JOIN OSOBY ok ON (k.id_osoby = ok.id_osoby)
JOIN USLUGI u ON (z.id_uslugi = u.id_uslugi)
WHERE a.miasto = 'Kielce'
ORDER BY u.cena ASC;