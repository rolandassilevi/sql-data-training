# J02 - Création d'un environnement PostgreSQL isolé et introduction aux schémas

**Parcours :** Plan d'exécution SQL/Data - 16 semaines  
**Semaine :** 1  
**Jour :** J02  
**Durée prévue :** 60-75 min  
**Timer choisi :** 75 min  
**Durée réelle :** 84 min  
**Écart prévu/réel :** +9 min par rapport au timer de 75 min (+12 %) ; +9 min au-dessus de la borne haute prévue  
**Statut technique :** terminé  
**Statut documentaire :** terminé  
**Git :** volontairement reporté à la prochaine séance (création du dépôt, commit et push)

## 1. Objectifs
- Créer une base PostgreSQL isolée pour l'apprentissage.
- Comprendre la différence entre base de données et schéma.
- Construire les schémas `raw`, `staging`, `analytics` et `sandbox`.
- Comprendre les noms qualifiés `schema.table`.
- Expérimenter `search_path`, `current_schemas(false)` et `current_schema()`.
- Produire et résoudre volontairement une erreur de résolution de relation.
- Nettoyer l'expérimentation et valider l'état final dans psql et pgAdmin.
- Capitaliser le travail dans deux scripts SQL réutilisables.

## 2. État initial
La session a été vérifiée avant toute création :
- base active : `postgres`
- rôle : `postgres`
- adresse : `::1`
- port : `5432`
- `sql_training` n'existait pas
- 7 bases étaient visibles avec `\l`

## 3. Création de la base
Commande exécutée :
```sql
CREATE DATABASE sql_training;
```
Résultat : `CREATE DATABASE`.

Le plan proposait initialement `sql_training_2033`, mais la base effectivement créée est `sql_training`. Ce nom est retenu pour la suite du parcours.

Après création, `\l` affichait 8 bases. La nouvelle base utilise UTF8, `libc`, et les paramètres de locale hérités de l'environnement.

## 4. Connexion à la base
```text
\c sql_training
```

Validation :
```sql
SELECT
    current_database() AS database_name,
    current_user AS connected_user;
```

Résultat : `sql_training | postgres`.

`\dn` montrait initialement uniquement `public`.

## 5. Architecture des schémas
Commandes :
```sql
CREATE SCHEMA raw;
CREATE SCHEMA staging;
CREATE SCHEMA analytics;
CREATE SCHEMA sandbox;
```

Architecture finale :
```text
sql_training
├── public
├── raw
├── staging
├── analytics
└── sandbox
```

Rôles fonctionnels :
- **raw** : données reçues avec transformations minimales ;
- **staging** : nettoyage, typage, standardisation et préparation ;
- **analytics** : données prêtes pour KPI, analyses et BI ;
- **sandbox** : tests, prototypes et expérimentations.

Les quatre schémas créés ont pour propriétaire `postgres`. Le schéma `public` est associé à `pg_database_owner`.

## 6. Métadonnées avec information_schema
```sql
SELECT
    schema_name,
    schema_owner
FROM information_schema.schemata
WHERE schema_name IN ('raw', 'staging', 'analytics', 'sandbox')
ORDER BY schema_name;
```

Résultat : 4 lignes (`analytics`, `raw`, `sandbox`, `staging`) avec propriétaire `postgres`.

## 7. Search path : observation
État initial :
```sql
SHOW search_path;
-- "$user", public

SELECT current_schemas(false);
-- {public}
```

Interprétation :
- `SHOW search_path` affiche la configuration du chemin de recherche ;
- `current_schemas(false)` retourne les **schémas existants effectivement présents** dans ce chemin, hors schémas système implicites ;
- `current_schema()` retourne le premier schéma valide du chemin.

Correction issue du challenge : `current_schemas(false)` retourne des **schémas**, pas des rôles.

## 8. Expérience sur les noms qualifiés
Table temporaire d'apprentissage :
```sql
CREATE TABLE sandbox.test_search_path (
    id INTEGER
);
```

Accès qualifié :
```sql
SELECT * FROM sandbox.test_search_path;
```
Résultat : succès, 0 ligne.

Accès non qualifié :
```sql
SELECT * FROM test_search_path;
```
Résultat volontaire :
```text
ERROR: relation "test_search_path" does not exist
```

### Diagnostic
`sandbox` n'était pas dans le `search_path`. Le nom qualifié `sandbox.test_search_path` permettait de trouver l'objet explicitement, contrairement au nom simple `test_search_path`.

