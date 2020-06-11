1.
	CREATE DATABASE Laboratorium_Filmoteka;
	CREATE USER '244941'@'localhost';
	SET PASSWORD FOR '244941'@'localhost' = 'Pawel941'; -- PASSWORD()?
	GRANT INSERT,SELECT,UPDATE,DELETE ON *.* TO '244941'@'localhost';

2.
	CREATE TABLE aktorzy(
		id int NOT NULL AUTO_INCREMENT,
		imie varchar(44) NOT NULL,
		nazwisko varchar(44) NOT NULL,
		PRIMARY KEY(id)
	);
	
	CREATE TABLE filmy(
		id int NOT NULL AUTO_INCREMENT,
		title varchar(44) NOT NULL,
		gatunek varchar(20) NOT NULL,
		dlugosc int NOT NULL,
		kategoria varchar(10),
		PRIMARY KEY(id)
	);
	
	CREATE TABLE zagrali(
		aktor int NOT NULL,
		film int NOT NULL
	);
	
	INSERT INTO filmy(id, title, gatunek, dlugosc, kategoria)
		SELECT film.film_id, film.title, c.name, film.length, film.rating 
		FROM sakila.film film 
			JOIN sakila.film_category fc ON film.film_id = fc.film_id
				JOIN sakila.category c ON c.category_id = fc.category_id
		WHERE film.title NOT LIKE "%x%" AND film.title NOT LIKE "%v%" AND film.title NOT LIKE "%q%%";
	
	INSERT INTO aktorzy(id, imie, nazwisko)
		SELECT actor.actor_id, actor.first_name, actor.last_name 
		FROM sakila.actor actor
		WHERE actor.first_name NOT LIKE "%x%" AND actor.first_name NOT LIKE "%v%" AND actor.first_name NOT LIKE "%q%"
		AND actor.last_name NOT LIKE "%x%" AND actor.last_name NOT LIKE "%v%" AND actor.last_name NOT LIKE "%q%";
		
	INSERT INTO zagrali(aktor,film)
		SELECT fa.actor_id, fa.film_id
		FROM sakila.film_actor fa 
		WHERE fa.actor_id IN (SELECT id FROM aktorzy) AND fa.film_id IN (SELECT id FROM filmy);
	
3.
	ALTER TABLE aktorzy ADD ilosc_wystapien int;

	--INSERT INTO aktorzy (ilosc_wystapien)
	--	SELECT COUNT(film) FROM zagrali GROUP BY aktor;

	UPDATE aktorzy A JOIN (SELECT aktor, COUNT(film)AS liczba FROM zagrali GROUP BY aktor)Z ON A.id = Z.aktor
	SET A.ilosc_wystapien = Z.liczba;
	-- nie ma aktorow co by mieli < 4 wystapienia w filmach
	
4.
	CREATE TABLE Agenci (
		licencja varchar(30) NOT NULL ,
		nazwa varchar(90) NOT NULL,
		wiek int NOT NULL,
		typ set("osoba indywidualna","agencja","inny") NOT NULL,
		PRIMARY KEY(licencja)
	);
	
	 --INSERT INTO agenci VALUES ("#0001","Agent007",19,"inny");

		-- CHECK nie działa, dlatego procedura + 2 triggery
	
	
		DELIMITER $$
		CREATE PROCEDURE sprawdz_agenci (IN wiek int)
		BEGIN
			IF wiek < 21 THEN
				SIGNAL SQLSTATE '45000'
					SET MESSAGE_TEXT = 'Wiek musi byc > 20';
			END IF;
		END$$
		DELIMITER ;
		
		DELIMITER $$ 
		CREATE TRIGGER sprawdz_agenci_insert BEFORE INSERT ON Agenci
		FOR EACH ROW
		BEGIN
			CALL sprawdz_agenci(NEW.wiek);
		END$$
		DELIMITER ;
		
		DELIMITER $$ 
		CREATE TRIGGER sprawdz_agenci_update BEFORE UPDATE ON Agenci
		FOR EACH ROW
		BEGIN
			CALL sprawdz_agenci(NEW.wiek);
		END$$
		DELIMITER ;
		
		--/
	
	CREATE TABLE Kontrakty (
		ID int NOT NULL AUTO_INCREMENT,
		agent varchar(30) NOT NULL,
		aktor int NOT NULL,
		początek date NOT NULL,
		koniec date NOT NULL,
		gaża int unsigned NOT NULL,
		PRIMARY KEY(ID),
		FOREIGN KEY(agent) REFERENCES Agenci(licencja),
		FOREIGN KEY(aktor) REFERENCES Aktorzy(id)
	);
	
		DELIMITER $$
		CREATE TRIGGER sprawdz_kontrakty_update BEFORE UPDATE ON Kontrakty 
		FOR EACH ROW
		BEGIN
			IF NEW.początek > (DATE_SUB(NEW.koniec, INTERVAL 1 DAY)) THEN
				SIGNAL SQLSTATE '12345'
					SET MESSAGE_TEXT = 'Początek musi byc < niż koniec';
			END IF;
		END $$
		DELIMITER ;

		DELIMITER $$
		CREATE TRIGGER sprawdz_kontrakty_insert BEFORE INSERT ON Kontrakty 
		FOR EACH ROW
		BEGIN
			IF NEW.początek > (DATE_SUB(NEW.koniec, INTERVAL 1 DAY)) THEN
				SIGNAL SQLSTATE '12345'
					SET MESSAGE_TEXT = 'Początek musi byc < niż koniec';
			END IF;
		END $$
		DELIMITER ;

	--  INSERT INTO Kontrakty VALUES(1, "#0001", 1, "1998-03-03", "1998-03-02", 100);

