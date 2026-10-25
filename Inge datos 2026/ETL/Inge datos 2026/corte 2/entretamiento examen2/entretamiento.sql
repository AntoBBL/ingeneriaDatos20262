DROP DATABASE IF EXISTS veloandes;
CREATE DATABASE veloandes;
USE veloandes;

CREATE TABLE stations (
  id_station INT NOT NULL AUTO_INCREMENT,
  nom VARCHAR(60) NOT NULL,
  ville VARCHAR(60) NOT NULL,
  capacite INT NOT NULL,
  date_ouverture DATE NOT NULL,
  PRIMARY KEY (id_station),
  UNIQUE (nom),
  CONSTRAINT chk_stations_capacite CHECK (capacite > 0)
);

CREATE TABLE velos (
  id_velo INT NOT NULL AUTO_INCREMENT,
  code_serie VARCHAR(12) NOT NULL,
  modele VARCHAR(40) NOT NULL,
  autonomie_km DECIMAL(5,1) NOT NULL,
  statut VARCHAR(15) NOT NULL DEFAULT 'DISPONIBLE',
  km_total DECIMAL(8,1) NOT NULL DEFAULT 0,
  date_achat DATE NOT NULL,
  id_station INT NOT NULL,
  PRIMARY KEY (id_velo),
  UNIQUE (code_serie),
  CONSTRAINT chk_velos_autonomie CHECK (autonomie_km > 0),
  CONSTRAINT chk_velos_km_positif CHECK (km_total >= 0),
  CONSTRAINT chk_velos_statut CHECK (statut IN ('DISPONIBLE','LOUE','MAINTENANCE','HORS_SERVICE')),
  CONSTRAINT fk_velos_station FOREIGN KEY (id_station) REFERENCES stations (id_station)
);

CREATE TABLE clients (
  id_client INT NOT NULL AUTO_INCREMENT,
  type_client VARCHAR(12) NOT NULL,
  nom VARCHAR(80) NOT NULL,
  email VARCHAR(80) NULL,
  telephone VARCHAR(15) NULL,
  ville VARCHAR(60) NOT NULL,
  date_inscription DATE NOT NULL DEFAULT (CURRENT_DATE),
  id_parrain INT NULL,
  PRIMARY KEY (id_client),
  UNIQUE (email),
  CONSTRAINT chk_clients_type CHECK (type_client IN ('PARTICULIER','ENTREPRISE'))
  -- la FK du parrain (fk_clients_parrain) s'ajoute en R3.c
);

CREATE TABLE accessoires (
  id_accessoire INT NOT NULL AUTO_INCREMENT,
  nom VARCHAR(40) NOT NULL,
  prix_jour DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (id_accessoire),
  UNIQUE (nom),
  CONSTRAINT chk_accessoires_prix CHECK (prix_jour > 0)
);

CREATE TABLE locations (
  id_location INT NOT NULL AUTO_INCREMENT,
  code VARCHAR(10) NOT NULL,
  id_client INT NOT NULL,
  id_velo INT NOT NULL,
  date_debut DATETIME NOT NULL,
  date_fin DATETIME NULL,
  km_parcourus DECIMAL(6,1) NOT NULL DEFAULT 0,
  statut VARCHAR(12) NOT NULL DEFAULT 'PLANIFIEE',
  note SMALLINT NULL,
  PRIMARY KEY (id_location),
  UNIQUE (code),
  CONSTRAINT chk_locations_km CHECK (km_parcourus >= 0),
  CONSTRAINT chk_locations_statut CHECK (statut IN ('PLANIFIEE','EN_COURS','TERMINEE','ANNULEE')),
  CONSTRAINT chk_locations_note CHECK (note BETWEEN 1 AND 5),
  CONSTRAINT chk_locations_date_fin CHECK (date_fin IS NULL OR statut = 'TERMINEE'),
  CONSTRAINT fk_locations_client FOREIGN KEY (id_client) REFERENCES clients (id_client),
  CONSTRAINT fk_locations_velo FOREIGN KEY (id_velo) REFERENCES velos (id_velo)
);