## 9. Résolution temporaire
```sql
SET search_path TO sandbox, public;
SHOW search_path;
SELECT current_schemas(false);
SELECT * FROM test_search_path;
SELECT current_schema();
```

Résultats :
- `search_path` : `sandbox, public`
- `current_schemas(false)` : `{sandbox,public}`
- la requête non qualifiée fonctionne désormais ;
- `current_schema()` : `sandbox`

La modification était limitée à la session.

## 10. Nettoyage et remise en état
```sql
DROP TABLE sandbox.test_search_path;
\dt sandbox.*

RESET search_path;
SHOW search_path;
SELECT current_schema();
\dn
```

Résultats :
- table expérimentale supprimée ;
- `sandbox` à nouveau vide ;
- `search_path` restauré à `"$user", public` ;
- `current_schema()` revenu à `public` ;
- les cinq schémas sont conservés.

Différence consolidée :
- `DELETE` supprime des lignes et conserve la structure de table ;
- `DROP TABLE` supprime l'objet table lui-même (structure et données).

## 11. Validation pgAdmin
pgAdmin confirme :
- `sql_training` existe ;
- `Schemas (5)` contient `analytics`, `public`, `raw`, `sandbox`, `staging` ;
- `sandbox > Tables` est vide après nettoyage.

Les résultats SQL, psql et pgAdmin sont donc cohérents.

## 12. Challenge J02
Résultat :
- Q1 base vs schéma : acquis
- Q2 rôles raw/staging/analytics/sandbox : acquis
- Q3 nom qualifié vs search_path : acquis
- Q4 commandes search_path : correction nécessaire puis acquise
- Q5 SET temporaire / RESET : acquis
- Q6 DELETE vs DROP TABLE : acquis

**Score pédagogique : 5/6 immédiatement acquis + 1/6 acquis après correction.**

Point à retenir :
```text
SHOW search_path              -> configuration
current_schemas(false)        -> schémas valides du chemin
current_schema()              -> premier schéma valide
```

## 13. Scripts capitalisés
`code/setup_training_database.sql` :
- création de la base ;
- connexion via `\connect` ;
- création des quatre schémas ;
- validation par SQL.

`code/exercice_search_path.sql` :
- état initial ;
- création de la table expérimentale ;
- erreur volontaire ;
- modification temporaire du `search_path` ;
- résolution ;
- nettoyage ;
- restauration.

Le script d'initialisation n'est pas encore idempotent : le relancer sur l'environnement existant produirait notamment une erreur `database already exists`. L'idempotence sera traitée ultérieurement.

## 14. Captures
Le dossier `captures/` contient les 14 captures réellement disponibles :
J02-01 à J02-13, avec deux captures complémentaires pour l'étape J02-09.

## 15. Git / versionnement
La structure locale `documentation/semaine-01/jour-02/code/` a été créée et les deux scripts sont visibles dans VS Code.

**Décision de séance :** la création du dépôt Git, le premier commit et le push sont reportés à la prochaine séance. Cette décision est explicitement documentée ; aucun commit fictif n'est déclaré pour J02.

## 16. KPI
| KPI | Valeur |
|---|---|
| Durée prévue | 60-75 min |
| Timer choisi | 75 min |
| Durée réelle | 84 min |
| Écart | +9 min vs timer 75 min (+12 %) |
| Base créée | 1 |
| Schémas Data créés | 4 |
| Expérience search_path | Réussie |
| Erreur volontaire diagnostiquée | 1 |
| Nettoyage final | Réussi |
| Challenge | 5/6 immédiat + 1 corrigé |
| Scripts capitalisés | 2 |
| Captures disponibles | 14 |
| Git commit/push | Reporté prochaine séance |

## 17. Potentiel pédagogique
**Tutoriel :** « PostgreSQL : créer une base isolée et comprendre les schémas ».  
**Vidéo courte :** 8-12 min sur `search_path` et l'erreur `relation does not exist`.  
**Module de formation :** 30-45 min sur base vs schéma, architecture raw/staging/analytics/sandbox, noms qualifiés et nettoyage contrôlé.

Le scénario d'erreur volontaire est particulièrement réutilisable :
**problème -> diagnostic -> correction -> validation -> remise en état**.

## 18. Conclusion
J02 a fait passer le parcours de l'audit à la construction. Une base isolée `sql_training` est maintenant disponible et structurée en quatre zones Data. Le comportement du `search_path` a été observé et testé concrètement.

**Prochaine séance :** Git (création du dépôt, état initial, ajout contrôlé, premier commit, dépôt distant/push), puis poursuite du plan du jour correspondant sans introduire de journée au-delà de J112.
