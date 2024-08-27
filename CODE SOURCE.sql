 //2BIS1 
projet élaboré par : Nour Charfeddine et Nader ben Ammar
Création des tables 
create table individu( 
numindividue number(8) primary key, 
nomindividu varchar(50) not null, 
prenomindividu varchar(50) not null); 
CREATE TABLE film( 
numfilm number(8) primary key, 
titre varchar(50) not null, 
realisateur number(8)references individu(numindividue)); 
create table exemplaire( 
numexemplaire number(8) primary key, 
numfilm number(8)references film(numfilm), 
codesupport varchar(8) not null, 
vo varchar(8), 
probleme varchar(1000), 
detailsupport varchar(1000)); 
create table clientt( 
login varchar(30) primary key, 
nomclient varchar(50) not null, 
prenomclient varchar(50) not null, 
motdepasse varchar(20), 
adresse varchar(70)); 
create table LOCATION( 
numexemplaire number(8) references exemplaire(numexemplaire), 
datelocation date, 
login varchar(30) references clientt(login), 
dateenvoi date not null, 
dateretour date not null, 
primary key(numexemplaire,datelocation)); 
1/CREATE OR REPLACE FUNCTION nbreFilms(realisateur_id number) 
RETURN number 
IS 
    total_films number; 
BEGIN 
    SELECT COUNT(*) 
    INTO total_films 
    FROM film 
    WHERE realisateur = realisateur_id; 
 
    RETURN total_films; 
END; 
/ 
*********************** 
DECLARE 
    nombre_films number; 
BEGIN 
    nombre_films := nbreFilms(1); 
    dbms_output.put_line('Le réalisateur numéro 1091 a tourné ' || nombre_films || ' films.'); 
END; 
/ 
2/b/CREATE OR REPLACE FUNCTION Pourcentage(n1 IN NUMBER, n2 IN NUMBER) 
RETURN NUMBER 
IS 
    pct NUMBER; 
BEGIN 
    IF n2 = 0 THEN 
        RETURN NULL; 
    ELSE 
        pct := (n1 / n2) * 100; 
        RETURN ROUND(pct, 2); 
    END IF; 
EXCEPTION 
    WHEN OTHERS THEN 
        RETURN NULL; 
END; 
/ 



2/c/DECLARE 
    n1 CONSTANT NUMBER := 5; -- Définir la valeur de n1 
    n2 CONSTANT NUMBER := 10; -- Définir la valeur de n2 
BEGIN 
    FOR bonus_rec IN (SELECT login, nbrExLoues FROM tableBonus) LOOP 
        IF bonus_rec.nbrExLoues > 0 THEN 
            IF bonus_rec.nbrExLoues < n1 THEN 
                UPDATE tableBonus 
                SET bonus = 0.1 
                WHERE login = bonus_rec.login; 
            ELSIF bonus_rec.nbrExLoues >= n1 AND bonus_rec.nbrExLoues < n2 THEN 
                UPDATE tableBonus 
                SET bonus = 0.2 
                WHERE login = bonus_rec.login; 
            ELSE 
                UPDATE tableBonus 
                SET bonus = 0.4 
                WHERE login = bonus_rec.login; 
            END IF; 
        ELSE 
            UPDATE tableBonus 
            SET bonus = 0 
            WHERE login = bonus_rec.login; 
        END IF; 
    END LOOP; 
    COMMIT; 
END; 
select * from tablebonus;
/ 
2/c/DECLARE 
    n1 CONSTANT NUMBER := 2; -- Définir la valeur de n1 
    n2 CONSTANT NUMBER := 10; -- Définir la valeur de n2 