CREATE TABLE location_accessoire (
  id_location INT NOT NULL,
  id_accessoire INT NOT NULL,
  quantite INT NOT NULL DEFAULT 1,
  PRIMARY KEY (id_location, id_accessoire),
  CONSTRAINT chk_locacc_quantite CHECK (quantite > 0),
  CONSTRAINT fk_locacc_location FOREIGN KEY (id_location) REFERENCES locations (id_location),
  CONSTRAINT fk_locacc_accessoire FOREIGN KEY (id_accessoire) REFERENCES accessoires (id_accessoire)
);

CREATE TABLE historique_locations (
  id_historique INT NOT NULL AUTO_INCREMENT,
  id_location INT NOT NULL,
  statut_ancien VARCHAR(12) NOT NULL,
  statut_nouveau VARCHAR(12) NOT NULL,
  date_changement DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id_historique),
  CONSTRAINT fk_historique_location FOREIGN KEY (id_location) REFERENCES locations (id_location)
);

INSERT INTO stations (id_station, nom, ville, capacite, date_ouverture)
VALUES
(1, 'Station Centre', 'Medellín', 8, '2024-03-01'),
(2, 'Station Parc', 'Envigado', 5, '2024-09-15'),
(3, 'Station Lac', 'Guatapé', 4, '2025-02-10'),
(4, 'Station Gare', 'Bogotá', 6, '2026-06-01');
INSERT INTO velos (id_velo, code_serie, modele, autonomie_km, statut,
km_total, date_achat, id_station) VALUES
(1, 'VE-URB-01', 'Urbain 300', 60.0, 'DISPONIBLE', 820.5, '2024-03-05',
1),
(2, 'VE-URB-02', 'Urbain 300', 60.0, 'LOUE', 1210.0, '2024-03-05',
1),
(3, 'VE-TRK-01', 'Trek Pro', 90.0, 'DISPONIBLE', 1340.0, '2025-01-20',
2),
(4, 'VE-TRK-02', 'Trek Pro', 90.0, 'MAINTENANCE', 1530.0, '2024-10-01',
2),
(5, 'VE-CTY-01', 'City Lite', 40.0, 'DISPONIBLE', 95.0, '2025-03-12',
3),
(6, 'VE-CTY-02', 'City Lite', 40.0, 'DISPONIBLE', 1005.0, '2025-03-12',
3),
(7, 'VE-MTN-01', 'Montagne X', 120.0, 'HORS_SERVICE', 2300.0, '2024-06-01',
1);
INSERT INTO clients (id_client, type_client, nom, email, telephone, ville,
date_inscription, id_parrain) VALUES
(1, 'PARTICULIER', 'Andrés Cárdenas', 'andres.cardenas@gmail.com',
'3101234567', 'Medellín', '2024-03-10', NULL),
(2, 'PARTICULIER', 'Valentina Ríos', 'vale.rios@outlook.com',
'3209876543', 'Envigado', '2024-10-02', 1),
(3, 'ENTREPRISE', 'Café Mirador S.A.S.', 'compras@cafemirador.co',
'6045551234', 'Guatapé', '2025-02-20', NULL),
(4, 'PARTICULIER', 'Julián Osorio', NULL,
'31055544', 'Medellín', '2025-05-14', 1),
(5, 'PARTICULIER', 'Camila Torres', 'camila.torres@hotmail.com',
'3157778899', 'Bogotá', '2025-08-30', 2),
(6, 'ENTREPRISE', 'Hostal Los Nogales', 'info@hostalnogales.com', NULL,
'Guatapé', '2025-09-09', 3),
(7, 'PARTICULIER', 'Sebastián Mora', 'sebas.mora@gmail.com',
'3001112233', 'Bogotá', '2026-06-15', 5),
(8, 'PARTICULIER', 'Laura Pineda',
'lpineda@universidad.edu.co','3123334455', 'Envigado', '2026-07-01', NULL),
(9, 'PARTICULIER', 'Tomás Vega', NULL, NULL,
'Medellín', '2026-09-01', NULL);
INSERT INTO accessoires (id_accessoire, nom, prix_jour) VALUES
(1, 'Casque', 2000), (2, 'Antivol', 1500), (3, 'Panier', 1000),
(4, 'Siège enfant', 4000), (5, 'Remorque', 6000);
INSERT INTO locations (id_location, code, id_client, id_velo, date_debut,
date_fin, km_parcourus, statut, note) VALUES
(1, 'LOC-0001', 1, 1, '2026-08-01 09:00:00', '2026-08-01 13:00:00', 32.5,
'TERMINEE', 5),
(2, 'LOC-0002', 2, 3, '2026-08-03 10:00:00', '2026-08-03 18:30:00', 64.0,
'TERMINEE', 4),
(3, 'LOC-0003', 3, 5, '2026-08-05 08:00:00', '2026-08-05 12:00:00', 28.0,
'TERMINEE', NULL),
(4, 'LOC-0004', 1, 2, '2026-08-09 14:00:00', NULL, 0, 'ANNULEE', NULL),
(5, 'LOC-0005', 4, 6, '2026-08-12 09:30:00', '2026-08-12 11:00:00', 15.0,
'TERMINEE', 3),
(6, 'LOC-0006', 5, 3, '2026-08-15 07:00:00', '2026-08-15 16:00:00', 82.0,
'TERMINEE', 5),
(7, 'LOC-0007', 2, 1, '2026-08-20 10:00:00', '2026-08-20 15:00:00', 45.0,
'TERMINEE', 4),
(8, 'LOC-0008', 6, 5, '2026-08-22 09:00:00', '2026-08-22 13:30:00', 30.0,
'TERMINEE', 2),
(9, 'LOC-0009', 3, 4, '2026-08-25 11:00:00', NULL, 0, 'ANNULEE', NULL),
(10, 'LOC-0010', 1, 3, '2026-09-02 08:30:00', '2026-09-02 17:00:00', 70.0,
'TERMINEE', 5),
(11, 'LOC-0011', 7, 6, '2026-09-10 09:00:00', '2026-09-10 12:00:00', 22.0,
'TERMINEE', 4),
(12, 'LOC-0012', 5, 1, '2026-09-14 15:00:00', NULL, 0, 'ANNULEE', NULL),
(13, 'LOC-0013', 2, 2, '2026-09-20 10:00:00', '2026-09-20 16:00:00', 55.0,
'TERMINEE', NULL),
(14, 'LOC-0014', 8, 2, '2026-09-28 09:00:00', NULL, 0, 'EN_COURS', NULL),
(15, 'LOC-0015', 7, 6, '2026-10-01 09:00:00', NULL, 0, 'PLANIFIEE', NULL),
(16, 'LOC-0016', 3, 4, '2026-10-02 10:00:00', NULL, 0, 'PLANIFIEE', NULL);
INSERT INTO location_accessoire (id_location, id_accessoire, quantite) VALUES
(1,1,1),(1,2,1),(2,1,2),(2,3,1),(3,1,1),(5,1,1),(6,1,1),(6,2,1),(6,4,1),
(7,1,1),(8,1,2),(8,4,1),(9,2,1),(10,1,1),(10,2,1),(11,3,1),(13,1,1),
(14,1,1),(15,1,1),(16,2,1);

