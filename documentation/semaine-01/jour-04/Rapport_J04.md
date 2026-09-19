# Rapport J04 - Première table PostgreSQL : DDL, contraintes, DML et versionnement Git

**Plan d'exécution SQL/Data - 16 semaines | Semaine 01 | Jour 04**

> Statut : TERMINÉ ET VALIDÉ

## 1. Synthèse de la séance

J04 a permis de passer d'un environnement PostgreSQL structuré en schémas à la création et à la validation d'une première table réelle dans le schéma raw. La séance a couvert le DDL, les types PostgreSQL, les contraintes d'intégrité, l'insertion de données, l'observation d'une violation NOT NULL, le comportement d'une colonne IDENTITY et la mise sous version du script SQL.

Résultat final : la table raw.training_events existe, deux lignes valides sont présentes, le phénomène de trou d'identité 1 -> 3 a été démontré, le script de création a été versionné et publié sur GitHub, et le dépôt local a été ramené à un état propre.

## 2. Temps de travail et KPI

Durée prévue : 90 min.

Durée réelle retenue à la clôture technique : 85 min 19 s.

Écart prévu/réel : -4 min 41 s (séance terminée 4 min 41 s avant la limite).

Taux d'utilisation du créneau : environ 94,8 %.

Comparaison utile : la séance a été contenue dans le créneau prévu, contrairement à J03 qui avait dépassé le temps prévu.

## 3. Objectifs J04

Valider l'état de la base sql_training et de ses schémas.

Créer une première table dans raw en utilisant des types et contraintes appropriés.

Comprendre PRIMARY KEY, NOT NULL, DEFAULT et GENERATED ALWAYS AS IDENTITY.

Effectuer un INSERT valide et provoquer volontairement une erreur de contrainte.

Observer la différence entre identité technique et nombre réel de lignes.

Transformer les commandes exécutées en script SQL reproductible.

Versionner le travail avec Git, pousser vers origin/main et vérifier le résultat sur GitHub.

## 4. État initial contrôlé

Connexion à sql_training avec le rôle postgres via psql.

search_path initial : "$user", public.

Schémas présents : analytics, public, raw, sandbox, staging.

Aucune table n'était présente dans raw avant J04.

## 5. DDL - création de raw.training_events

```sql
CREATE TABLE raw.training_events (
    event_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    event_type VARCHAR(50) NOT NULL,
    source_system VARCHAR(100) NOT NULL,
    event_value NUMERIC(12,2),
    event_timestamp TIMESTAMPTZ NOT NULL,
    ingested_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

La table contient six colonnes. event_id est une clé primaire générée automatiquement. event_type et source_system sont obligatoires. event_value est nullable. event_timestamp est obligatoire. ingested_at est automatiquement horodaté si aucune valeur n'est fournie.

## 6. Validation de la structure

\d raw.training_events a confirmé les types, la nullabilité, la valeur par défaut et l'index de clé primaire.

information_schema.columns a confirmé l'ordre des colonnes, les types, la nullabilité, le DEFAULT et le caractère IDENTITY.

information_schema.table_constraints a confirmé la PRIMARY KEY et les contraintes internes associées aux colonnes NOT NULL.

## 7. DML - première insertion valide

```sql
INSERT INTO raw.training_events (
    event_type,
    source_system,
    event_value,
    event_timestamp
)
VALUES (
    'training_test',
    'manual_psql',
    125.50,
    CURRENT_TIMESTAMP
);
```

Résultat : INSERT 0 1. PostgreSQL a généré event_id = 1 et ingested_at automatiquement.

## 8. Test négatif - violation NOT NULL

Une insertion volontairement incomplète a omis event_type. PostgreSQL a rejeté la ligne avec : null value in column "event_type" ... violates not-null constraint.

Le test confirme qu'une contrainte NOT NULL constitue une règle de qualité appliquée directement par le moteur de base de données. event_value pouvait être NULL, mais event_type ne le pouvait pas.

## 9. Challenge IDENTITY et trou de séquence

Après l'échec de l'insertion, une nouvelle ligne valide sensor_reading / microgrid_poc / 303.25 a été insérée.

Le nouvel enregistrement a reçu event_id = 3, alors que seules deux lignes existent. L'identifiant 2 avait été consommé lors de la tentative d'insertion échouée.

Conclusion : une identité/séquence garantit la génération d'identifiants, pas une numérotation continue sans trous.

## 10. COUNT(*) versus MAX(event_id)

```sql
SELECT COUNT(*) AS total_events,
       MIN(event_id) AS min_event_id,
       MAX(event_id) AS max_event_id
