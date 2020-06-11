1. 
	--SHOW INDEX FROM <table>;
	ALTER TABLE filmy ADD INDEX tytuly (title);
	
	ALTER TABLE aktorzy ADD INDEX nazwa (nazwisko, imie(1));
	
	ALTER TABLE zagrali ADD INDEX glowny (aktor); -- ?

2.
	ALTER TABLE kontrakty ADD INDEX idx_koniec USING BTREE (koniec);
	
	SELECT A.* FROM kontrakty K  JOIN aktorzy A ON K.aktor = A.id 
	WHERE K.koniec BETWEEN "2018.12.01" AND "2018.12.31";
	-- BTREE := O(log(n)) vs HASH := O(n) in BETWEEN
	
3.
	SELECT imie FROM aktorzy WHERE imie LIKE "J%"; -- Nie, musialoby byc nazwisko (LEFT)
	
	SELECT nazwisko FROM aktorzy WHERE ilosc_wystapien >= 12; -- Nie
	
	SELECT Z2.* FROM zagrali Z1 JOIN 
	(SELECT * FROM zagrali WHERE aktor = 
		(SELECT id FROM aktorzy WHERE imie = "Zero" AND nazwisko = "Cage") -- Przy nazwisku
	)Z2
	ON Z1.film = Z2.film AND Z1.aktor <> Z2.aktor; -- Tutaj
	
	
	SELECT AK.* FROM aktorzy AK JOIN 
		(SELECT A.aktor FROM (SELECT aktor, ((CURDATE()-koniec) * -1) as dokonca
		FROM kontrakty WHERE koniec > CURDATE())A -- Indeks
		WHERE A.dokonca =                                                         -- Indeks
			(SELECT MIN((CURDATE()-koniec) * -1) as dokonca FROM kontrakty WHERE koniec > CURDATE())
		) TAB 
	ON AK.id = TAB.aktor;
	
	SELECT A.imie FROM(SELECT imie, COUNT(imie) AS liczba FROM aktorzy GROUP BY imie)A
	WHERE A.liczba = (SELECT MAX(B.liczba) FROM  
	(SELECT imie, COUNT(imie) AS liczba FROM aktorzy GROUP BY imie)B);
	-- Bez indeksow
	
