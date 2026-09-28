# Rapport J14 - Consolidation SQL et bilan de la Semaine 02

**Plan d'exécution SQL/Data - 16 semaines**  
**Semaine 02 - J14**  
**Date d'exécution : 28 septembre 2026**  
**Base :** `sql_training`  
**Table :** `raw.training_events`  
**PostgreSQL :** 17.5  
**Durée prévue :** 60-75 min  
**Timer de référence :** 75 min  
**Timer arrêté avec :** 35 min restantes  
**Durée réelle :** 40 min  
**Écart vs minimum prévu (60 min) :** -20 min  
**Écart vs référence de 75 min :** -35 min  
**Documentation et Git :** hors timer.

## 1. Objectif de J14

Consolider les acquis SQL de la Semaine 02 sans introduire de nouvelle notion majeure, mesurer l'autonomie sur le filtrage, les agrégations, `GROUP BY`, `HAVING`, `DISTINCT`, `CASE`, les fonctions texte, le tri et la construction d'un dataset analytique à partir d'un besoin métier.

## 2. Validation de l'environnement

Le dépôt Git était propre et synchronisé avec `origin/main`. Le point de départ était le commit `8c08b45` : `docs: complete J13 PostgreSQL text functions and data cleaning training`.

La connexion à `sql_training` a été confirmée. Contrôle initial :
- `total_rows` = 15 ;
- `source_count` = 4 ;
- `event_type_count` = 6 ;
- `min_event_id` = 1 ;
- `max_event_id` = 18 ;
- `total_value` = 1583.40.

## 3. J14-02 - Révision du filtrage

Requête reconstruite en autonomie avec `WHERE event_value >= 25`, puis `ORDER BY event_value DESC, event_id ASC`.

Résultat :
- 9 lignes ;
- premier `event_id` = 15 ;
- dernier `event_id` = 8.

Le filtrage intervient sur les lignes avant toute agrégation.

## 4. J14-03 - Agrégations et GROUP BY

Agrégation par `source_system` avec :
- `COUNT(*) AS event_count` ;
- `ROUND(AVG(event_value), 2) AS average_value` ;
- `ROUND(SUM(event_value), 2) AS total_value`.

Résultats :
- `microgrid_poc` : 7 événements, moyenne 190.99, total 1336.90 ;
- `manual_psql` : 1 événement, moyenne 125.50, total 125.50 ;
- `sensor_gateway` : 4 événements, moyenne 28.00, total 112.00 ;
- `tomra_training` : 3 événements, moyenne 3.00, total 9.00.

Prédictions exactes :
- 4 groupes ;
- première source : `microgrid_poc` ;
- source avec le plus de lignes : `microgrid_poc`.

## 5. J14-04 - HAVING

La requête précédente a été adaptée avec `HAVING COUNT(*) >= 3`.

Résultat : 3 groupes conservés :
- `microgrid_poc` ;
- `sensor_gateway` ;
- `tomra_training`.

Compréhension validée :
- `WHERE` filtre les lignes individuelles avant `GROUP BY` ;
- `GROUP BY` constitue les groupes ;
- `HAVING` filtre les groupes après agrégation.

Ainsi, `WHERE event_value >= 25` répond à la question « cette ligne entre-t-elle dans le calcul ? », tandis que `HAVING COUNT(*) >= 3` répond à « ce groupe agrégé doit-il être conservé ? ».

## 6. J14-05 - DISTINCT

La liste unique des couples `source_system` / `event_type` a été reconstruite sans reprendre le script J12.

Résultat : 6 couples distincts :
- `manual_psql` / `training_test` ;
- `microgrid_poc` / `current` ;
- `microgrid_poc` / `sensor_reading` ;
- `microgrid_poc` / `voltage` ;
- `sensor_gateway` / `temperature` ;
- `tomra_training` / `machine_alarm`.

## 7. J14-06 - CASE et fonctions texte