BEGIN 
    FOR bonus_rec IN (SELECT login, nbrExLoues FROM tableBonus) LOOP 
        IF bonus_rec.nbrExLoues > 0 THEN 
            IF bonus_rec.nbrExLoues < n1 THEN 
                UPDATE tableBonus 
                SET bonus = 0.1 
                WHERE login = bonus_rec.login; 
            ELSIF bonus_rec.nbrExLoues >= n1 AND bonus_rec.nbrExLoues < n2 THEN 
                UPDATE tableBonus 
                SET bonus = 0.2 
                WHERE login = bonus_rec.login; 
            ELSE 
                UPDATE tableBonus 
                SET bonus = 0.4 
                WHERE login = bonus_rec.login; 
            END IF; 
        ELSE 
            UPDATE tableBonus 
            SET bonus = 0 
            WHERE login = bonus_rec.login; 
        END IF; 
    END LOOP; 
    COMMIT; 
END; 
/ 

2/d/SELECT c.nomclient, c.prenomclient, b.bonus 
FROM clientt c 
JOIN tableBonus b ON c.login = b.login; 
select * from clientt;
Q3// 
a/CREATE OR REPLACE FUNCTION Pourcentage(n1 IN NUMBER, n2 IN NUMBER) 
RETURN NUMBER 
IS 
    pct NUMBER; 
BEGIN 
    IF n2 = 0 THEN 
        RETURN NULL; 
    ELSE 
        pct := (n1 / n2) * 100; 
        RETURN ROUND(pct, 2); 
    END IF; 
END; 
/ 
b/CREATE OR REPLACE FUNCTION nbrExSupport(n IN NUMBER, c IN VARCHAR2) 
RETURN NUMBER 
IS 
    total_exemplaires NUMBER; 
BEGIN 
    IF c = 'ANY' THEN 
        SELECT COUNT(*) 
        INTO total_exemplaires 
        FROM exemplaire 
        WHERE numfilm = n; 
    ELSE 
        SELECT COUNT(*) 
        INTO total_exemplaires 
        FROM exemplaire 
        WHERE numfilm = n AND codesupport = c; 
    END IF; 
 
    RETURN total_exemplaires; 
EXCEPTION 
    WHEN NO_DATA_FOUND THEN 
        RETURN 0; -- Si aucun enregistrement trouvé, retourner 0 
END; 
/ 
c/CREATE TABLE statistiques ( 
    numFilm NUMBER, 
    nbrEx NUMBER, 
    pctgeDVD NUMBER(8,2), 
    pctgeVHS NUMBER(8,2) 
); 
d/CREATE OR REPLACE PROCEDURE remplirStat IS 
BEGIN 
    -- Supprimer toutes les lignes existantes de la table statistiques 
    DELETE FROM statistiques; 
 
    -- Boucle pour chaque film 
    FOR film_rec IN (SELECT numfilm FROM film) LOOP 
        DECLARE 
            v_numfilm NUMBER := film_rec.numfilm; 
            v_nbrEx NUMBER; 
            v_nbrDVD NUMBER; 
            v_nbrVHS NUMBER; 
            v_pctgeDVD NUMBER; 
            v_pctgeVHS NUMBER; 
        BEGIN 
            -- Nombre total d'exemplaires du film 
            SELECT COUNT(*) 
            INTO v_nbrEx 
            FROM exemplaire 
            WHERE numfilm = v_numfilm; 
 
            -- Nombre d'exemplaires DVD du film 
            SELECT COUNT(*) 
            INTO v_nbrDVD 
            FROM exemplaire 
            WHERE numfilm = v_numfilm AND codesupport = 'DVD'; 
 
            -- Nombre d'exemplaires VHS du film 
            SELECT COUNT(*) 
            INTO v_nbrVHS 
            FROM exemplaire 
            WHERE numfilm = v_numfilm AND codesupport = 'VHS'; 
 
            -- Calcul des pourcentages 
            IF v_nbrEx > 0 THEN 
                v_pctgeDVD := (v_nbrDVD / v_nbrEx) * 100; 
                v_pctgeVHS := (v_nbrVHS / v_nbrEx) * 100; 
            ELSE 
                v_pctgeDVD := 0; 
                v_pctgeVHS := 0; 
            END IF; 
 
            -- Insertion des données dans la table statistiques 
            INSERT INTO statistiques (numFilm, nbrEx, pctgeDVD, pctgeVHS) 
            VALUES (v_numfilm, v_nbrEx, v_pctgeDVD, v_pctgeVHS); 
        EXCEPTION 
            WHEN NO_DATA_FOUND THEN 
                -- Si aucune donnée trouvée pour le film, passer au suivant 
                CONTINUE; 
        END; 
    END LOOP; 
 
    -- Valider les modifications 
    COMMIT; 
