 # Perfect seed script doesn't exist yet here we are...
 CALL generujlinie(1);
 CALL generujkierowcow(2);

INSERT INTO przystanek (nazwa) VALUES ("Rynek");
INSERT INTO przystanek (nazwa) VALUES ("Młyn");
INSERT INTO przystanek (nazwa) VALUES ("Opolska");
INSERT INTO przystanek (nazwa) VALUES ("Sąd Okręgowy");
INSERT INTO przystanek (nazwa) VALUES ("Stabłowice");

INSERT INTO pojazd(typ) VALUES ("bus");

INSERT INTO trasa VALUES (0,0,2,5);
INSERT INTO trasa VALUES (1,0,1,4);

INSERT INTO przejazd (przystanekA, przystanekB,ID_Trasa) VALUES (2,3,1);
INSERT INTO przejazd (przystanekA, przystanekB,ID_Trasa) VALUES (3,4,1);
INSERT INTO przejazd (przystanekA, przystanekB,ID_Trasa) VALUES (4,5,1);

INSERT INTO przejazd (przystanekA, przystanekB,ID_Trasa)  VALUES (1,2,0);
INSERT INTO przejazd (przystanekA, przystanekB,ID_Trasa) VALUES (2,3,0);
INSERT INTO przejazd (przystanekA, przystanekB,ID_Trasa) VALUES (3,4,0);
INSERT INTO przejazd (przystanekA, przystanekB,ID_Trasa) VALUES (4,5,0);

INSERT INTO terminarz (id_przejazd,przyjazd,odjazd) VALUES(1,NULL,TIME('2018-03-03 12:00:00'));
INSERT INTO przypisania (id_terminarz,id_kierowca,id_pojazd) VALUES(1,1,1);
INSERT INTO terminarz (id_przejazd,przyjazd,odjazd) VALUES(2,TIME('2018-03-03 12:02:00'),TIME('2018-03-03 12:02:15'));
INSERT INTO przypisania (id_terminarz,id_kierowca,id_pojazd) VALUES(2,1,1);
INSERT INTO terminarz (id_przejazd,przyjazd,odjazd) VALUES(3,TIME('2018-03-03 12:05:00'),NULL);
INSERT INTO przypisania (id_terminarz,id_kierowca,id_pojazd) VALUES(3,1,1);

INSERT INTO terminarz (id_przejazd,przyjazd,odjazd) VALUES(4,NULL,TIME('2018-03-04 12:00:00'));
INSERT INTO przypisania (id_terminarz,id_kierowca,id_pojazd) VALUES(4,2,1);
INSERT INTO terminarz (id_przejazd,przyjazd,odjazd) VALUES(5,TIME('2018-03-04 12:02:00'),TIME('2018-03-04 12:02:15'));
INSERT INTO przypisania (id_terminarz,id_kierowca,id_pojazd) VALUES(5,2,1);
INSERT INTO terminarz (id_przejazd,przyjazd,odjazd) VALUES(6,TIME('2018-03-04 12:05:00'),TIME('2018-03-04 12:05:15'));
INSERT INTO przypisania (id_terminarz,id_kierowca,id_pojazd) VALUES(6,2,1);
INSERT INTO terminarz (id_przejazd,przyjazd,odjazd) VALUES(7,TIME('2018-03-04 12:09:00'),NULL);
INSERT INTO przypisania (id_terminarz,id_kierowca,id_pojazd) VALUES(7,2,1);

