# Multi-AMR Pathfinding (SIPP Algorithm)

Ce projet implémente un système de planification de chemins pour des robots mobiles autonomes (**AMR**) en Julia. Il repose sur l'algorithme **SIPP** (Safe Interval Path Planning), permettant de gérer les collisions spatio-temporelles entre robots.

---

## Fonctionnalités

- **Algorithme SIPP** : Recherche de chemin optimal dans des environnements dynamiques en utilisant des intervalles de sécurité.
- **Anti-Swap** : Logique avancée pour empêcher les robots de se croiser frontalement sur une même arête.
- **Planification Séquentielle** : Les robots sont planifiés un par un par ordre de priorité (temps auquel ils commencent leur mission), mettant à jour la carte pour les suivants.
- **Animation en temps réel** : Visualisation des déplacements avec le package `GLMakie`.
- **Export complet** : Génération de rapports textuels (`.txt`) et de rendus visuels agrandis (`.png`).

---

## Structure du projet

```
PathFinding/
 │
 ├── src/                        # Code source Julia
 │   ├── algo.jl                 # Code des différents algorithmes de Path Finding (BFS, Glouton, Dijkstra, Astar)
 │   ├── main.jl                 # Point d'entrée (orchestration)
 │   ├── shifting.jl             # Cœur algorithmique (astarAMR, successorSIPP)
 │   ├── datastructures.jl       # Définition des types (AMR, SafeInterval, Case)
 │   ├── openFile.jl             # Parsing des fichiers .map et instances
 │   ├── symbols.jl              # Gestion des symboles des cases
 │   ├── colors.jl               # Gestion des couleurs des AMR
 │   ├── pkg.jl                  # Gestion des packages nécessaires
 │   └── display.jl              # Fonctions d'exportation et d'affichage (TXT et Images)
 │
 ├── dat/                        # Jeux de données et instances (.map, .txt)
 │
 ├── out/                        # Résultats exportés (Images PNG, Logs)
 │
 ├── doc/                        # Documentation et rapport de projet
 │
 └── README.md
```
---

## Installation

### 1. Installer Julia

Télécharger Julia : 

&emsp; https://julialang.org/downloads/

### 2. Installer les packages

Télécharger le dépôt sur votre machine, puis lancer Julia et exécuter :

&emsp; include("pkg.jl")

Le fichier pkg.jl installera automatiquement les packages nécessaires.

### 3. Utilisation

Depuis le dossier "PathFinding/", exécuter la commande :

&emsp; include("main.jl")

Exemple d'utilisation :

• main("version1-instance1.txt")

• main("version2-instance1.txt")

-> le fichier '.txt' doit être dans le dossier "dat/robot-instance/"

---

## Données

Les données de test sont disponibles dans le dossier "dat/" :

• "robot-map/" -> ce dossier contient les cartes '.map' de la forme :

```
type octile
height 11
width 37
map
@@@.@@@@.@@@@.@@@@.@@@@.@@@@.@@@@.@@@
@S.................................S@
@S.................................S@
@S........@@.............@@........S@
@S.................................S@
@SS...............................SS@
@S.................................S@
@S........@@.............@@........S@
@S.................................S@
@S.................................S@
@@@.@@@@.@@@@.@@@@.@@@@.@@@@.@@@@.@@@
```


• "robot-instance/" -> ce dossier contient les instances '.txt' de la forme :

```
// Intance 1 sur la carte version 1
version1.map

// chaque ligne correspond à un AMR avec son temps de départ, son point de départ et son point d'arrivée
t=0 dock=(1,4) destination=(11,24)
t=3 dock=(11,9) destination=(1,14)
```
---
---

## Algorithmes de Path Finding

### • Exécution

Importer le fichier contenant les algorithmes :

&emsp; include("algo.jl")

Exemple d'utilisation :

algoBFS(fname, D, A)

algoDijkstra(fname, D, A)

algoGlouton(fname, D, A)

algoAstar(fname, D, A)

avec comme paramètres :

• fname | type : String | exemple : "didactic.map"

• D | type : Tuple{Int64, Int64} | exemple : (12, 14)

• A | type : Tuple{Int64, Int64} | exemple : (4, 5)

### • Données

Les données de test sont disponibles dans le dossier "dat/".

Elles sont composées de fichier map dans lequel les algorithmes vont en extraire la carte.

@article{sturtevant2012benchmarks,
  title={Benchmarks for Grid-Based Pathfinding},
  author={Sturtevant, N.},
  journal={Transactions on Computational Intelligence and AI in Games},
  volume={4},
  number={2},
  pages={144 -- 148},
  year={2012},
  url = {http://web.cs.du.edu/~sturtevant/papers/benchmarks.pdf},
}

### • Documentation

La documentation des algorthimes de "algo.jl"  est disponible dans le dossier :

doc/

Elle contient :

la description des algorithmes

les choix d’implémentation

les résultats expérimentaux

---
---

## Projet réalisé dans le cadre de :

Projet d'informatique scientifique

Sous la supervision de :  Xavier Gandibleux

Auteur : Mathieu LEROY