END; 
/ 
******* 
4/a/CREATE OR REPLACE PACKAGE statistics AS 
    -- Fonction pour calculer le pourcentage d'exemplaires sans problème
    FUNCTION pct_exemplaires_sans_probleme RETURN NUMBER;
END statistics;
/
 
/ 
 
CREATE OR REPLACE PACKAGE BODY statistics AS 
    PROCEDURE count_films_no_copies(p_count OUT NUMBER) IS 
    BEGIN 
        SELECT COUNT(*) INTO p_count 
        FROM film f 
        WHERE NOT EXISTS ( 
            SELECT 1 
            FROM exemplaire e 
            WHERE e.numfilm = f.numfilm 
        ); 
    END count_films_no_copies; 
END statistics; 
/ 
 
DECLARE 
    no_copies_count NUMBER; 
BEGIN 
    statistics.count_films_no_copies(no_copies_count); 
    DBMS_OUTPUT.PUT_LINE('Number of films without copies: ' || no_copies_count); 
END; 
/
//4/b
CREATE OR REPLACE PACKAGE statistics AS 
    -- Fonction pour calculer le pourcentage d'exemplaires sans problème
    FUNCTION pct_exemplaires_sans_probleme RETURN NUMBER;
END statistics;
/

CREATE OR REPLACE PACKAGE BODY statistics AS 
    -- Fonction pour calculer le pourcentage d'exemplaires sans problème
    FUNCTION pct_exemplaires_sans_probleme RETURN NUMBER IS 
        total_exemplaires NUMBER;
        total_sans_probleme NUMBER;
        pct NUMBER;
    BEGIN
        -- Nombre total d'exemplaires
        SELECT COUNT(*) INTO total_exemplaires FROM exemplaire;
        
        -- Nombre d'exemplaires sans problème
        SELECT COUNT(*) INTO total_sans_probleme 
        FROM exemplaire 
        WHERE probleme IS NULL;

        -- Calcul du pourcentage
        IF total_exemplaires > 0 THEN
            pct := (total_sans_probleme / total_exemplaires) * 100;
        ELSE
            pct := 0;
        END IF;

        RETURN pct;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN NULL; -- Gestion de l'exception
    END pct_exemplaires_sans_probleme;
END statistics;
/

//5/
CREATE TABLE trace (
    numLog INTEGER,
    message VARCHAR2(255)
);

CREATE OR REPLACE FUNCTION nbValLog RETURN INTEGER AS
    nbval INTEGER;
BEGIN
    SELECT COUNT(*) INTO nbval FROM TRACE;
    RETURN nbval;
END;

//Q5 réponse textuelle
// Q6
CREATE OR REPLACE TRIGGER TRIG_PREVENT_DELETE
BEFORE DELETE ON LOCATION
FOR EACH ROW
DECLARE
    -- Définir ici les utilisateurs autorisés à supprimer
    authorized_user VARCHAR2(30) := 'admin'; -- Utilisateur autorisé

BEGIN
    -- Vérifier si l'utilisateur est autorisé
    IF USER <> authorized_user THEN
        -- Empêcher la suppression en annulant l'opération
        RAISE_APPLICATION_ERROR(-20001, 'Attention, utilisateur non autorisé !');
    END IF;

    -- Si l'utilisateur est autorisé, permettre la suppression
    -- Aucune action spécifique n'est nécessaire ici, car la suppression se poursuivra si l'utilisateur est autorisé.
END;

select * from location;

DELETE FROM location WHERE numexemplaire = 1001;
ROLLBACK;

