-- =====================================================
-- EXERCICE SQL — Base "Bibliothèque"
-- Révision : DDL, contraintes, DML, consultas, JOIN,
-- sous-requêtes, GROUP BY/HAVING, VIEW, PROCEDURE
-- À exécuter dans MySQL Workbench, étape par étape.
-- =====================================================

-- 0. Création et sélection de la base
DROP DATABASE IF EXISTS bibliotheque;
CREATE DATABASE bibliotheque;
USE bibliotheque;

-- =====================================================
-- 1. SCHÉMA (DDL + contraintes)
-- =====================================================

CREATE TABLE auteurs (
    id_auteur   INT PRIMARY KEY AUTO_INCREMENT,
    nom         VARCHAR(50) NOT NULL,
    pays        VARCHAR(50) DEFAULT 'Inconnu'
);

CREATE TABLE livres (
    id_livre    INT PRIMARY KEY AUTO_INCREMENT,
    titre       VARCHAR(100) NOT NULL,
    annee       INT CHECK (annee >= 1500),
    prix        DECIMAL(6,2) DEFAULT 0,
    id_auteur   INT,
    FOREIGN KEY (id_auteur) REFERENCES auteurs(id_auteur)
);

CREATE TABLE membres (
    id_membre   INT PRIMARY KEY AUTO_INCREMENT,
    nom         VARCHAR(50) NOT NULL,
    email       VARCHAR(100) UNIQUE,
    age         INT CHECK (age >= 0)
);

CREATE TABLE emprunts (
    id_emprunt  INT PRIMARY KEY AUTO_INCREMENT,
    id_livre    INT,
    id_membre   INT,
    date_emprunt DATE NOT NULL,
    rendu       BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (id_livre) REFERENCES livres(id_livre),
    FOREIGN KEY (id_membre) REFERENCES membres(id_membre)
);

-- =====================================================
-- 2. DONNÉES (DML)
-- =====================================================

INSERT INTO auteurs (nom, pays) VALUES
('Victor Hugo', 'France'),
('J.K. Rowling', 'UK'),
('Gabriel Garcia Marquez', 'Colombie'),
('Isaac Asimov', 'USA');

INSERT INTO livres (titre, annee, prix, id_auteur) VALUES
('Les Misérables', 1862, 12.50, 1),
('Notre-Dame de Paris', 1831, 10.00, 1),
('Harry Potter à l’école des sorciers', 1997, 15.90, 2),
('Harry Potter et la Chambre des secrets', 1998, 15.90, 2),
('Cent ans de solitude', 1967, 13.20, 3),
('Fondation', 1951, 9.90, 4),
('Fondation et Empire', 1952, 9.90, 4);

INSERT INTO membres (nom, email, age) VALUES
('Antoine', 'antoine@mail.com', 20),
('Clara', 'clara@mail.com', 22),
('Sofia', 'sofia@mail.com', 17),
('Léo', 'leo@mail.com', 30);

INSERT INTO emprunts (id_livre, id_membre, date_emprunt, rendu) VALUES
(1, 1, '2024-01-10', TRUE),
(3, 1, '2024-02-05', FALSE),
(4, 2, '2024-02-10', TRUE),
(5, 3, '2024-03-01', FALSE),
(6, 4, '2024-03-15', TRUE),
(7, 4, '2024-03-20', FALSE);

-- =====================================================
-- 3. QUESTIONS — essaie de répondre AVANT de regarder le corrigé
-- =====================================================

-- DDL
-- Q1. Ajoute une colonne "genre" (VARCHAR(30)) à la table livres.
-- Q2. Supprime la contrainte implicite en rendant "annee" obligatoire (NOT NULL) via MODIFY.