-- R3
alter table clients modify nom VARCHAR(120) not null;
alter table velos add constraint chk_velos_km check (km_total <= 100000);
ALTER TABLE clients ADD CONSTRAINT fk_clients_parrain FOREIGN KEY (id_parrain) REFERENCES clients (id_client);

-- R4
insert into clients (type_client,nom,email,telephone, ville, date_inscription, id_parrain) values
('PARTICULIER', 'Daniel Ospina', 'daniel.ospina@gmail.com', '3114445566', 'Medellín', '2026-09-28', 1),
('PARTICULIER', 'Marta LucíaGil', NULL, '3175556677', 'Envigado', '2026-09-29', 2),
('ENTREPRISE', 'Bicicafé Andino', 'contacto@bibicafe.co', '3201239874', 'Bogotá', '2026-09-30', NULL);

SET SQL_SAFE_UPDATES = 0;
update velos set statut = 'MAINTENANCE'
where statut = 'DISPONIBLE' and km_total > 1000;

delete from locations 
where statut = 'ANNULEE' AND id_location NOT IN (SELECT id_location FROM location_accessoire);

select
	(select COUNT(id_client) from clients) as totCLI, 
    (select COUNT(id_location) from locations) as totLOC,
    (select COUNT(id_velo) from velos where statut = 'MAINTENANCE') as nbMaint ;
    