//Q7/
CREATE OR REPLACE TRIGGER TRIG_LOCATION_MODIFICATION
BEFORE UPDATE OR INSERT ON LOCATION
FOR EACH ROW
DECLARE
    v_old_login VARCHAR2(30);
    v_old_numexemplaire NUMBER;
    v_old_datelocation DATE;
BEGIN
    IF UPDATING THEN
        -- Récupérer les anciennes valeurs
        v_old_login := :OLD.login;
        v_old_numexemplaire := :OLD.numexemplaire;
        v_old_datelocation := :OLD.datelocation;

        -- Afficher les anciennes valeurs
        DBMS_OUTPUT.PUT_LINE('Anciennes valeurs - Login: ' || v_old_login || ', Numéro d''exemplaire: ' || v_old_numexemplaire || ', Date de location: ' || TO_CHAR(v_old_datelocation, 'DD-MON-YYYY'));
    END IF;

    -- Vérifier les conditions avant modification
    IF :NEW.dateenvoi IS NOT NULL AND DELETING THEN
        -- Refuser la suppression si la date d'envoi est renseignée
        RAISE_APPLICATION_ERROR(-20001, 'Impossible de supprimer une location avec une date d''envoi renseignée.');
    ELSIF :NEW.dateretour IS NOT NULL AND (:NEW.dateenvoi IS NULL OR :NEW.dateenvoi = '') THEN
        -- Refuser la mise à jour ou l'insertion sans date d'envoi mais avec une date de retour
        RAISE_APPLICATION_ERROR(-20002, 'Impossible de modifier ou insérer une location avec une date de retour mais sans date d''envoi.');
    ELSE
        -- Afficher un message pour les autres cas
        DBMS_OUTPUT.PUT_LINE('Modification autorisée pour la location avec Login: ' || :NEW.login || ', Numéro d''exemplaire: ' || :NEW.numexemplaire || ', Date de location: ' || TO_CHAR(:NEW.datelocation, 'DD-MON-YYYY'));
    END IF;
END;
/














-- Insertions
INSERT INTO individu (numindividue, nomindividu, prenomindividu) VALUES (1, 'Spielberg', 'Steven');
INSERT INTO individu (numindividue, nomindividu, prenomindividu) VALUES (2, 'Nolan', 'Christopher');
INSERT INTO individu (numindividue, nomindividu, prenomindividu) VALUES (3, 'Coppola', 'Francis');

DESC exemplaire;

INSERT INTO film (numfilm, titre, realisateur) VALUES (101, 'Jurassic Park', 1); -- Réalisé par Spielberg
INSERT INTO film (numfilm, titre, realisateur) VALUES (102, 'Inception', 2); -- Réalisé par Nolan
INSERT INTO film (numfilm, titre, realisateur) VALUES (103, 'The Godfather', 3); -- Réalisé par Coppola

INSERT INTO exemplaire (numexemplaire, numfilm, codesupport, vo, probleme, detailsupport)
VALUES (1001, 101, 'DVD', 'Oui', NULL, 'Bonne condition');
INSERT INTO exemplaire (numexemplaire, numfilm, codesupport, vo, probleme, detailsupport)
VALUES (1002, 101, 'VHS', 'Non', 'Rayures', 'Besoin de réparation');
INSERT INTO exemplaire (numexemplaire, numfilm, codesupport, vo, probleme, detailsupport)
VALUES (1003, 102, 'DVD', 'Oui', NULL, 'Excellent état');


INSERT INTO clientt (login, nomclient, prenomclient, motdepasse, adresse) VALUES ('john_doe', 'Doe', 'John', 'secret123', '123 Rue des Roses');
INSERT INTO clientt (login, nomclient, prenomclient, motdepasse, adresse) VALUES ('jane_smith', 'Smith', 'Jane', 'password456', '456 Avenue des Lilas');