Construction autonome des colonnes :
- `source_label` avec `INITCAP(REPLACE(...))` ;
- `event_label` avec `INITCAP(REPLACE(...))` ;
- `value_category` avec `CASE`.

Règles :
- `event_value >= 200` -> `HIGH` ;
- `event_value >= 25` -> `MEDIUM` ;
- sinon -> `LOW`.

Prédictions et résultats :
- 15 lignes : exact ;
- 5 `HIGH` : exact ;
- 4 `MEDIUM` : exact ;
- 6 `LOW` : exact ;
- premier `event_id` = 15 : exact ;
- première catégorie = `HIGH` : exact.

Score de prédiction J14-06 : **6/6**.

## 8. J14-07 - Challenge autonome de fin de Semaine 02

Besoin métier : produire un dataset analytique regroupant les catégories d'événements significatives par système source.

Contraintes appliquées :
- exclusion des valeurs `< 25` avec `WHERE` ;
- transformation des identifiants techniques en libellés métier ;
- regroupement `source_system, event_type` ;
- calcul de `COUNT`, `AVG`, `SUM` ;
- conservation des groupes avec au moins 2 événements via `HAVING` ;
- classement par `total_value DESC`, puis `source_label ASC`.

Résultat :
- `Microgrid Poc | Voltage | 3 | 230.27 | 690.80`
- `Microgrid Poc | Sensor Reading | 2 | 309.58 | 619.15`
- `Sensor Gateway | Temperature | 3 | 29.07 | 87.20`

Prédictions exactes :
- nombre de groupes = 3 ;
- premier `source_label` = `Microgrid Poc` ;
- premier `event_label` = `Voltage` ;
- premier `event_count` = 3 ;
- premier `total_value` = 690.80.

Score de prédiction J14-07 : **5/5**.

Ce challenge démontre la capacité à traduire un besoin métier en chaîne SQL complète : filtrage des lignes -> transformation -> regroupement -> KPI -> filtrage des groupes -> classement -> dataset analytique.

## 9. Script reproductible

Script créé :

`documentation/semaine-02/jour-14/code/J14_week02_consolidation.sql`

Commande de validation :

```powershell
psql -U postgres -d sql_training -f ".\documentation\semaine-02\jour-14\code\J14_week02_consolidation.sql"
```

Résultats de validation :
- étape 01 : 15 / 4 / 6 / 1 / 18 / 1583.40 ;
- étape 02 : 9 lignes ;
- étape 03 : 4 groupes ;
- étape 04 : 3 groupes ;
- étape 05 : 6 couples ;
- étape 06 : 15 lignes ;
- étape 07 : 3 groupes ;
- étape 08 : 15 / 4 / 6 / 1 / 18 / 1583.40.

Aucune erreur SQL bloquante observée. Le contrôle final étant identique au contrôle initial, J14 est confirmé en lecture seule.

## 10. Captures à conserver

- `J14-01_environment-week02-validation.png`
- `J14-02_filtering-review.png`
- `J14-03_groupby-aggregation-review.png`
- `J14-04_having-review.png`
- `J14-05_distinct-review.png`
- `J14-06_case-text-functions-review.png`
- `J14-07_week02-autonomous-business-challenge.png`
- `J14-08_week02-consolidation-script-validation-1.png`
- `J14-08_week02-consolidation-script-validation-2.png` si disponible
- `J14-08_week02-consolidation-script-validation-3.png` si disponible

## 11. KPI J14

- Contrôle d'intégrité : réussi.
- Filtrage autonome : réussi.
- `GROUP BY` / agrégations : réussi.
- `HAVING` : réussi et expliqué correctement.
- `DISTINCT` : réussi.
- `CASE` + fonctions texte : réussi.
- Prédictions J14-06 : 6/6.
- Prédictions J14-07 : 5/5.
- Challenge métier intégré : réussi.
- Validation `psql -f` : réussie.
- Erreurs SQL bloquantes : 0.
- Dataset modifié : non.
- Autonomie : progression nette vers la composition de requêtes analytiques multi-notions.

