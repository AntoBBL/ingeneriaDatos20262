#pregunta 1
ALTER TABLE livres ADD genre VARCHAR(30);

#pregunta 2
ALTER TABLE `bibliotheque`.`livres` CHANGE COLUMN `annee` `annee` INT NOT NULL ; 

#pregunta 3
INSERT INTO `bibliotheque`.`auteurs` (`id_auteur`, `nom`, `pays`) VALUES ('5', 'Albert Camus', 'France');

#pregunta 4
UPDATE `bibliotheque`.`livres` SET `prix` = '11.0' WHERE (`id_livre` = '6');

#pregunta 5
DELETE FROM `bibliotheque`.`emprunts` WHERE (`id_emprunt` = '4');
DELETE FROM `bibliotheque`.`membres` WHERE (`id_membre` = '3');

#pregunta 6
select * from livres
order by prix desc;

#pregunta 7
select * from membres
where age < 21;

#pregunta 8
select * from livres
where titre like '%Harry%';

#pregunta 9
select * from livres
where annee between 1950 and 1970
order by annee asc;

#pregunta 10
select * from emprunts
where rendu = 0;

#pregunta 11
select id_auteur, count(*) as tot_livres from livres
group by id_auteur;

#pregunta 12
select avg (prix) as moyenne_prix from livres;

#pregunta 13
	#select auteurs.nom, count(livres.id_livre) as nb_livres from livres
	#inner join auteurs on livres.id_auteur = auteurs.id_auteur
	#group by auteurs.nom
	#having count (livres.id_livre) > 1;

SELECT id_auteur, COUNT(*) AS nb_livres FROM livres
GROUP BY id_auteur
HAVING COUNT(*) > 1;

#pregunta 14
	#select livres.titre from livres
	#inner join auteurs on livres.id_auteur = auteurs.id_auteur
	#order by auteurs.nom;

SELECT livres.titre, auteurs.nom FROM livres
JOIN auteurs ON livres.id_auteur = auteurs.id_auteur;

#pregunta 15
select membres.nom, livres.titre from emprunts
join membres on emprunts.id_membre = membres.id_membre
join livres on emprunts.id_livre = livres.id_livre
where emprunts.rendu = false;

#pregunta 16
select auteurs.nom, count(emprunts.id_emprunt) as nb_tot_empr from emprunts
join livres on emprunts.id_livre = livres.id_livre
join auteurs on livres.id_auteur = auteurs.id_auteur
group by auteurs.nom;

#pregunta 17
	#select titre, avg(prix) as moy from livres
	#where prix > 'moy'
	#group by titre;
select titre, prix, (select avg(prix) from livres) as moy from livres
where prix > (select avg(prix) from livres);

#pregunta 18
