CREATE DATABASE `JSOPDB`;

CREATE TABLE `Przystanek` (
	`ID_Przystanek` INT NOT NULL AUTO_INCREMENT,
	`Nazwa` VARCHAR(44) NOT NULL,
	PRIMARY KEY (`ID_Przystanek`)
)
COMMENT='Fizyczny przystanek'
COLLATE='utf8_polish_ci'
ENGINE=InnoDB;

CREATE TABLE `Linia` (
	`ID_Linia` INT NOT NULL,
	PRIMARY KEY (`ID_Linia`)
)
COMMENT='Pomocniczy zbiór dla okrleślenia tras.'
COLLATE='utf8_polish_ci'
ENGINE=InnoDB;

CREATE TABLE `Trasa` (
	`ID_Trasa` INT NOT NULL,
	`ID_Linia` INT NOT NULL,
	`ID_Początek` INT NOT NULL,
	`ID_Koniec` INT NOT NULL,
	PRIMARY KEY (`ID_Trasa`),
	CONSTRAINT `FK__linia` FOREIGN KEY (`ID_Linia`) REFERENCES `linia` (`ID_Linia`),
	CONSTRAINT `FK__przystanek1` FOREIGN KEY (`ID_Początek`) REFERENCES `przystanek` (`ID_Przystanek`),
	CONSTRAINT `FK__przystanek2` FOREIGN KEY (`ID_Koniec`) REFERENCES `przystanek` (`ID_Przystanek`)
)
COLLATE='utf8_polish_ci'
ENGINE=InnoDB
;

CREATE TABLE `Przejazd` (
	`ID_Przejazd` INT NOT NULL AUTO_INCREMENT,
	`PrzystanekA` INT NOT NULL,
	`PrzystanekB` INT NOT NULL,
	`ID_Trasa` INT NOT NULL,
	PRIMARY KEY (`ID_Przejazd`),
	CONSTRAINT `FK__przystanek` FOREIGN KEY (`PrzystanekA`) REFERENCES `przystanek` (`ID_Przystanek`),
	CONSTRAINT `FK__przystanek_2` FOREIGN KEY (`PrzystanekB`) REFERENCES `przystanek` (`ID_Przystanek`),
	CONSTRAINT `FK__trasa` FOREIGN KEY (`ID_Trasa`) REFERENCES `trasa` (`ID_Trasa`) 
)
COLLATE='utf8_polish_ci'
ENGINE=InnoDB
;

CREATE TABLE `Terminarz` (
	`ID_Terminarz` INT(11) NOT NULL AUTO_INCREMENT,
	`ID_Przejazd` INT(11) NOT NULL,
	`Przyjazd` TIME NULL DEFAULT NULL,
	`Odjazd` TIME NULL DEFAULT NULL,
	PRIMARY KEY (`ID_Terminarz`),
	INDEX `FK__przejazd` (`ID_Przejazd`),
	CONSTRAINT `FK__przejazd` FOREIGN KEY (`ID_Przejazd`) REFERENCES `przejazd` (`ID_Przejazd`)
)
COLLATE='utf8_polish_ci'
ENGINE=InnoDB
;

CREATE TABLE `Kierowca` (
	`ID_Kierowca` INT NOT NULL AUTO_INCREMENT,
	`Nazwa` VARCHAR(44) NULL DEFAULT NULL,
	PRIMARY KEY (`ID_Kierowca`)
)
COLLATE='utf8_polish_ci'
ENGINE=InnoDB
;

CREATE TABLE `Pojazd` (
	`ID_Pojazd` INT NOT NULL AUTO_INCREMENT,
	`Typ` VARCHAR(44) NULL,
	PRIMARY KEY (`ID_Pojazd`)
)
COLLATE='utf8_polish_ci'
ENGINE=InnoDB
;

CREATE TABLE `Przypisania` (
	`ID_Przypisanie` INT NOT NULL AUTO_INCREMENT,
	`ID_Terminarz` INT NOT NULL,
	`ID_Kierowca` INT NULL,
	`ID_Pojazd` INT NULL,
	PRIMARY KEY (`ID_Przypisanie`),
	CONSTRAINT `FK__terminarz` FOREIGN KEY (`ID_Terminarz`) REFERENCES `terminarz` (`ID_Terminarz`),
	CONSTRAINT `FK__kierowca` FOREIGN KEY (`ID_Kierowca`) REFERENCES `kierowca` (`ID_Kierowca`),
	CONSTRAINT `FK__pojazd` FOREIGN KEY (`ID_Pojazd`) REFERENCES `pojazd` (`ID_Pojazd`)
)
COLLATE='utf8_polish_ci'
ENGINE=InnoDB
;