## 12. Bilan de la Semaine 02

La Semaine 02 a fait progresser le travail depuis les filtres métier vers la production de datasets analytiques structurés.

Compétences consolidées :
- projections, alias et colonnes calculées ;
- `WHERE`, comparaisons, `BETWEEN`, `IN`, logique de filtrage ;
- `COUNT`, `MIN`, `MAX`, `AVG`, `SUM` ;
- `GROUP BY` ;
- différence entre colonne agrégée et non agrégée ;
- `WHERE` versus `HAVING` ;
- `ORDER BY` simple et multi-colonnes ;
- ordre déterministe ;
- `LIMIT`, `OFFSET`, Top-N ;
- `DISTINCT` simple et multi-colonnes ;
- expressions calculées et `ROUND()` ;
- `CASE` simple/multi-niveaux et logique métier ;
- fonctions texte `UPPER`, `LOWER`, `LENGTH`, `REPLACE`, `INITCAP`, `TRIM` ;
- concaténation `||` ;
- `COALESCE` ;
- combinaison de plusieurs notions dans une requête métier ;
- validation reproductible par script `psql -f` ;
- discipline de documentation et versionnement Git.

Le niveau démontré en fin de semaine n'est plus seulement « connaître une syntaxe » : il consiste à partir d'une question métier, choisir les opérations SQL nécessaires, prédire le résultat, exécuter, contrôler et documenter.

## 13. Durée

- Durée prévue : 60-75 min.
- Timer de référence : 75 min.
- Timer arrêté avec 35 min restantes.
- Durée réelle : **40 min**.
- Écart vs minimum prévu de 60 min : **-20 min**.
- Écart vs référence de 75 min : **-35 min**.
- Rapports et Git sont effectués après arrêt du timer et ne sont pas ajoutés à la durée réelle.

La durée inférieure à la plage prévue reflète ici une exécution rapide des exercices de consolidation déjà maîtrisés ; elle ne résulte pas d'une suppression du challenge ou de la validation reproductible.

## 14. Git / versionnement

Les opérations Git doivent être réalisées hors timer après génération et placement des rapports et captures.

Commit cible recommandé :

`docs: complete J14 and week 02 SQL consolidation review`

Contrôles attendus avant commit :
- uniquement les actifs J14 sont staged ;
- rapports MD/DOCX/PDF présents ;
- script SQL présent ;
- captures présentes.

Après commit et push :
- `HEAD -> main` et `origin/main` doivent pointer sur le même commit ;
- le working tree doit être propre.

## 15. Conclusion

J14 clôture la Semaine 02 sur une évaluation intégrée réussie. Le point le plus significatif est la capacité à construire sans requête modèle un dataset analytique combinant `WHERE`, fonctions texte, `GROUP BY`, agrégations, `HAVING` et `ORDER BY`, puis à prédire correctement les résultats avant exécution.

Le dataset d'entraînement reste intact à 15 lignes et 1583.40 de valeur totale.

## 16. Réutilisation pédagogique et portfolio

Les actifs J14 peuvent alimenter :
- un tutoriel « De la question métier au dataset analytique avec PostgreSQL » ;
- une vidéo sur la différence logique entre `WHERE`, `GROUP BY` et `HAVING` ;
- un exercice corrigé de consolidation SQL ;
- un mini-lab de préparation de données pour Power BI ;
- une démonstration portfolio de raisonnement SQL et de validation reproductible ;
- un module de formation montrant la progression filtre -> agrégation -> KPI -> dataset analytique.

## 17. Prochaine étape

Après clôture Git de J14, la suite du Plan d'exécution doit commencer à J15, sans ajouter de journée intermédiaire. La progression continuera vers des requêtes plus avancées et vers le profil cible Data/Analytics Engineer avec expertise SQL/PostgreSQL, modélisation, performance et architecture de données.
