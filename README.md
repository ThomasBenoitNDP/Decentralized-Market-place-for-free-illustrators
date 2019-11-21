# Decentralized-Market-place-for-free-illustrators
A decentralized application (Dapp) in solidity (Blockchain Ethereum)

Note pour Alyra: 

L'archive associée à ce readme:
	- le smartcontract AlyraDefi2.sol
	- (le readme.txt)
	- Un dossier ClientWeb
		- app.css
		- app.html
		- app.js

/!\ Mais vous pouvez retrouver ces documents sur:


Pour la partie interface graphique, vous pouvez la visualiser sur ce lien  (intéraction entre le smartcontract et client web) (partie 2): 
https://studio.ethereum.org/5dd3c49f26b473001233eb74


-------------------------------------------------------------------------------------------------------------------------------------------

Le but de ce projet est de créer une place de marché décentralisée pour illustrateurs indépendants. Si le sujet vous inspire, vous pouvez arrêter la lecture ici en créant une DApp avec :

    Un mécanisme de réputation

    Une liste de demandes et d’offres de services

    Un mécanisme de contractualisation avec dépôt préalable

La suite de ce document propose le détail d’une conception possible de ce type d’application.


## Mécanisme de réputation


    Pour représenter la réputation, nous allons associer chaque utilisateur à une valeur entière

    Lorsqu’un nouveau participant rejoint la plateforme, il appelle la fonction inscription() qui lui donne une réputation de 1. Il faut une réputation minimale pour accéder à la plupart des fonctionnalités. Un nom est aussi associé à l’adresse

    (optionnel) Les adresses peuvent être bannies par un administrateur de la plateforme. Dans ce cas la réputation est mise à 0 et l’adresse ajoutée à la liste des adresses bannies. Lors de l’inscription l’adresse est vérifiée.

## Liste de demandes


    Définir une structure de données pour chaque demande qui comprend:

        La rémunération (en wei)

        Le délai à compter de l’acceptation (en secondes)

        Une description de la tâche à mener (champ texte)

        L’état de la demande : OUVERTE, ENCOURS, FERMEE

            [Aide: Penser aux énumérations enum Choix { A, B, C }]

        Définir une réputation minimum pour pouvoir postuler

        Une liste de candidats

    Créer un tableau des demandes

    Créer une fonction ajouterDemande() qui permet à une entreprise de formuler une demande. L’adresse du demandeur doit être inscrite sur la plateforme. L’entreprise doit en même temps déposer l’argent sur la plateforme correspondant à la rémunération + 2% de frais pour la plateforme.

    Ecrire l’interface qui permet de lister ces offres
    
## Mécanisme de contractualisation

    Créer une fonction postuler() qui permet à un indépendant de proposer ses services. Il est alors ajouté à la liste des candidats

    Créer une fonction accepterOffre() qui permet à l’entreprise d’accepter un illustrateur. La demande est alors ENCOURS jusqu’à sa remise

    Ecrire une fonction livraison() qui permet à l’illustrateur de remettre le hash du lien où se trouve son travail. Les fonds sont alors automatiquement débloqués et peuvent être retirés par l’illustrateur. L’illustrateur gagne aussi un point de réputation