select code_serie, modele, autonomie_km, statut from velos
where statut in ('DISPONIBLE', 'LOUE') and (autonomie_km between 40 and 90) 
ORDER BY autonomie_km DESC, code_serie;

-- R5.b1
SELECT code, statut, date_debut
FROM locations
WHERE statut NOT IN ('PLANIFIEE','EN_COURS','TERMINEE') AND date_fin IS NULL
ORDER BY code;

-- R5.b2
SELECT code, date_fin
FROM locations
WHERE date_fin IS NOT NULL AND note IS NULL;

-- R5.c
SELECT code_serie, modele, autonomie_km, km_total, statut
FROM velos
WHERE statut <> 'HORS_SERVICE'
  AND ((autonomie_km >= 60 AND km_total < 1000) OR km_total > 1500)
ORDER BY code_serie;

-- R5.d
SELECT nom, type_client, date_inscription
FROM clients
WHERE NOT type_client = 'PARTICULIER' AND date_inscription <= '2025-09-09'
ORDER BY date_inscription;


-- R6.a
SELECT UPPER(nom) AS client, ville,
       COALESCE(telephone, 'SANS TÉLÉPHONE') AS telephone,
       LENGTH(telephone) AS chiffres
FROM clients
WHERE telephone IS NULL OR LENGTH(telephone) <> 10
ORDER BY nom;

-- R6.b
SELECT nom, LOWER(email) AS email,
       CONCAT(nom, ' <', LOWER(email), '>') AS contact
FROM clients
WHERE email IS NOT NULL
  AND email NOT LIKE '%@gmail.com'
  AND email NOT LIKE '%@hotmail.com'
  AND email NOT LIKE '%@outlook.com'
ORDER BY nom;


-- R6.c
SELECT code_serie, UPPER(modele) AS modele, km_total,
       ROUND(km_total / 2500 * 100, 1) AS pct_vie
FROM velos
WHERE code_serie LIKE 'VE-___-__'
ORDER BY km_total DESC;


-- R7.a
SELECT modele,
       COUNT(*) AS nb_velos,
       ROUND(AVG(km_total), 2) AS km_moyen,
       MIN(km_total) AS km_min,
       MAX(km_total) AS km_max
FROM velos
GROUP BY modele
HAVING COUNT(*) >= 2
ORDER BY km_moyen DESC;

-- R7.b
SELECT c.nom AS client,
       COUNT(*) AS locations_realisees,
       ROUND(AVG(l.note), 2) AS note_moyenne
FROM clients c
JOIN locations l ON l.id_client = c.id_client
WHERE l.statut = 'TERMINEE'
GROUP BY c.id_client, c.nom
HAVING COUNT(*) >= 2 AND AVG(l.note) >= 4
ORDER BY note_moyenne DESC, client;


-- R8.a
SELECT l.code, c.nom AS client, v.code_serie AS velo, s.nom AS station,
       TIMESTAMPDIFF(MINUTE, l.date_debut, l.date_fin) AS minutes
