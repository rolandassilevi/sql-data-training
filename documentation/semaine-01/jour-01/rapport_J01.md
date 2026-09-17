# J01 - Audit professionnel PostgreSQL sous Windows 11

**Parcours :** SQL / Data - 16 semaines  
**Semaine :** 1  
**Jour :** 1  
**Durée prévue :** 60 min  
**Durée réelle :** 77 min  
**Écart :** +17 min (+28,3 %)  
**Statut :** Terminé  
**Nature de la séance :** Audit en lecture seule - aucune modification du serveur

## 1. Objectifs
- Vérifier l'installation du client et du serveur PostgreSQL.
- Contrôler le service Windows et les processus PostgreSQL.
- Valider une connexion avec `psql`.
- Identifier la version, l'hôte, le port, la base, le rôle, le répertoire de données et le `search_path`.
- Examiner les bases, rôles, schémas et tables visibles.
- Recouper les résultats dans pgAdmin.
- Distinguer PowerShell, méta-commandes `psql` et SQL.
- Documenter les observations, avertissements et apprentissages.

## 2. Résultats principaux

| Élément | Résultat |
|---|---|
| Client psql | PostgreSQL 17.5 |
| Service Windows | `postgresql-x64-17` - Running |
| Processus PostgreSQL | 12 observés |
| Serveur | PostgreSQL 17.5, x86_64-windows, 64-bit |
| Hôte de la session | `localhost` / `::1` |
| Port | `5432` |
| Base active | `postgres` |
| Utilisateur connecté | `postgres` |
| Rôle postgres | Superuser, Create role, Create DB, Replication, Bypass RLS |
| Data directory | `C:/Program Files/PostgreSQL/17/data` |
| Search path | `"$user", public` |
| Schéma visible dans `postgres` | `public` |
| Tables utilisateur visibles | Aucune |
| Modification effectuée | Aucune |

Bases observées avec `\l` : `db_rcw`, `examen_resultats_db`, `pizza_db`,
`postgres`, `smart_ao`, `template0`, `template1`.

## 3. Procédure exécutée

### 3.1 Audit Windows / PowerShell
```powershell
psql --version
Get-Service *postgres*
Get-Process postgres -ErrorAction SilentlyContinue
```

Résultats :
- `psql (PostgreSQL) 17.5`
- service `postgresql-x64-17` en état `Running`
- 12 processus `postgres` observés

La présence de plusieurs processus PostgreSQL est normale pour une architecture
serveur multiprocessus. Les rôles exacts des processus n'ont pas été déduits à
partir de `Get-Process` seul.

### 3.2 Connexion psql
```text
psql -U postgres
```

Connexion réussie à PostgreSQL 17.5.

Avertissement observé :
```text
WARNING: Console code page (850) differs from Windows code page (1252)
8-bit characters might not work correctly.
```

**Diagnostic :** avertissement d'encodage de la console Windows, non bloquant
pour la séance. Aucune correction n'a été appliquée pendant J01.

### 3.3 Méta-commandes psql
```text
\conninfo
\l
\du
\dn
\dt
```

`\conninfo` a confirmé :
- database : `postgres`
- user : `postgres`
- host : `localhost`
- address : `::1`
- port : `5432`

`\du` a montré un seul rôle visible : `postgres`, doté de privilèges élevés.

`\dn` a montré le schéma `public`, propriétaire `pg_database_owner`.

`\dt` a retourné :
```text
Did not find any relations.
```
Ce résultat n'est pas une erreur : aucune table utilisateur visible n'était
présente dans le contexte courant.

### 3.4 SQL / paramètres serveur
```sql
SELECT version();

SELECT
    current_database() AS database_name,
    current_user AS connected_user;

SHOW port;
SHOW data_directory;
SHOW search_path;
```

Résultats :
```text
PostgreSQL 17.5 on x86_64-windows, compiled by msvc-19.44.35209, 64-bit
database_name  = postgres
connected_user = postgres
port           = 5432
data_directory = C:/Program Files/PostgreSQL/17/data
search_path    = "$user", public
```

### 3.5 Requête d'audit consolidée
```sql
SELECT
    current_database() AS database_name,
    current_user AS connected_user,
    inet_server_addr() AS server_address,
    inet_server_port() AS server_port,
    version() AS postgresql_version;
```

Résultat :
```text
database_name  : postgres
connected_user : postgres
server_address : ::1
server_port    : 5432
version        : PostgreSQL 17.5 on x86_64-windows, compiled by msvc-19.44.35209, 64-bit
```

## 4. Vérification graphique avec pgAdmin
L'arborescence de pgAdmin a confirmé les bases visibles et la structure :

```text
Serveur PostgreSQL
  -> Base de données
     -> Schéma
        -> Objets
           -> Tables / Views / Functions / Sequences / ...
```