5.

	DELIMITER $$
	
	DROP PROCEDURE IF EXISTS dodaj_agentow$$;
	CREATE PROCEDURE dodaj_agentow(IN ile INT)
	BEGIN
		DECLARE x INT;
		SET x = 1;
		WHILE x <= ile DO 
			INSERT INTO agenci VALUES (CONCAT('#',x,'#'),
			SUBSTRING(MD5(RAND()) FROM 1 FOR 7),
			FLOOR(RAND()*40 + 21), ELT(FLOOR(RAND()*3)+1,
			"osoba indywidualna","agencja","inny"));
			SET x = x + 1;
		END WHILE;
	END$$
	DELIMITER ;
	
	-- SET @typ = ELT(FLOOR(RAND()*3)+1,"osoba indywidualna","agencja","inny")  
	-- SUBSTRING(MD5(RAND()) FROM 1 FOR 5)  losowy ciag znakow 5
	
	DELIMITER $$
	DROP PROCEDURE IF EXISTS dodaj_kontrakty$$
	CREATE PROCEDURE dodaj_kontrakty()
	BEGIN
		SET @maxV=0,@num1=0, @num2=0;
		SELECT COUNT(id) INTO @maxV FROM aktorzy;
		
		INSERT INTO kontrakty(agent,aktor,początek,koniec,gaża) 
		SELECT t2.licencja,t1.id,ADDDATE(CURDATE(),FLOOR(RAND()*30)*-1 - 1),ADDDATE(CURDATE(),FLOOR(RAND()*30) + 1),FLOOR(RAND()*100)
		FROM (
			SELECT id, @num1:=@num1+1 AS num
			FROM aktorzy
		) AS t1
		INNER JOIN (
			SELECT licencja, @num2:=@num2+1 AS num
			FROM (
				SELECT licencja
				FROM agenci
				ORDER BY RAND()
			) AS t
				WHERE @num2 < @maxV
		) AS t2
		ON t1.num = t2.num;
			
	END$$
	DELIMITER ;


	--INSERT INTO kontrakty(agent,aktor,początek,koniec,gaża) 
	--SELECT Ag.licencja, Ak.id  FROM aktorzy Ak, (SELECT licencja FROM agenci ORDER BY RAND())Ag

6.

	DELIMITER $$
	DROP PROCEDURE IF EXISTS dodaj_archiwalne$$
	CREATE PROCEDURE dodaj_archiwalne()
	BEGIN
		SET @i = 0;
		WHILE @i < 30 
		DO
			SET @i = @i + 1;
			INSERT INTO kontrakty(agent,aktor,początek,koniec,gaża) 
			SELECT TAB.agent, TAB.id_aktor, ADDDATE(TAB.początek,FLOOR(RAND()*30)*-1 - 2), TAB.początek, FLOOR(RAND()*100)
			FROM
				(SELECT K.*,I.id_aktor FROM Kontrakty K,(SELECT id as id_aktor FROM Aktorzy ORDER BY RAND() LIMIT 1) I ORDER BY RAND() LIMIT 1) TAB;
				
		END WHILE;
	END$$
	DELIMITER ;

		--SELECT * FROM kontrakty k1 JOIN Kontrakty k2 ON k1.aktor = k2.aktor WHERE k1.początek <> k2.początek ;
		
		