INSERT INTO LOCATION (numexemplaire, datelocation, login, dateenvoi, dateretour) VALUES (1001, TO_DATE('2024-05-01', 'YYYY-MM-DD'), 'john_doe', TO_DATE('2024-05-01', 'YYYY-MM-DD'), TO_DATE('2024-05-05', 'YYYY-MM-DD'));
INSERT INTO LOCATION (numexemplaire, datelocation, login, dateenvoi, dateretour) VALUES (1002, TO_DATE('2024-05-02', 'YYYY-MM-DD'), 'jane_smith', TO_DATE('2024-05-02', 'YYYY-MM-DD'), TO_DATE('2024-05-06', 'YYYY-MM-DD'));


--verification
DESC exemplaire;
DESC CLIENTT;
DESC FILM;
DESC INDIVIDU;
DESC LOCATION;

Select * from exemplaire;
Select * from CLIENTT;
Select * from FILM;
Select *from INDIVIDU;
Select * from LOCATION;

--test Q2/a
CREATE TABLE tableBonus (
    login VARCHAR2(30) PRIMARY KEY,
    bonus NUMBER(8,2),
    nbrExLoues NUMBER(8)
);
select * from tablebonus;
UPDATE tableBonus
SET login = 'john_doe'
WHERE login = 'utilisateur1';
UPDATE tableBonus
SET login = 'jane_smith'
WHERE login = 'utilisateur2';
--

DECLARE
    v_result NUMBER;
BEGIN
    -- Appel de la fonction Pourcentage avec des valeurs spécifiques
    v_result := Pourcentage(20, 50); -- Appel avec n1 = 20 et n2 = 50
    
    -- Affichage du résultat
    IF v_result IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('Le pourcentage est : ' || v_result);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Erreur : Division par zéro.');
    END IF;
END;


-- test q2 /b
-- Déclaration de variables pour les tests
DECLARE
    result1 NUMBER;
    result2 NUMBER;
    result3 NUMBER;
BEGIN
    -- Appel de la fonction avec différents scénarios

    -- Scénario 1: n1 = 10, n2 = 5 (n2 non nul)
    result1 := Pourcentage(10, 5);
    DBMS_OUTPUT.PUT_LINE('Pourcentage(10, 5) = ' || result1);

    -- Scénario 2: n1 = 0, n2 = 8 (n1 nul)
    result2 := Pourcentage(0, 8);
    DBMS_OUTPUT.PUT_LINE('Pourcentage(0, 8) = ' || result2);

    -- Scénario 3: n1 = 12, n2 = 0 (n2 nul)
    result3 := Pourcentage(12, 0);
    DBMS_OUTPUT.PUT_LINE('Pourcentage(12, 0) = ' || result3);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Une erreur s\'est produite lors de l\'exécution de la fonction Pourcentage.');
END;
/


--test q3 a
DECLARE
    v_n1 NUMBER := 25;
    v_n2 NUMBER := 50;
    v_result NUMBER;
BEGIN
    -- Appel de la fonction Pourcentage avec les valeurs v_n1 et v_n2
    v_result := Pourcentage(v_n1, v_n2);
    
    -- Affichage du résultat
    DBMS_OUTPUT.PUT_LINE('Le pourcentage est : ' || v_result);
END;
/
--test Q3 b
DECLARE
    v_numfilm NUMBER := 101;  -- Numéro de film à rechercher
    v_codesupport VARCHAR2(8) := 'DVD';  -- Code de support à rechercher
    v_result NUMBER;

BEGIN
    -- Appel de la fonction nbrExSupport avec les valeurs v_numfilm et v_codesupport
    v_result := nbrExSupport(v_numfilm, v_codesupport);

    -- Affichage du résultat
    DBMS_OUTPUT.PUT_LINE('Nombre d''exemplaires avec le code de support ' || v_codesupport || ' pour le film ' || v_numfilm || ' : ' || v_result);
END;

--test 3d
DECLARE
    v_numfilm NUMBER;
    v_nbrEx NUMBER;
    v_nbrDVD NUMBER;
    v_nbrVHS NUMBER;
    v_pctgeDVD NUMBER;
    v_pctgeVHS NUMBER;