Dans `postgres -> Schemas -> public`, le dossier `Tables` était vide, ce qui
recoupe le résultat de `\dt`.

Deux autres connexions enregistrées, `microgrid` et `microgrid1`, étaient visibles
dans pgAdmin. Leur présence dans pgAdmin ne suffit pas à conclure qu'il s'agit
de deux instances Windows actives supplémentaires ; aucune modification ou
investigation de ces connexions n'a été faite pendant J01.

## 5. Concepts acquis

### Serveur, base, schéma, table
```text
Machine Windows
  -> Service / instance PostgreSQL
     -> Base de données
        -> Schéma
           -> Table
              -> Lignes et colonnes
```

### Trois niveaux d'outils
```text
PowerShell             -> état Windows / processus / services
Méta-commandes psql    -> informations et fonctions du client psql
SQL / SHOW             -> requêtes et paramètres demandés au serveur
```

Exemples :
```text
Get-Service *postgres*     -> PowerShell / Windows
\conninfo                  -> psql
SELECT current_database()  -> SQL
SHOW port;                 -> paramètre PostgreSQL
```

### Search path
`"$user", public` signifie que, pour un objet non qualifié, PostgreSQL applique
son chemin de recherche. `"$user"` représente dynamiquement le nom du rôle
courant ; `public` vient ensuite.

### Principe du moindre privilège
Une application Python ne devrait pas utiliser quotidiennement le superutilisateur
`postgres`. Un rôle applicatif limité réduit l'impact possible d'une erreur,
d'un bug ou d'une compromission.

## 6. Challenge de compréhension
Le challenge comportait cinq questions : hiérarchie PostgreSQL, port 5432,
différence `\conninfo` / SQL, `search_path` et rôle superutilisateur.

**Résultat : 5/5 concepts acquis**, avec précisions terminologiques à consolider :
- un serveur PostgreSQL est plus précisément une instance/service du SGBD en fonctionnement ;
- le port 5432 appartient au service PostgreSQL, pas à une base particulière ;
- `\conninfo` est une méta-commande psql tandis que `SELECT current_database()` est du SQL ;
- le moindre privilège doit guider les futurs comptes applicatifs.

## 7. Captures
Les captures de la séance sont nommées selon la convention suivante :

- `J01-01_psql-version.png`
- `J01-02_postgresql-service.png`
- `J01-03_postgres-processes.png`
- `J01-04_psql-connection.png`
- `J01-05_conninfo.png`
- `J01-06_databases.png`
- `J01-07_roles.png`
- `J01-08_schemas.png`
- `J01-09_tables.png`
- `J01-10_server-version.png`
- `J01-11_current-session.png`
- `J01-12_server-port.png`
- `J01-13_data-directory.png`
- `J01-14_search-path.png`
- `J01-15_environment-audit.png`
- `J01-16_pgadmin-server-overview.png`
- `J01-17_pgadmin-postgres-public-schema.png`

Les deux captures pgAdmin disponibles dans la conversation sont incluses dans
le dossier `captures/`. Les captures terminal restantes peuvent être ajoutées
sous les noms ci-dessus.

## 8. Mesure de la séance
- Temps prévu : **60 min**
- Temps réel : **77 min**
- Écart : **+17 min**
- Écart relatif : **+28,3 %**
- Contrôles principaux : réussis
- Incident bloquant : aucun
- Modification du serveur : aucune
- Challenge conceptuel : 5/5

L'écart de temps est conservé comme donnée de référence. Les séances suivantes
permettront de mesurer l'évolution de la vitesse d'exécution et de l'autonomie.

## 9. Réutilisation pédagogique
**Sujet :** Auditer une installation PostgreSQL sous Windows 11 avec PowerShell,
psql et pgAdmin.

**Public :** débutant SQL/PostgreSQL, étudiant Data/BI, technicien évoluant vers
Data Engineering.

**Problème traité :** « PostgreSQL est installé : comment vérifier proprement
que le client, le service, le serveur et la connexion fonctionnent avant de
commencer un projet ? »

**Format court vidéo :** 5 à 8 min.  
**Module de formation :** 20 à 30 min.

Démonstration :
1. vérifier `psql --version` ;
2. contrôler le service ;
3. se connecter ;
4. utiliser `\conninfo`, `\l`, `\du`, `\dn`, `\dt` ;
5. exécuter l'audit SQL ;
6. recouper dans pgAdmin ;
7. expliquer le moindre privilège.

## 10. Conclusion
J01 valide un environnement PostgreSQL 17.5 fonctionnel sous Windows 11.
Le serveur existant contient déjà plusieurs bases : les exercices de formation
ne devront donc pas altérer ces environnements.

**Prochaine étape J02 :** créer un environnement de formation isolé
`sql_training_2033`, puis introduire les schémas `raw`, `staging`, `analytics`
et `sandbox`, en expliquant chaque opération avant exécution.