FROM locations l
INNER JOIN clients c  ON c.id_client  = l.id_client
INNER JOIN velos v    ON v.id_velo    = l.id_velo
INNER JOIN stations s ON s.id_station = v.id_station
WHERE l.statut = 'TERMINEE'
ORDER BY l.date_debut;

-- R8.b
SELECT c.nom AS client, c.ville, COUNT(l.id_location) AS locations_realisees
FROM clients c
LEFT JOIN locations l ON l.id_client = c.id_client AND l.statut = 'TERMINEE'
GROUP BY c.id_client, c.nom, c.ville
ORDER BY locations_realisees DESC, client;

-- R8.c
SELECT c.nom AS client, c.type_client,
       COALESCE(p.nom, 'SANS PARRAIN') AS parrain
FROM clients c
LEFT JOIN clients p ON p.id_client = c.id_parrain
ORDER BY parrain, client;

-- R8.d
SELECT l.code, c.nom AS client, v.code_serie AS velo, v.statut AS statut_velo
FROM locations l
JOIN clients c ON c.id_client = l.id_client
JOIN velos v   ON v.id_velo   = l.id_velo
WHERE l.statut = 'PLANIFIEE' AND v.statut <> 'DISPONIBLE';


-- R9.a
SELECT code, km_parcourus
FROM locations
WHERE statut = 'TERMINEE'
  AND km_parcourus > (SELECT AVG(km_parcourus) FROM locations WHERE statut = 'TERMINEE')
ORDER BY km_parcourus DESC;

-- R9.b
SELECT nom, type_client, ville, date_inscription
FROM clients
WHERE id_client NOT IN (SELECT id_client FROM locations)
ORDER BY date_inscription, nom;

-- R9.c
SELECT v.code_serie, s.nom AS station, v.km_total
FROM velos v
JOIN stations s ON s.id_station = v.id_station
WHERE v.km_total > (SELECT AVG(v2.km_total) FROM velos v2 WHERE v2.id_station = v.id_station)
ORDER BY station;

-- R9.d
SELECT a.nom, a.prix_jour
FROM accessoires a
WHERE NOT EXISTS (SELECT 1 FROM location_accessoire la WHERE la.id_accessoire = a.id_accessoire);


-- R10.a
CREATE OR REPLACE VIEW vw_tableau_locations AS
SELECT l.code, l.date_debut, c.nom AS client, c.type_client,
       v.code_serie AS velo, s.nom AS station, l.statut,
       COUNT(la.id_accessoire) AS nb_accessoires,
       COALESCE(SUM(la.quantite * a.prix_jour), 0) AS cout_accessoires
FROM locations l
JOIN clients c  ON c.id_client  = l.id_client
JOIN velos v    ON v.id_velo    = l.id_velo
JOIN stations s ON s.id_station = v.id_station
LEFT JOIN location_accessoire la ON la.id_location = l.id_location
LEFT JOIN accessoires a          ON a.id_accessoire = la.id_accessoire
GROUP BY l.id_location, l.code, l.date_debut, c.nom, c.type_client,
         v.code_serie, s.nom, l.statut;

SELECT * FROM vw_tableau_locations
WHERE statut IN ('PLANIFIEE','EN_COURS')
ORDER BY date_debut;

-- R10.b

CREATE INDEX idx_locations_statut_date ON locations (statut, date_debut);

CREATE INDEX idx_clients_type_ville ON clients (type_client, ville);

SHOW INDEX FROM locations;
SHOW INDEX FROM clients;


DELIMITER $$
CREATE FUNCTION fn_valeur_location(p_id_location INT)
RETURNS DECIMAL(12,2)
READS SQL DATA
BEGIN
  DECLARE v_km DECIMAL(6,1);
  DECLARE v_acc DECIMAL(12,2);
  DECLARE v_total DECIMAL(12,2);

  SELECT km_parcourus INTO v_km FROM locations WHERE id_location = p_id_location;
  IF v_km IS NULL THEN
    RETURN NULL;
  END IF;

  SELECT COALESCE(SUM(la.quantite * a.prix_jour), 0) INTO v_acc
  FROM location_accessoire la
  JOIN accessoires a ON a.id_accessoire = la.id_accessoire
  WHERE la.id_location = p_id_location;

  SET v_total = v_acc + v_km * 500;
  IF v_km > 50 THEN
    SET v_total = v_total * 1.15;
  END IF;
  RETURN ROUND(v_total, 2);