BEGIN
    -- Supprimer toutes les lignes existantes de la table statistiques
    DELETE FROM statistiques;

    -- Boucle pour chaque film
    FOR film_rec IN (SELECT numfilm FROM film) LOOP
        -- Récupérer le numéro de film de la boucle courante
        v_numfilm := film_rec.numfilm;

        -- Nombre total d'exemplaires du film
        SELECT COUNT(*)
        INTO v_nbrEx
        FROM exemplaire
        WHERE numfilm = v_numfilm;

        -- Nombre d'exemplaires DVD du film
        SELECT COUNT(*)
        INTO v_nbrDVD
        FROM exemplaire
        WHERE numfilm = v_numfilm AND codesupport = 'DVD';

        -- Nombre d'exemplaires VHS du film
        SELECT COUNT(*)
        INTO v_nbrVHS
        FROM exemplaire
        WHERE numfilm = v_numfilm AND codesupport = 'VHS';

        -- Calcul des pourcentages
        IF v_nbrEx > 0 THEN
            v_pctgeDVD := (v_nbrDVD / v_nbrEx) * 100;
            v_pctgeVHS := (v_nbrVHS / v_nbrEx) * 100;
        ELSE
            v_pctgeDVD := 0;
            v_pctgeVHS := 0;
        END IF;

        -- Insertion des données dans la table statistiques
        INSERT INTO statistiques (numFilm, nbrEx, pctgeDVD, pctgeVHS)
        VALUES (v_numfilm, v_nbrEx, v_pctgeDVD, v_pctgeVHS);
    END LOOP;

    -- Valider les modifications
    COMMIT;

    -- Afficher un message de réussite
    DBMS_OUTPUT.PUT_LINE('La procédure remplirStat a été exécutée avec succès.');
EXCEPTION
    -- Gérer les exceptions
    WHEN NO_DATA_FOUND THEN
        -- En cas d'absence de données, afficher un message approprié
        DBMS_OUTPUT.PUT_LINE('Aucune donnée trouvée pour le film.');
    WHEN OTHERS THEN
        -- En cas d'autres erreurs, afficher le message d'erreur
        DBMS_OUTPUT.PUT_LINE('Erreur lors de l''exécution de la procédure remplirStat : ' || SQLERRM);
END;
select * from statistiques;
/
-- test Q4 a

--test Q4 b
DECLARE
    pourcentage NUMBER;
BEGIN
    pourcentage := statistics.pct_exemplaires_sans_probleme;
    
    IF pourcentage IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('Pourcentage d''exemplaires sans problème : ' || pourcentage || '%');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Erreur lors du calcul du pourcentage.');
    END IF;
END;

select * from statistiques;
--test Q5 partie 1
DECLARE
    v_nbVal INTEGER;
BEGIN
    v_nbVal := nbValLog();
    DBMS_OUTPUT.PUT_LINE('Nombre de lignes dans la table trace : ' || v_nbVal);
END;

SELECT nbValLog() AS nombre_de_lignes FROM DUAL;

-- test Q7
-- test insertion
INSERT INTO LOCATION (numexemplaire, datelocation, login, dateenvoi)
VALUES (1001, SYSDATE, 'john_doe', SYSDATE);

-- test mise à jour
-- Créer une location avec une date d'envoi renseignée
INSERT INTO LOCATION (numexemplaire, datelocation, login, dateenvoi)
VALUES (1003, SYSDATE, 'admin', SYSDATE);

-- Tentative de suppression d'une location avec une date d'envoi renseignée (devrait être refusée)
DELETE FROM LOCATION WHERE numexemplaire = 1003;

-- Mise à jour d'une location avec une date de retour renseignée mais sans date d'envoi (devrait être refusée)
UPDATE LOCATION SET dateretour = SYSDATE + 7 WHERE numexemplaire = 1003;

--test mise à jours autorisé
INSERT INTO LOCATION (numexemplaire, datelocation, login, dateenvoi, dateretour)
VALUES (1004, SYSDATE, 'admin', SYSDATE, SYSDATE + 7);

UPDATE LOCATION SET dateretour = SYSDATE + 10 WHERE numexemplaire = 1004;

