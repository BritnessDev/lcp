# TP0 - Copie paresseuse de fichiers (INF3173 Automne 2022)

L'objectif du TP est de développer `lcp` un utilitaire qui copie des fichiers paresseusement afin de faire moins d'écritures.

Ce TP0 a pour objectif de vous échauffer. La spécification et les choix d'implémentation vous sont imposés.
Il vous permet aussi d'utiliser des appels système spécifiques et d'observer leurs effets.


## Description de l'outil

Usage : `lcp [-b TAILLE] SOURCE... DESTINATION`

Copie le fichier SOURCE vers le fichier DESTINATION.
Si DESTINATION n'existe pas, il est créé.
Si DESTINATION existe et qu'il est un fichier, il est écrasé.
Si DESTINATION existe et qu'il est un répertoire, les fichiers sources y seront copiés.

❤ Pour simplifier le développement, les options et arguments seront toujours dans l'ordre indiqué.

### Option `-b`

Spécifie la taille des blocs à utiliser.
Par défaut, la taille est 32 octets (la copie se fait 32 octets à la fois).

TAILLE peut-être aussi grand que le système le permet (plusieurs Go par exemple).

### Copie paresseuse

Le programme `lcp` copie paresseusement. Si les fichiers sources et destinations sont identiques, aucune écriture n'est effectuée.
Si les deux fichiers diffèrent partiellement, seuls les blocs (option `-b`) qui diffèrent sont réécrits.

Exemple: Soient un fichier source qui contient `ABCDEF` et un fichier destination qui contient `ABCCEF` et une taille de blocs de 2. Seul le bloc `CD` sera copié pour remplacer le bloc `CC`.

Pour valider si les blocs sont identiques, une fonction `fletcher32` vous est fournise dans le fichier checksum.c et doit être utilisée.

### Détails d'implémentation

Le but du TP0 est de vous familiariser avec les appels systèmes et la gestion des erreurs.
Pour le traitement des fichiers, vous devrez utiliser `stat`, `open`, `read`, `write`, `lseek` et `close`.
En gros, pas de `fopen` ni de `FILE *`.

❤ N’hésitez pas à consulter le man pour le détail de l'utilisation des fonctions et appels système.


### Code de retour

Le code de retour est 0 si la copie s'est déroulée correctement (dans ce cas-là, le programme n'affiche rien).
En cas d'erreur, 1 est retourné.

Si l'erreur concerne un fichier (n'existe pas, droits, problème physique, etc.), un message d'erreur est affiché sur la sortie d'erreur, préfixé du nom du fichier (avec `perror`).

Si c'est une autre erreur (option invalide, pas assez de mémoire, etc.) un message d'erreur spécifique est affiché sur la sortie d'erreur (avec `fprintf` ou `perror`).


## Acceptation et remise du TP

### Acceptation

Pour accepter le TP vous devez **impérativement** :

* Cloner (fork) ce dépôt sur le gitlab départemental.
* Le rendre privé : dans `Settings` → `General` → `Visibility` → `Project visibility` → `Private`.
* Ajouter l'utilisateur `@pepospetitcl` comme mainteneur (oui, j'ai besoin de ce niveau de droits) : dans `Settings` → `Members` → `Invite member` → `@pepospetitcl`.

❤ Pour toute demande de support, merci d'utiliser le mattermost.


### Développement

Vous devez développer le programme `lcp` en C.
Le fichier source doit s'appeler `lcp.c` et être à la racine du dépôt.
Vu la taille du projet, tout doit rentrer dans ce seul fichier source.

Pour pouvez compiler avec `make` (le `Makefile` est fourni).

Vous pouvez vous familiariser avec le contenu du dépôt, en étudiant chacun des fichiers (README.md, Makefile, check.bats, .gitlab-ci.yml, etc.).

⚠️ À priori, il n'y a pas de raison de modifier un autre fichier du dépôt.
Si vous en avez besoin, ou si vous trouvez des bogues ou problèmes dans les autres fichiers, merci de me contacter.

### Remise

La remise s'effectue simplement en poussant votre code sur votre dépôt gitlab privé.
Seule la dernière version remise avant le **mercredi 05 octobre 23 h 55 ** sera considérée pour la correction.

⚠ ️**Intégrité académique**
Rendre public votre dépôt personnel ou votre code ici ou ailleurs ; ou faire des MR contenant votre code vers ce dépôt principal (ou vers tout autre dépôt accessible) sera considéré comme du **plagiat**.


### Intégration continue et mises à jour

Le système d'intégration continue vérifie votre TP à chaque `push`.
Vous pouvez vérifier localement avec `make check`.
Vous pouvez aussi regarder le reste du dépôt pour comprendre les détails des tests effectués.

⚠️ Pour que les tests s'exécutent correctement, il faut l'utilitaire `bats` entre autres.

Éventuellement, le dépôt public principal pourrait être mis à jour (ajout de tests, corrections mineures, etc.)
Vous pouvez mettre à jour votre code avec la version publique du TP (Ajouter le `git remote add` puis `git pull`.

❤ L'ajout de nouveaux tests dans l'intégration continue est une **bonne chose** pour vous.
Cela vous donne l'occasion de détecter et de corriger des bogues avant la date limite de la remise (et avant que les correcteurs notent votre code !)

⚠️ Attention, vérifier **≠** valider.
Ce n'est pas parce que les tests passent et que vous avez une pastille verte que votre TP est valide et vaut 100%.
Par contre, si les tests échouent, c'est généralement un bon indicateur de problèmes dans votre code.

❤ En cas de problème pour exécuter les tests sur votre machine, merci de 1. lire la documentation présente ici et 2. poser vos questions sur [/var/log](https://mattermost.info.uqam.ca/forum/channels/inf3173).
Attention toutefois à ne pas fuiter de l’information relative à votre solution (conception, morceaux de code, etc.)


## Critères de correction

* 100% pour les tests
* 100% la qualité du code: exactitude, robustesse, lisibilité, conception, commentaires, etc.
* La note finale est le produit des deux pourcentages

⚠️ Si votre programme **ne compile pas** ou **ne passe aucun test**, une note de **0 sera automatiquement attribuée**, et cela indépendamment de la qualité de code source ou de la quantité de travail mise estimée.

Comme le TP n'est pas si gros (de l'ordre de grandeur de la centaine de lignes), il est attendu un effort important sur le soin du code et la gestion des cas d'erreurs.


## Résumé du travail à réaliser

Voici un résumé des étapes à effectuer pour un TP0 réussi

1. acceptez le TP
   * forkez, mettez le dépôt privé, ajoutez @pepospetitcl comme mainteneur
   * ou utilisez l'interface web expérimentale
2. clonez sur votre machine (`git clone`)
3. développez l'application
   * Développez la fonctionnalité de façon modulaire et élégante
   * Nettoyez votre code : indentation, style, etc.
   * Documentez-le au fure et à mesure.
   * Assurez-vous de prendre en compte correctement les cas d'erreurs.
   * Évitez le code inutile ou redondant
4. testez avec `make check`
5. commitez/poussez (`git commit && git push`)
6. vérifiez l'état de l'intégration continue (vert=OK, rouge=investiguer, bleu=attendre)
8. nettoyez une dernière-fois votre code
9. comme vous avez commité et poussé au fure et à mesure, il n'y a pas de remise à faire : félicitations, vous avez livré de la valeur en continue en tout en réduisant le risque d'un TP échoué.