END$$
DELIMITER ;

-- R11.b
SELECT code, fn_valeur_location(id_location) AS valeur_cop
FROM locations
WHERE statut = 'TERMINEE'
ORDER BY valeur_cop DESC;

SELECT fn_valeur_location(999) AS valeur_inexistante;   -- NULL


DELIMITER $$
CREATE TRIGGER trg_locations_statut
BEFORE UPDATE ON locations
FOR EACH ROW
BEGIN
  IF NEW.statut <> OLD.statut THEN
    IF NEW.statut = 'TERMINEE' AND NEW.date_fin IS NULL THEN
      SET NEW.date_fin = NOW();
    END IF;
    INSERT INTO historique_locations (id_location, statut_ancien, statut_nouveau)
    VALUES (OLD.id_location, OLD.statut, NEW.statut);
  END IF;
END$$
DELIMITER ;

UPDATE locations SET statut = 'TERMINEE', note = 5 WHERE code = 'LOC-0014';
UPDATE locations SET statut = 'ANNULEE' WHERE code = 'LOC-0016';
UPDATE locations SET note = 4 WHERE code = 'LOC-0013';

SELECT l.code, h.statut_ancien, h.statut_nouveau, h.date_changement
FROM historique_locations h
JOIN locations l ON l.id_location = h.id_location;
-- Attendu : 2 lignes (LOC-0014 et LOC-0016), rien pour LOC-0013

SELECT code, statut, date_fin, note
FROM locations
WHERE code IN ('LOC-0013','LOC-0014','LOC-0016');


DELIMITER $$
CREATE PROCEDURE sp_planifier_location(
  IN p_code VARCHAR(10),
  IN p_id_client INT,
  IN p_id_velo INT,
  IN p_date_debut DATETIME,
  IN p_km_prevus DECIMAL(6,1)
)
BEGIN
  DECLARE v_nb_client INT;
  DECLARE v_statut VARCHAR(15);
  DECLARE v_autonomie DECIMAL(5,1);

  SELECT COUNT(*) INTO v_nb_client FROM clients WHERE id_client = p_id_client;
  SELECT statut, autonomie_km INTO v_statut, v_autonomie
  FROM velos WHERE id_velo = p_id_velo;

  -- 1) existence
  IF v_nb_client = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Le client n''existe pas';
  END IF;
  IF v_statut IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Le vélo n''existe pas';
  END IF;
  -- 2) vélo disponible (RN-04)
  IF v_statut <> 'DISPONIBLE' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Le vélo n''est pas DISPONIBLE';
  END IF;
  -- 3) autonomie
  IF p_km_prevus > v_autonomie THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Les km prévus dépassent l''autonomie du vélo';
  END IF;

  INSERT INTO locations (code, id_client, id_velo, date_debut)
  VALUES (p_code, p_id_client, p_id_velo, p_date_debut);

  SELECT LAST_INSERT_ID() AS id_location_genere;
END$$
DELIMITER ;

CALL sp_planifier_location('LOC-0017', 9, 1, '2026-10-05 09:00:00', 30.0);  -- OK
CALL sp_planifier_location('LOC-0018', 1, 4, '2026-10-05 10:00:00', 20.0);  -- erreur : vélo en MAINTENANCE
CALL sp_planifier_location('LOC-0019', 2, 5, '2026-10-06 08:00:00', 55.0);  -- erreur : 55 > 40 km
CALL sp_planifier_location('LOC-0020', 99, 1, '2026-10-06 09:00:00', 10.0); -- erreur : client inexistant

SELECT * FROM vw_tableau_locations WHERE code = 'LOC-0017';
