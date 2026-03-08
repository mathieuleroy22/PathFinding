# Path Finding Algorithms (Julia)

Ce projet implémente plusieurs **algorithmes de recherche de chemin (path finding)** en Julia et permet de les tester sur différents jeux de données.

## Algorithmes implémentés

Les algorithmes sont définis dans le fichier `algo.jl` :

- Breadth-First Search (BFS)
- Dijkstra
- Glouton
- A*

Chaque algorithme permet de trouver un chemin entre un **point de départ** et un **point d'arrivée** dans un fichier map.

---

## Structure du projet

```
project/
│
├── src/ # Code source
| ├── algo.jl # Implémentation des algorithmes de path finding
| ├── pkg.jl # Installation des dépendances Julia
│
├── data/ # Jeux de données utilisés pour les tests
│ ├── dao-map/
│ ├── wc3maps512-map/
│
├── doc/ # Documentation du projet
│ ├── rapport.pdf
│
└── README.md
```
---

## Installation

### 1. Installer Julia

Télécharger Julia :  
https://julialang.org/downloads/

### 2. Installer les packages

Lancer Julia puis exécuter :

include("pkg.jl")

Le fichier pkg.jl installera automatiquement les packages nécessaires.

### 3. Utilisation

Exécuter le fichier contenant les algorithmes :

include("algo.jl")

Exemple d'utilisation :

algoBFS(fname, D, A)
algoDijkstra(fname, D, A)
algoGlouton(fname, D, A)
algoAstar(fname, D, A)

avec comme paramètres :

• fname | type : String | exemple : "didactic.map"
• D | type : Tuple{Int64, Int64} | exemple : (12, 14)
• A | type : Tuple{Int64, Int64} | exemple : (4, 5)

## Données

Les données de test sont disponibles dans le dossier data/.
Elles sont composées de fichier map dans lequel les algorithmes vont en extraire la carte.

## Documentation

La documentation détaillée du projet est disponible dans le dossier :

doc/

Elle contient :

la description des algorithmes

les choix d’implémentation

les résultats expérimentaux

## Projet réalisé dans le cadre de :

Projet d'informatique scientifique

Mathieu LEROY