4.
	CREATE DATABASE laboratorium_firma;
	
	CREATE TABLE Ludzie (
		PESEL CHAR(11) NOT NULL,
		imie VARCHAR(30) NOT NULL,
		nazwisko VARCHAR(30) NOT NULL,
		data_urodzenia DATE NOT NULL,
		wzrost FLOAT,
		waga FLOAT,
		rozmiarbuta INT unsigned,
		ulubionykolor SET('czarny','czerwony','zielony','niebieski','bialy'),
		PRIMARY KEY(PESEL)
	);
	
	--INSERT INTO Ludzie VALUES("19980909099","Jan","Kowalski","1998-09-09",180,80,44,'czarny');
	
	DELIMITER $$ 
	DROP TRIGGER IF EXISTS sprawdz_ludzie_insert;
	CREATE TRIGGER sprawdz_ludzie_insert BEFORE INSERT ON Ludzie
	FOR EACH ROW
	BEGIN
		IF NEW.wzrost < 0.0 THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = 'Wzrost musi byc > 0.0';
		END IF;
		
		IF NEW.waga < 0.0 THEN
			SIGNAL SQLSTATE '45001'
				SET MESSAGE_TEXT = 'Waga musi byc > 0.0';
		END IF;
		
			SET @pesel_test = CONVERT(NEW.PESEL, SIGNED);
		
		IF CHAR_LENGTH(CONVERT(@pesel_test,SIGNED)) <> 11 THEN
			SIGNAL SQLSTATE '45002'
				SET MESSAGE_TEXT = 'Pesel musi byc liczba';
		END IF;
		
			SET @pesel_data = DATE(STR_TO_DATE(MID(NEW.PESEL,1,8),"%Y %c %d"));
		
		IF @pesel_data IS NULL THEN
			SIGNAL SQLSTATE '45003'
				SET MESSAGE_TEXT = '8 cyfr peselu musi oznaczac date';
		END IF;
		
		IF @pesel_data <> NEW.data_urodzenia THEN
			SIGNAL SQLSTATE '45004'
				SET MESSAGE_TEXT = 'pesel nie zgadza sie z data urodzenia';
		END IF;
		
	END$$
	DELIMITER ;
	
	DELIMITER $$ 
	DROP TRIGGER IF EXISTS sprawdz_ludzie_update;
	CREATE TRIGGER sprawdz_ludzie_update BEFORE UPDATE ON Ludzie
	FOR EACH ROW
	BEGIN
		IF NEW.wzrost < 0.0 THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = 'Wzrost musi byc > 0.0';
		END IF;
		
		IF NEW.waga < 0.0 THEN
			SIGNAL SQLSTATE '45001'
				SET MESSAGE_TEXT = 'Waga musi byc > 0.0';
		END IF;
		
			SET @pesel_test = CONVERT(NEW.PESEL, SIGNED);
		
		IF CHAR_LENGTH(CONVERT(@pesel_test,SIGNED)) <> 11 THEN
			SIGNAL SQLSTATE '45002'
				SET MESSAGE_TEXT = 'Pesel musi byc liczba';
		END IF;
		
			SET @pesel_data = DATE(STR_TO_DATE(MID(NEW.PESEL,1,8),"%Y %c %d"));
		
		IF @pesel_data IS NULL THEN
			SIGNAL SQLSTATE '45003'
				SET MESSAGE_TEXT = '8 cyfr peselu musi oznaczac date';
		END IF;
		
		IF @pesel_data <> NEW.data_urodzenia THEN
			SIGNAL SQLSTATE '45004'
				SET MESSAGE_TEXT = 'pesel nie zgadza sie z data urodzenia';
		END IF;
		
	END$$
	DELIMITER ;
	
	
	CREATE TABLE Pracownicy (
		PESEL CHAR(11) NOT NULL,
		zawod VARCHAR(50) NOT NULL,
		pensja FLOAT NOT NULL,
		PRIMARY KEY(PESEL)
	);
	
	DELIMITER $$
	DROP FUNCTION IF EXISTS wiek_dlapesel;
	CREATE FUNCTION wiek_dlapesel(peselV char(11))
	RETURNS INTEGER DETERMINISTIC
	BEGIN
		DECLARE wiekV INT;
		DECLARE dateV DATE;
		SET dateV = DATE(STR_TO_DATE(MID(peselV,1,8),"%Y %c %d"));
		IF dateV IS NULL THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = 'pesel must be valid date';
		END IF;
		
		SELECT (YEAR(CURDATE()) - YEAR(dateV)) INTO wiekV;
		
		RETURN wiekV;
	END$$
	DELIMITER ;
	
	--INSERT INTO pracownicy VALUES ('11119999099',"gracz",1);
	DELIMITER $$ 
	DROP TRIGGER IF EXISTS sprawdz_pracownicy_insert;
	CREATE TRIGGER sprawdz_pracownicy_insert BEFORE INSERT ON pracownicy
	FOR EACH ROW
	BEGIN
		
		IF NEW.pensja < 0.0 THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = 'Pensja musi byc > 0.0';
		END IF;
		
		IF wiek_dlapesel(NEW.PESEL) < 18 THEN
			SIGNAL SQLSTATE '45001'
				SET MESSAGE_TEXT = "Pracownik musi byc pelnoletni";
		END IF;
		
		SET @pesel_test = CONVERT(NEW.PESEL, SIGNED);
		
		IF CHAR_LENGTH(CONVERT(@pesel_test,SIGNED)) <> 11 THEN
			SIGNAL SQLSTATE '45002'
				SET MESSAGE_TEXT = 'Pesel musi byc liczba';
		END IF;
		
		SET @pesel_data = DATE(STR_TO_DATE(MID(NEW.PESEL,1,8),"%Y %c %d"));

		IF @pesel_data IS NULL THEN
			SIGNAL SQLSTATE '45003'
				SET MESSAGE_TEXT = '8 cyfr peselu musi oznaczac date';
		END IF;
		
	END$$
	DELIMITER ;
	
	DELIMITER $$ 
	DROP TRIGGER IF EXISTS sprawdz_pracownicy_update;
	CREATE TRIGGER sprawdz_pracownicy_update BEFORE UPDATE ON pracownicy
	FOR EACH ROW
	BEGIN
		
		IF NEW.pensja < 0.0 THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = 'Pensja musi byc > 0.0';
		END IF;
		
		IF wiek_dlapesel(NEW.PESEL) < 18 THEN
			SIGNAL SQLSTATE '45001'
				SET MESSAGE_TEXT = "Pracownik musi byc pelnoletni";
		END IF;
		
		SET @pesel_test = CONVERT(NEW.PESEL, SIGNED);
		
		IF CHAR_LENGTH(CONVERT(@pesel_test,SIGNED)) <> 11 THEN
			SIGNAL SQLSTATE '45002'
				SET MESSAGE_TEXT = 'Pesel musi byc liczba';
		END IF;
		
		SET @pesel_data = DATE(STR_TO_DATE(MID(NEW.PESEL,1,8),"%Y %c %d"));

		IF @pesel_data IS NULL THEN
			SIGNAL SQLSTATE '45003'
				SET MESSAGE_TEXT = '8 cyfr peselu musi oznaczac date';
		END IF;
		
	END$$
	DELIMITER ;
	
	DELIMITER $$
	DROP FUNCTION IF EXISTS randomPesel;
	CREATE FUNCTION randomPesel(minimum INT, zasieg INT)
	RETURNS CHAR(11) DETERMINISTIC
	BEGIN
		DECLARE yearV INT;
		DECLARE monthV INT;
		DECLARE dayV INT;
		DECLARE lastDigits INT;
		
		SET yearV = FLOOR(RAND()*zasieg) + minimum;
		SET monthV = FLOOR(RAND()*12) + 1;
		SET dayV = FLOOR(RAND()*31) + 1;
		WHILE DATE(CONVERT(CONCAT(yearV,LPAD(monthV,2,'0'),LPAD(dayV,2,'0')),DATE)) IS NULL DO
			SET dayV = (dayV - 1);
		END WHILE;
		SET lastDigits = FLOOR(RAND()*1000);
		
		RETURN CONCAT(yearV,LPAD(monthV,2,'0'),LPAD(dayV,2,'0'),LPAD(lastDigits,3,'0'));
	END$$
	DELIMITER ;
	
	
	--SUBSTRING(MD5(RAND()) FROM 1 FOR 7)
	--DATE(STR_TO_DATE(MID(NEW.PESEL,1,8),"%Y %c %d")
	
	DELIMITER $$
	DROP PROCEDURE IF EXISTS dodaj_ludzi;
	CREATE PROCEDURE dodaj_ludzi(IN ile INT)
	BEGIN
		DECLARE x INT;
		SET x = 1;
		WHILE x <= ile DO 
			SET @peselV = randomPesel(1950,52);
			INSERT INTO ludzie VALUES (@peselV,
			ELT(FLOOR(RAND()*5)+1, "Jan","Andrzej","Mikolaj","Natalia","Julia"),
			ELT(FLOOR(RAND()*5)+1, "Andrychowicz","Kuzniewicz","Biegun","Heban","Strzelec"),
			DATE(STR_TO_DATE(MID(@peselV,1,8),"%Y %c %d")),
			(RAND()*30 + 160),
			(RAND()*30 + 55),
			(FLOOR(RAND()*6) + 38),
			ELT(FLOOR(RAND()*5)+1, "czarny","czerwony","zielony","niebieski","bialy"));
			SET x = x + 1;
		END WHILE;
	END$$
	DELIMITER ;
	
	DELIMITER $$
	DROP PROCEDURE IF EXISTS przydziel_zawody;
	CREATE PROCEDURE przydziel_zawody()
	BEGIN
		DECLARE done INT DEFAULT FALSE;
		DECLARE x INT;
		DECLARE minWage INT DEFAULT 14000;
		DECLARE wage INT;
		DECLARE pesel_var CHAR(11);
		DECLARE cur1 CURSOR FOR SELECT PESEL FROM Ludzie ORDER BY RAND();
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
	
		OPEN cur1;
		
		SET minWage = RAND() * 12000 + 2000;
		SET x = 1;
		WHILE x <= 13 DO
			IF done THEN
			SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'Niepawidwola tabela Ludzie';
			END IF;
			
			SET wage = RAND() * 12000 + 2000;
			IF NOT (wage > minWage * 3) THEN
				FETCH cur1 INTO pesel_var;

				IF wiek_dlapesel(pesel_var) >= 18 THEN					
					IF wage < minWage THEN
						SET wage = minWage;
					END IF;

					INSERT INTO pracownicy VALUES (pesel_var, "informatyk", wage);
					SET x = x + 1;
				END IF;
			END IF;
		END WHILE;
		
		SET x = 1;
		WHILE x <= 2 DO
			IF done THEN
				SIGNAL SQLSTATE '45002' SET MESSAGE_TEXT = 'Niepawidwola tabela Ludzie';
			END IF;
			
			FETCH cur1 INTO pesel_var;
			IF wiek_dlapesel(pesel_var) >= 18 THEN
				SET wage = RAND() * 8000 + 4000;
				INSERT INTO pracownicy VALUES (pesel_var, "reporter", wage);
				SET x = x + 1;
			END IF;
		END WHILE;
		
		SET x = 1;
		WHILE x <= 33 DO
			IF done THEN
				SIGNAL SQLSTATE '45003' SET MESSAGE_TEXT = 'Niepawidwola tabela Ludzie';
			END IF;
		
			FETCH cur1 INTO pesel_var;
			IF wiek_dlapesel(pesel_var) >= 18 THEN
				SET wage = RAND() * 9000 + 5000;
				INSERT INTO pracownicy VALUES (pesel_var, "agent", wage);
				SET x = x + 1;
			END IF;
		END WHILE;
			
		
		SET x = 1;
		WHILE x <= 50 DO
			IF done THEN
				SIGNAL SQLSTATE '45004' SET MESSAGE_TEXT = 'Niepawidwola tabela Ludzie';
			END IF;
		
			FETCH cur1 INTO pesel_var;
			IF wiek_dlapesel(pesel_var) >= 18 THEN
				SET wage = RAND() * 12000 + 3000;
				INSERT INTO pracownicy VALUES (pesel_var, "aktor", wage);
				SET x = x + 1;
			END IF;
			
		END WHILE;
		
		SET x = 1;
		WHILE x <= 77 DO
			IF done THEN
				SIGNAL SQLSTATE '45005' SET MESSAGE_TEXT = 'Niepawidwola tabela Ludzie';
			END IF;
			
			FETCH cur1 INTO pesel_var;
			IF wiek_dlapesel(pesel_var) < 65 OR wiek_dlapesel(pesel_var) >= 18 THEN
				SET wage = RAND() * 4000 + 1500;
				INSERT INTO pracownicy VALUES (pesel_var, 'sprzedawca', wage);
				SET x = x + 1;
			END IF;
			
		END WHILE;
		CLOSE cur1;
	END$$
	DELIMITER ;
	
5.	
	-- SQL INJECTION PREVENTION CHEAT SHEET
	-- 1. Prepared statment with parametrized queries
	-- 2. Use of stored procedures
	-- 3. While list input validation
	-- 4. Escaping all user supplied input
	DELIMITER $$
	DROP PROCEDURE IF EXISTS aggregat_kolumna;
	CREATE PROCEDURE aggregat_kolumna(IN agg VARCHAR(10), IN kol VARCHAR(15))
	BEGIN
		IF(agg <> "MAX" AND agg <> "MIN" AND agg <> "SUM" AND agg <> "AVG") THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "agg should be one of these:[MAX,MIN,SUM,AVG]";
		END IF;
		
		SET @agg_prep = agg;
		SET @kol_prep = kol;
		SET @str = CONCAT("SELECT ", @agg_prep, "(", @kol_prep, ") INTO @x_prep FROM Ludzie;");
		PREPARE stmt FROM @str;
		EXECUTE stmt;
		
		DEALLOCATE PREPARE stmt;
		
		SET @str2 = CONCAT("SELECT @kol_prep AS kol, @agg_prep AS agg, @x_prep AS X");
		PREPARE stmt2 FROM @str2;
		EXECUTE stmt2;
		
		DEALLOCATE PREPARE stmt2;
	END$$
	
	DELIMITER ;
	
6.
	DELIMITER $$
	DROP PROCEDURE IF EXISTS wyplata;
	CREATE PROCEDURE wyplata(IN zawod VARCHAR(50), IN budzet INT)
	BEGIN
		DECLARE done INT DEFAULT FALSE;
		DECLARE suma INT DEFAULT 0;
		DECLARE pensja_var INT;
		DECLARE pesel_var CHAR(11);
		DECLARE cur1 CURSOR FOR SELECT P.pesel, P.pensja FROM pracownicy P WHERE P.zawod = zawod;
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
		
		IF(zawod <> "informatyk" AND zawod <> "aktor" AND zawod <> "agent" AND zawod <> "reporter" AND zawod <> "sprzedawca") THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "zawod should be one of these:[informatyk, aktor, agent, reporter, sprzedawca]";
		END IF; 

		CREATE TABLE temp ( pesel3 CHAR(3) );
		
		OPEN cur1;
		SET autocommit=0;
		START TRANSACTION;
			
			WHILE done = FALSE DO
				FETCH cur1 INTO pesel_var, pensja_var;
				SET budzet = budzet - pensja_var;
				INSERT INTO temp VALUES(SUBSTRING(pesel_var, 9, 3));
				
				IF budzet < 0 THEN
					ROLLBACK;
				END IF;
			
			END WHILE;
			
			SELECT LPAD(pesel3,11,'*') AS pesel,"Wyplacono" FROM temp;
		COMMIT;
		
		CLOSE cur1;
		DROP TABLE temp;
	END$$
	DELIMITER ;

7.
	DELIMITER $$
	DROP PROCEDURE IF EXISTS suma_kolumny;
	CREATE PROCEDURE suma_kolumny(IN kolumna VARCHAR(15), IN zawod VARCHAR(50), IN priv FLOAT)
	BEGIN
		IF(zawod <> "informatyk" AND zawod <> "aktor" AND zawod <> "agent" AND zawod <> "reporter" AND zawod <> "sprzedawca") THEN
			SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = "zawod should be one of these:[informatyk, aktor, agent, reporter, sprzedawca]";
		END IF;
		SET @zaw = zawod;
		SET @kol = kolumna;
		
		IF kolumna = "pensja" THEN
			SET @inital = 0;
			SET @q = CONCAT("SELECT SUM(pensja) INTO @inital FROM pracownicy WHERE zawod = ?");
			PREPARE stmt from @q;
			EXECUTE stmt using @zaw;
			DEALLOCATE PREPARE stmt;
			
			SET @maksi = 0;
			SET @mini= 0;
			SET @q1 = CONCAT('SELECT MAX(pensja) INTO @maksi FROM pracownicy P WHERE P.zawod = ?');
			PREPARE stmtq1 FROM @q1;
			SET @q2 = CONCAT('SELECT MIN(pensja) INTO @mini FROM pracownicy P WHERE P.zawod = ?');
			PREPARE stmtq2 FROM @q2;
			EXECUTE stmtq1 USING @zaw;
			EXECUTE stmtq2 USING @zaw;
			DEALLOCATE PREPARE stmtq2;
			DEALLOCATE PREPARE stmtq1;
			
			SET @ran = 0;
			SET @q = CONCAT("SELECT pensja INTO @ran FROM pracownicy P
			WHERE P.zawod = ? ORDER BY RAND() LIMIT 1");
			PREPARE stmt FROM @q;
			EXECUTE stmt USING @ran;
			
			SET @b = 2*(@maksi - @mini) / priv;
			SET @final = 1/(2*@b) * EXP(-@ran/@b);
			
			SELECT @inital + @final;
			
		ELSEIF kolumna = "waga" OR kolumna = "wzrost" OR kolumna = "imie" THEN
			SET @inital = 0;
			SET @q = CONCAT("SELECT SUM( L.", @kol," ) INTO @inital FROM pracownicy P JOIN Ludzie L ON P.PESEL = L.PESEL WHERE P.zawod = ?");
			PREPARE stmt2 FROM @q;
			EXECUTE stmt2 USING @zaw;
			DEALLOCATE PREPARE stmt2;
				
			SET @maksi = 0;
			SET @mini= 0;
			SET @q1 = CONCAT('SELECT MAX(L.', @kol, ') INTO @maksi FROM ludzie L JOIN pracownicy P ON L.pesel = P.pesel WHERE P.zawod = ?');
			PREPARE stmtq1 FROM @q1;
			SET @q2 = CONCAT('SELECT MIN(L.', @kol, ') INTO @mini FROM ludzie L JOIN pracownicy P ON L.pesel = P.pesel WHERE P.zawod = ?');
			PREPARE stmtq2 FROM @q2;
			
			EXECUTE stmtq1 USING @zaw;
			EXECUTE stmtq2 USING @zaw;
			DEALLOCATE PREPARE stmtq2;
			DEALLOCATE PREPARE stmtq1;
			
			SET @ran = 0;
			SET @q = CONCAT("SELECT L.", @kol," INTO @ran FROM pracownicy P
			JOIN Ludzie L ON P.PESEL = L.PESEL WHERE P.zawod = ? ORDER BY RAND() LIMIT 1");
			PREPARE stmt2 FROM @q;
			EXECUTE stmt2 USING @ran;
			
			SET @b = 2*(@maksi-@mini) / priv;
			SET @final = 1/(2*@b) * EXP(-@ran/@b);
			
			SELECT @inital + @final;
		
		ELSE SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "kolumna should be one of these:{wzrost,waga,pensja}";

		END IF;
		
		SET @inital = 0;
	END$$
	DELIMITER ;

8.
	CREATE DATABASE logs;
	CREATE TABLE logPensja (Old_val TEXT, New_val TEXT,changeDate DATETIME, user VARCHAR(60));

	DELIMITER $$
	DROP TRIGGER IF EXISTS log_pracownicy;
	CREATE TRIGGER log_pracownicy AFTER UPDATE ON pracownicy 
	FOR EACH ROW
	BEGIN
		IF(OLD.pensja <> NEW.pensja) THEN
			INSERT INTO logs.logPensja VALUES(CONCAT(OLD.pesel,", ", OLD.zawod,", ", OLD.pensja),
			CONCAT(NEW.pesel,", ", NEW.zawod,", ", NEW.pensja), NOW(), USER());
		END IF;
	END $$
	DELIMITER ;
	
		DELIMITER $$
	DROP TRIGGER IF EXISTS log_pracownicy_insert;
	CREATE TRIGGER log_pracownicy_insert AFTER INSERT ON pracownicy 
	FOR EACH ROW
	BEGIN
			INSERT INTO logs.logPensja VALUES(CONCAT("INSERT"),
			CONCAT(NEW.pesel,", ", NEW.zawod,", ", NEW.pensja), NOW(), USER());
	END $$
	DELIMITER ;
	
		DELIMITER $$
	DROP TRIGGER IF EXISTS log_pracownicy_delete;
	CREATE TRIGGER log_pracownicy_delete AFTER DELETE ON pracownicy 
	FOR EACH ROW
	BEGIN
			INSERT INTO logs.logPensja VALUES(CONCAT(OLD.pesel,", ", OLD.zawod,", ", OLD.pensja),
			CONCAT("DELETE"), NOW(), USER());
	END $$
	DELIMITER ;
	--UPDATE pracownicy SET pensja = 1800 WHERE pesel = '20001229750';
9.