-- DML
-- Q3. Insère un nouvel auteur "Albert Camus" (France).
-- Q4. Change le prix du livre "Fondation" à 11.00.
-- Q5. Supprime le membre "Sofia" (attention à l'ordre à cause des FOREIGN KEY : que faut-il faire avant ?).

-- CONSULTAS simples
-- Q6. Liste tous les livres triés par prix décroissant.
-- Q7. Liste les membres de moins de 21 ans.
-- Q8. Liste les livres dont le titre contient "Harry".
-- Q9. Liste les livres publiés entre 1950 et 1970.
-- Q10. Liste les emprunts non rendus (rendu = FALSE).

-- AGRÉGATION / GROUP BY / HAVING
-- Q11. Combien de livres par auteur (id_auteur, nombre de livres) ?
-- Q12. Quel est le prix moyen des livres ?
-- Q13. Quels auteurs ont écrit plus d'un livre (HAVING) ?

-- JOIN
-- Q14. Affiche le titre du livre + le nom de l'auteur pour chaque livre.
-- Q15. Affiche le nom du membre + le titre du livre pour chaque emprunt en cours (rendu = FALSE).
-- Q16. Affiche le nom de l'auteur + le nombre total de livres empruntés de ses livres (JOIN sur 3 tables + GROUP BY).

-- SOUS-REQUÊTE
-- Q17. Liste les livres dont le prix est supérieur au prix moyen.
-- Q18. Liste les membres qui n'ont jamais emprunté de livre (sous-requête avec NOT IN).

-- VIEW / PROCEDURE (bonus)
-- Q19. Crée une VIEW "emprunts_en_cours" qui montre nom du membre + titre du livre pour rendu = FALSE.
-- Q20. Crée une PROCEDURE "livres_auteur(id)" qui affiche tous les livres d'un auteur donné.

-- =====================================================
-- 4. CORRIGÉ
-- =====================================================

-- Q1
ALTER TABLE livres ADD genre VARCHAR(30);

-- Q2
ALTER TABLE livres MODIFY annee INT NOT NULL;

-- Q3
INSERT INTO auteurs (nom, pays) VALUES ('Albert Camus', 'France');

-- Q4
UPDATE livres SET prix = 11.00 WHERE titre = 'Fondation';

-- Q5 (il faut d'abord supprimer ses emprunts, sinon erreur de clé étrangère)
DELETE FROM emprunts WHERE id_membre = (SELECT id_membre FROM membres WHERE nom = 'Sofia');
DELETE FROM membres WHERE nom = 'Sofia';

-- Q6
SELECT * FROM livres ORDER BY prix DESC;

-- Q7
SELECT * FROM membres WHERE age < 21;

-- Q8
SELECT * FROM livres WHERE titre LIKE '%Harry%';

-- Q9
SELECT * FROM livres WHERE annee BETWEEN 1950 AND 1970;

-- Q10
SELECT * FROM emprunts WHERE rendu = FALSE;

-- Q11
SELECT id_auteur, COUNT(*) AS nb_livres
FROM livres
GROUP BY id_auteur;

-- Q12
SELECT AVG(prix) AS prix_moyen FROM livres;

-- Q13
SELECT id_auteur, COUNT(*) AS nb_livres
FROM livres
GROUP BY id_auteur
HAVING COUNT(*) > 1;

-- Q14
SELECT livres.titre, auteurs.nom
FROM livres
JOIN auteurs ON livres.id_auteur = auteurs.id_auteur;

-- Q15
SELECT membres.nom, livres.titre
FROM emprunts
JOIN membres ON emprunts.id_membre = membres.id_membre
JOIN livres ON emprunts.id_livre = livres.id_livre
WHERE emprunts.rendu = FALSE;

-- Q16
SELECT auteurs.nom, COUNT(emprunts.id_emprunt) AS total_emprunts
FROM auteurs
JOIN livres ON auteurs.id_auteur = livres.id_auteur
JOIN emprunts ON livres.id_livre = emprunts.id_livre
GROUP BY auteurs.nom;

-- Q17
SELECT * FROM livres
WHERE prix > (SELECT AVG(prix) FROM livres);

-- Q18
SELECT * FROM membres
WHERE id_membre NOT IN (SELECT id_membre FROM emprunts);

-- Q19
CREATE VIEW emprunts_en_cours AS
SELECT membres.nom AS membre, livres.titre AS livre
FROM emprunts
JOIN membres ON emprunts.id_membre = membres.id_membre
JOIN livres ON emprunts.id_livre = livres.id_livre
WHERE emprunts.rendu = FALSE;

SELECT * FROM emprunts_en_cours;

-- Q20
DELIMITER //
CREATE PROCEDURE livres_auteur(IN auteur_id INT)
BEGIN
    SELECT titre FROM livres WHERE id_auteur = auteur_id;
END //
DELIMITER ;

CALL livres_auteur(2);