DELIMITER &&
CREATE PROCEDURE Select_TrasaStandardFormat()
BEGIN
	SELECT A.ID_Trasa, A.Nazwa AS Początek, B.Nazwa AS Koniec
	FROM (SELECT ID_Trasa, Nazwa FROM trasa JOIN przystanek ON ID_Początek = ID_Przystanek) A JOIN (SELECT ID_Trasa, Nazwa FROM trasa JOIN przystanek ON ID_Koniec = ID_Przystanek) B
	ON A.ID_Trasa = B.ID_Trasa ;
END&&
DELIMITER ;

DELIMITER &&
CREATE PROCEDURE Select_Terminarz(IN przystanek VARCHAR(44), IN czas TIME, IN linia INT)
BEGIN

	SET @str = CONCAT("SELECT Ter.przyjazd, Ter.odjazd, Ter.linia FROM Przejazd P JOIN Trasa T ON p.ID_Trasa = T.ID_Trasa JOIN 
		Terminarz Ter ON Ter.ID_Przejazd = P.ID_Przejazd JOIN Przystanek Prz 
        ON P.przystanekA = Prz.ID_Przystanek AND Prz.nazwa = \'",
	 przystanek, "\' WHERE T.ID_Linia = \'", linia, "\'; ");
	PREPARE stmt FROM @str;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END&&
DELIMITER ;


DELIMITER &&
CREATE PROCEDURE Select_CzasJazdy(IN początek VARCHAR(44), IN koniec VARCHAR(44))
BEGIN
	SET @str = CONCAT(	"SELECT TIMEDIFF(przyjazd, odjazd) FROM (
			(SELECT odjazd, ID_Trasa FROM  
			(SELECT ID_Przejazd,ID_Trasa FROM 
			(SELECT ID_Przystanek FROM Przystanek WHERE nazwa = \'", początek,"\') A 
				JOIN Przejazd P
				ON P.PrzystanekA = A.ID_Przystanek) Prz1
				JOIN Terminarz Ter
			 	ON Prz1.ID_Przejazd = Ter.ID_Przejazd) T1 
				JOIN 
			(SELECT przyjazd, ID_Trasa FROM 
			(SELECT ID_Przejazd,ID_Trasa FROM 
			(SELECT ID_Przystanek FROM Przystanek WHERE nazwa = \'", koniec,"\') B 
				JOIN Przejazd P2
				ON P2.PrzystanekA = B.ID_Przystanek) Prz2 
				JOIN Terminarz Ter2 
				ON Prz2.ID_Przejazd = Ter2.ID_Przejazd) T2 ON T1.ID_Trasa = T2.ID_Trasa AND przyjazd > odjazd
		) ");
	PREPARE stmt FROM @str;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END&&
DELIMITER ;

DELIMITER XD
CREATE PROCEDURE generujkierowcow (IN liczba INT)
BEGIN
	DECLARE i INT DEFAULT 1;
	WHILE i <= LICZBA DO
		INSERT INTO kierowca (nazwa) VALUES (CONCAT('Kierowca nr ', i));
		SET i = i + 1;
	END WHILE;
ENDXD
DELIMITER ;

DELIMITER XD
CREATE PROCEDURE generujprzystanki (IN liczba INT)
BEGIN
	DECLARE i INT DEFAULT 1;
	WHILE i <= LICZBA DO
		INSERT INTO przystanek (nazwa) VALUES (CONCAT('Przystanek nr ', i));
		SET i = i + 1;
	END WHILE;
ENDXD
DELIMITER ;

DELIMITER XD
CREATE PROCEDURE generujlinie(IN liczba INT)
BEGIN
	DECLARE i INT DEFAULT 0;
	WHILE i <= liczba DO
		INSERT INTO linia VALUES (i);
		SET i = i + 1;
	END WHILE;
ENDXD
DELIMITER ;


CREATE USER 'manager'@'localhost' IDENTIFIED BY 'mr2019';
GRANT INSERT,SELECT,UPDATE,DELETE ON *.* TO 'manager'@'localhost';

CREATE USER 'passenger'@'localhost' IDENTIFIED BY 'pr2019';
GRANT SELECT ON *.* TO 'passenger'@'localhost';


GRANT EXECUTE ON PROCEDURE jsopdb.Select_Terminarz TO 'passenger'@'localhost';
GRANT EXECUTE ON PROCEDURE jsopdb.Select_CzasJazdy TO 'passenger'@'localhost';
GRANT EXECUTE ON PROCEDURE jsopdb.Select_Terminarz TO 'manager'@'localhost';
GRANT EXECUTE ON PROCEDURE jsopdb.Select_CzasJazdy TO 'manager'@'localhost';

CALL generujlinie(5);
CALL generujkierowcow(5);
CALL generujprzystanki(5);