7. 
		DELIMITER $$
		DROP PROCEDURE IF EXISTS znajdz_agenta_dla_aktora$$
		CREATE PROCEDURE znajdz_agenta_dla_aktora(IN imie VARCHAR(44), IN nazwisko VARCHAR(44))
		BEGIN
			SELECT AG.*,DATEDIFF(K.koniec,CURDATE()) AS DoKonca FROM 
				(SELECT id FROM aktorzy A WHERE A.imie = imie AND A.nazwisko = nazwisko) TAB
				JOIN kontrakty K 
				ON TAB.id = K.aktor
				JOIN agenci AG
				ON AG.licencja = K.agent;
		END$$
		DELIMITER ;

8.
	 
	DELIMITER $$
	DROP FUNCTION IF EXISTS oblicz_srednia_kontraktu;
	CREATE FUNCTION oblicz_srednia_kontraktu(licencja varchar(30))
	RETURNS FLOAT DETERMINISTIC
	BEGIN
		
		SET @val = 0;
		SELECT -1 INTO @val FROM kontrakty K WHERE k.agent = licencja LIMIT 1;
		
		IF @val = 0 THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Nie odnaleziono licencji";
		ELSE
			SET @a = -1.0;
			SELECT (K.gaża / DATEDIFF(K.koniec, K.początek)) INTO @a FROM kontrakty K 
			WHERE K.agent = licencja AND CURDATE() BETWEEN K.początek AND K.koniec; /* aktualny kontrakt */
			RETURN @a;
		END IF;
	END$$
	DELIMITER ;
	
9.
	SET @q = 'SELECT A.nazwa, COUNT(DISTINCT K.aktor) FROM kontrakty K JOIN agenci A ON K.agent = A.licencja WHERE A.nazwa = ?;';
	PREPARE stmt FROM @q;
	SET @i = '0066a15';
	EXECUTE stmt USING @i;
	DEALLOCATE PREPARE stmt;
		
	SET @q = 'SELECT A.nazwa, COUNT(DISTINCT K.aktor) FROM kontrakty K JOIN agenci A ON K.agent = A.licencja WHERE A.nazwa = ?;';
	PREPARE stmt FROM @q;
	SET @i = 'dff8d94';
	EXECUTE stmt USING @i;
	DEALLOCATE PREPARE stmt;
	
10. 

	DELIMITER $$
	DROP PROCEDURE IF EXISTS oldestAgent$$
	CREATE PROCEDURE oldestAgent()
	BEGIN
		
		SELECT agent INTO @licencjaV
			FROM Kontrakty
			WHERE DATEDIFF(CURDATE(), początek) = 
			(SELECT MAX( DATEDIFF(CURDATE(), początek)) FROM Kontrakty) LIMIT 1;
			--loop?
			
		SELECT nazwa INTO @nazwaV FROM agenci
			WHERE licencja = @licencjaV;
			
		SELECT wiek INTO @wiekV FROM agenci
			WHERE licencja = @licencjaV;
			
		SELECT typ INTO @typV FROM agenci
			WHERE licencja = @licencjaV;
	END $$
	
	DELIMITER ;
	
11.
	/*
		UPDATE
		INSERT
		DELETE
		! NOT NULL !
	*/
	
	DELIMITER $$
	CREATE TRIGGER On_Zagrali_Update BEFORE UPDATE ON zagrali
	FOR EACH ROW
	BEGIN
		IF NEW.aktor <> OLD.aktor THEN
			UPDATE aktorzy A
			SET A.ilosc_wystapien = A.ilosc_wystapien - 1
			WHERE A.id = OLD.aktor;		
			
			UPDATE aktorzy A
			SET A.ilosc_wystapien = A.ilosc_wystapien + 1		
			WHERE A.id = NEW.aktor;
		END IF;
	END$$
	DELIMITER ;
	
	DELIMITER $$
	CREATE TRIGGER On_Zagrali_INSERT BEFORE INSERT ON zagrali
	FOR EACH ROW
	BEGIN
		UPDATE aktorzy A
		SET A.ilosc_wystapien = A.ilosc_wystapien + 1		
		WHERE A.id = NEW.aktor;
	END$$
	DELIMITER ;
	
	DELIMITER $$
	CREATE TRIGGER On_Zagrali_Delete BEFORE DELETE ON zagrali
	FOR EACH ROW
	BEGIN
		UPDATE aktorzy A
		SET A.ilosc_wystapien = A.ilosc_wystapien - 1
		WHERE A.id = OLD.aktor;		
	END$$
	DELIMITER ;
	