FROM raw.training_events;
```

Résultat observé : total_events = 2, min_event_id = 1, max_event_id = 3.

Le nombre de lignes doit être mesuré avec COUNT(*). MAX(event_id) ne doit pas être utilisé comme compteur métier.

## 11. Script SQL produit

Fichier : documentation/semaine-01/jour-04/code/J04_create_raw_training_events.sql.

Le fichier reprend le DDL de création de raw.training_events. Le test volontairement invalide n'a pas été placé dans ce script de construction, afin de distinguer construction, tests et validation.

## 12. Git et GitHub

Le staging a été contrôlé avant commit avec git status --short, git diff --cached --stat et git diff --cached --name-status.

Commit fonctionnel : f6b0b03 - feat: add J04 PostgreSQL DDL training.

Push du commit fonctionnel vers origin/main réussi.

Le script J04_create_raw_training_events.sql a été ouvert et vérifié sur GitHub.

Commit documentaire : 94a9dae - docs: add J04 PostgreSQL DDL evidence.

Second push réussi.

État final : branche main à jour avec origin/main ; nothing to commit, working tree clean.

## 13. Erreurs, diagnostic et résolution

Erreur SQL volontaire : violation NOT NULL sur event_type. Cause : colonne obligatoire omise. Résolution : comprendre la règle de qualité ; aucune correction artificielle de la contrainte.

Observation IDENTITY : l'ID 2 n'a pas été réutilisé après l'échec. Leçon : ne jamais supposer qu'une séquence est sans trous.

Erreur Git : git log --oneline --decorate --graph 5 a produit fatal: ambiguous argument '5'. Cause : 5 sans tiret a été interprété comme une révision ou un chemin. Correction : git log --oneline --decorate --graph -5.

Point documentaire : les captures créées après un commit deviennent elles-mêmes de nouveaux fichiers. La stratégie retenue est un commit fonctionnel, puis un commit documentaire final, afin d'éviter une boucle de commits de captures.

## 14. Captures J04

- `J04-01_postgresql-connection-and-schemas.png`
- `J04-02_initial-table-inventory.png`
- `J04-03_create-raw-training-events.png`
- `J04-04_table-structure-psql.png`
- `J04-05_table-metadata-and-constraints.png`
- `J04-06_first-valid-insert.png`
- `J04-07_not-null-constraint-violation.png`
- `J04-08_identity-gap-and-sql-challenge.png`
- `J04-09_count-vs-identity-validation.png`
- `J04-10_git-status-before-staging.png`
- `J04-11_git-staging-before-commit.png`
- `J04-12_j04-local-commit.png`
- `J04-13_j04-first-push.png`
- `J04-14_github-j04-sql-script.png`
- `J04-15_j04-final-git-status.png`
## 15. Validation des acquis

Acquis validés : création d'une table avec nom qualifié ; choix de types de base ; clé primaire ; NOT NULL ; DEFAULT ; IDENTITY ; INSERT ; SELECT ; ORDER BY DESC ; COUNT/MIN/MAX ; lecture des métadonnées ; staging sélectif Git ; commit ; push ; contrôle GitHub.

Point à consolider : distinguer systématiquement clé technique, séquence/identité et métrique métier ; continuer à écrire les scripts avant de multiplier les manipulations interactives.

## 16. Potentiel de réutilisation pédagogique

Tutoriel : « Créer sa première table PostgreSQL professionnelle avec contraintes et IDENTITY ».

Vidéo courte : 6 à 10 min sur CREATE TABLE, INSERT, NOT NULL et le trou d'identité.

Module de formation : 30 à 45 min avec démonstration psql, test d'erreur et mini-challenge.

Exercice réutilisable : demander aux apprenants de prédire COUNT(*) et MAX(id) après une insertion invalide suivie d'une insertion valide.

## 17. Conclusion et prochaine étape

J04 constitue la première brique de données persistantes du parcours. L'environnement sql_training possède désormais une table raw réelle et un script DDL versionné.

J05 poursuivra la semaine 01 en capitalisant sur cette base : manipulation structurée des données et workflow Git/documentation, conformément au plan de 16 semaines.

## Preuves visuelles intégrées dans les versions DOCX/PDF

- **J04-12_j04-local-commit.png** - Commit fonctionnel J04
- **J04-13_j04-first-push.png** - Historique Git, push et suivi origin/main
- **J04-14_github-j04-sql-script.png** - Script SQL J04 vérifié sur GitHub
- **J04-15_j04-final-git-status.png** - Commit documentaire, push et working tree clean