12.

	DELIMITER $$
	DROP TRIGGER IF EXISTS On_Kontrakt_Insert_Before;
	CREATE TRIGGER On_Kontrakt_Insert_Before BEFORE INSERT ON kontrakty
	FOR EACH ROW
	BEGIN
		SET foreign_key_checks = 0;
		IF NOT czy_istnieje_agent(NEW.agent) THEN
			INSERT INTO agenci(licencja,nazwa,wiek,typ) VALUES(NEW.agent, "DUMMY", 25, "INNY" );
		END IF;
		SET foreign_key_checks = 1;
		/*
		IF czy_istnieje_aktor(NEW.aktor) THEN
			UPDATE kontrakty K
			SET K.koniec = ADDDATE(CURDATE(), -1)
			WHERE NEW.aktor = K.aktor AND CURDATE() BETWEEN K.początek AND K.koniec;
		END IF;
		*/
	END$$
	DELIMITER ;

	--INSERT INTO kontrakty(agent,aktor,początek,koniec,gaża) VALUES("XD",1,CURDATE(),ADDDATE(CURDATE(),5),100);

	DELIMITER $$
	DROP FUNCTION IF EXISTS czy_istnieje_agent;
	CREATE FUNCTION czy_istnieje_agent(wartosc varchar(30))
	RETURNS BOOLEAN DETERMINISTIC
	BEGIN
		SET @val = 0;
		SELECT COUNT(agent) INTO @val FROM kontrakty WHERE agent = wartosc;

		IF @val= 0 THEN
			RETURN FALSE;
		ELSE
			RETURN TRUE;
		END IF;
	END$$
	DELIMITER ;
	
	DELIMITER $$
	DROP FUNCTION IF EXISTS czy_istnieje_aktor;
	CREATE FUNCTION czy_istnieje_aktor(wartosc int)
	RETURNS BOOLEAN DETERMINISTIC
	BEGIN
		SET @val = 0;
		SELECT COUNT(aktor) INTO @val FROM kontrakty WHERE aktor = wartosc;

		IF @val= 0 THEN
			RETURN FALSE;
		ELSE
			RETURN TRUE;
		END IF;
	END$$
	DELIMITER ;
	
13.
	DELIMITER $$
	DROP TRIGGER IF EXISTS on_delete_film;
	CREATE TRIGGER on_delete_film BEFORE DELETE ON filmy
	FOR EACH ROW
	BEGIN
		DELETE FROM zagrali WHERE OLD.id = film;
	END$$
	DELIMITER ;
	
	-- Trigger w zagrali się odpali
	
14.
	-- Tylko aktorzy z akutalnym kontraktem?
	DROP VIEW Aktor_Agent;
	CREATE VIEW Aktor_Agent AS 
	SELECT Ak.imie,Ak.nazwisko,Ag.nazwa,DATEDIFF(K.koniec,CURDATE())
	FROM aktorzy Ak JOIN kontrakty K ON Ak.id = K.aktor 
	JOIN agenci Ag ON K.agent = Ag.licencja
	WHERE CURDATE() BETWEEN K.początek AND K.koniec;
	-- Uzytkownik widzi
	-- Uzytkownik nie może usunąc i nie może utworzyc
	
15.

--znajdz_agenta_dla_aktora
--oblicz_srednia_kontraktu
--oldestAgent

	DROP FUNCTION IF EXISTS licence();
	CREATE FUNCTION licence() RETURNS VARCHAR(30) DETERMINISTIC NO SQL RETURN @licencjaV;

	DROP VIEW PubliczniAgenci;
	CREATE VIEW PubliczniAgenci AS
	SELECT nazwa,wiek FROM AGENCI WHERE licencja = licence();
	
	DROP VIEW PubliczniAktorzy;
	CREATE VIEW PubliczniAktorzy AS
	SELECT imie,nazwisko FROM aktorzy WHERE ilosc_wystapien < 13;
	
	DROP VIEW NieznaneFilmy;
	CREATE VIEW NieznaneFilmy AS
	SELECT F.title, F.dlugosc FROM PubliczniAktorzy PA JOIN aktorzy A ON PA.imie = A.imie AND PA.nazwisko = A.nazwisko
	JOIN Zagrali Z ON A.id = Z.aktor JOIN Filmy F ON Z.film = F.id;
	
	
	CREATE USER 'test'@'localhost';
	SET PASSWORD FOR 'test'@'localhost' = '1234'; -- PASSWORD()?
	GRANT SHOW VIEW ON *.* TO 'test'@'localhost';
	
	GRANT SELECT ON laboratorium_filmoteka.PubliczniAgenci TO 'test'@'localhost';
	GRANT SELECT ON laboratorium_filmoteka.PubliczniAktorzy TO 'test'@'localhost';
	GRANT SELECT ON laboratorium_filmoteka.NieznaneFilmy TO 'test'@'localhost';

	--Nie może uzywac funkcji i procedur
	--Denied execute
	
	
	
	
	
	