/* PGM écrit par Thomas BENOIT dans le cadre de la formation développeur Alyra , Novembre 2019*/

pragma solidity ^0.5.1;
pragma experimental ABIEncoderV2; // <--- Génère un Warning qui peut bloquer le déploiement! 


contract AlyraDefi2{
   
    /* Constructor
    Note: L'utilisateur qui déploie le contrat devient un administrateur (utilisateur "admin) */
    address adminAddress;
    
    constructor() public {
        adminAddr[msg.sender] = true;
        inscription("admin");
        balances[msg.sender] = 1000000;
        adminAddress = msg.sender;
    }

    /* Nos modifiers : */
    
    /* Vérifier si un utilisateur est bien inscrit sur la plateforme */
    modifier onlyExisting() {
         require(existingAddr[msg.sender] == true, "You have not subscribed to our service. Please sign in!");
        _;
    }
    
    /* Vérifier si un utilisateur est bien administrateur */
    modifier onlyAdmin() {
         require(adminAddr[msg.sender] == true, "You could not use this function, because your are not an admin user");
        _;
    }
    
    /*###### PARTIE 1 #####*/ 
    
    /* Les listes de nos informations */
    // The reputation of users
    mapping (address => int256) reputations;
        
    // The name of users 
    mapping (address => string) names;
        
    // The list of baned addresses 
    mapping (address => bool) banedAddr;
        
    // The list of administrator user
    mapping (address => bool) adminAddr;
        
    // The existing users 
    mapping (address => bool) existingAddr;
    
    
    /* Function : Inscritions */
    function inscription (string memory name)  public {
        require(existingAddr[msg.sender] == false, "You have already subscribe to this plateform.");
        require(banedAddr[msg.sender] == false, "You are not any more authorized to use this market place.");
        
        // Our new user
        names[msg.sender] = name;
        reputations[msg.sender] = 1;
        existingAddr[msg.sender] = true;
        
        // Because newUser deserves money
        balances[msg.sender] = 1000000;
        }
    
    
    
    /*Function : Ban a user */
    function ban (address banedAddress) onlyAdmin public {
        reputations[banedAddress] = 0;
        banedAddr[banedAddress] = true;
    }


    /* #### PARTIE 2 #### */ 
    
    // Definition d'un Etat d'une demande 
    enum Etat { OUVERTE, ENCOURS, FERMEE }
    
    // Definition d'une demande 
    struct Demande {
        uint remuneration ; // en wei
        uint256 delai; 
        string description;
        Etat etat;
        int minReputation;
        
        // Pour la partie 3: les candidats sont associés par leurs adresses + On associe chaque offre à un owner 
        address[] candidats;    // liste des candidats 
        address maker;          // l'artiste qui prend en charge la commande
        address owner;          // l'émetteur de la requête
        address hashLink;       // Le hash du lien du résultat
    }   
    
    // liste des demandes 
    Demande[] demandes;
    
    // Ce mapping associe chaque demandeur à ses demandes
    mapping (address => uint[]) mesDemandes;
    
    /* Evenements */
    event TransferDemande (
        uint remuneration , // en wei
        uint256 delai,
        string description,
        Etat etat,
        int minReputation,
        
        // Pour la partie 3:
        uint index
        );



    
    /* Fonction: ajouterDemande() permet à une entreprise de formuler une demande.
        
        Prérequis:  1. @ du demendeurs sur la plateforme 
                    2.  L’entreprise doit en même temps déposer l’argent sur la plateforme correspondant à la rémunération + 2% de frais pour la plateforme.

    */
    function ajouterDemande (uint remunerationParam, uint256 delai, string memory description, int minReputation) onlyExisting public {
        
        /* début point 2 */
        uint remunerationRaw = SafeMath.mul(remunerationParam, 102);
        uint remuneration =  SafeMath.div(remunerationRaw, 100);
        require (balances[msg.sender] >= remuneration, "Insufficient funds!");
        
        uint forTheMarketPlace = SafeMath.div(SafeMath.mul(remuneration,2), 100);
        transfert(msg.sender, adminAddress, forTheMarketPlace);
        /* fin point 2 */
        
        uint256 date = now + delai;
        address[] memory init;
        
        // Objectif: inscrire la demande dans la table des demandes. Permet de répondre au point 1
        demandes.push( Demande(remuneration, date, description, Etat.OUVERTE, minReputation, init, address(0), msg.sender, address(0)) );
        
        // Index de notre demande (notre demande est le nième éléments du tableau demandes)
        uint index = demandes.length -1;
        
        // transmission de l'event au client web 
        emit TransferDemande(remuneration, date, description,Etat.OUVERTE, minReputation,index);

        // L'index de la demande est associée à son émetteur
        mesDemandes[msg.sender].push(index);
    }
    
    
    /* #### PARTIE 3: Méchanisme de contractualisation #### */
     
    /* # Pour les transactions financières: # */
    mapping (address => uint) balances;
    
    /* Pour que l'artiste récupère les fonds provenant de l'entreprise */
    function transfert(address _issuer, address _recipient, uint _value)  public {
        require (balances[ _issuer] >= _value, "Insufficient funds!"); 
        balances[ _issuer] -= _value;
        balances[_recipient] += _value;
    }
    
    
    /* # Fonctions exigées dans cette parte # */
    
 
    /* Function: postuler */
    function postuler(uint _index) onlyExisting public{
        require(demandes[_index].etat == Etat.OUVERTE, "This request is not any more opened!");
        require(reputations[msg.sender] >= demandes[_index].minReputation, "You have not the required level to respond to this request!");
        demandes[_index].candidats.push(msg.sender);
    }
    
    /* Function: accepterOffre */
    function accepterOffre(uint _index, address _applicant) onlyExisting public{
        require(demandes[_index].owner == msg.sender, "You are not the owner of this request!");
        demandes[_index].etat = Etat.ENCOURS;
        demandes[_index].maker = _applicant;
    }

    /* Function: livraison
        Prérequis: 
                    1. L’illustrateur remet le hash du lien où se trouve son travail
                    2. Les fonds sont alors automatiquement débloqués
                    3. L’illustrateur gagne aussi un point de réputation
    Note: l'utilisation des fonctions de hashage en solifity coûtent du Gaz. pour rendre cette action "gratuite", le hachage du lien doit être fait par l'artiste*/
    function livraison(uint _index,address _hashLink) onlyExisting public {
        require(demandes[_index].maker == msg.sender, "You are not responsible for this request!");
        demandes[_index].etat = Etat.FERMEE;
        
        // point 1
        demandes[_index].hashLink = _hashLink;
        
        // point 2
        address issuer = demandes[_index].owner;
        uint value = demandes[_index].remuneration;
        uint forThePerformer = value - SafeMath.div(SafeMath.mul(value,2), 100);
        transfert(issuer, msg.sender, forThePerformer);
        
        // point 3
        reputations[msg.sender] += 1;
    }
    
    
    
    /* #### ANNEXE: Fonctions "get" #### */
    
    /* Pour lire son solde */
    function getBalance () onlyExisting public view  returns (uint) {
        return balances[msg.sender];
    }

    /* Vérifier qu'un utilisateur est administrateur */
    function getAdmin () onlyExisting public view  returns (bool) {
        return adminAddr[msg.sender];
    }
    
    /* Permet à une entreprise de visualiser ses demandes */
    function getMesDemandes () onlyExisting public view  returns (uint[] memory) {
        return mesDemandes[msg.sender];
    }
    
    /* Pour obtenir l'état d'une demande donnée */
    function getDemandes (uint _index) onlyExisting public view  returns (Demande memory ) {
        return demandes[_index];
    }

    /* Pour obtenir le hash du lien du résulat d'une commande */
    function getHashLink (uint _index) onlyExisting public view  returns (address) {
        require(demandes[_index].owner == msg.sender, "You are not the owner of this request!");
        return demandes[_index].hashLink;
    }
    
    
}

/* Librairie SafeMath */
library SafeMath {
   function mul(uint256 a, uint256 b) internal pure returns (uint256) {
       if (a == 0) {
           return 0;
       }
       uint256 c = a * b;
       require(c / a == b);
       return c;
   }  
   function div(uint256 a, uint256 b) internal pure returns (uint256) {
       require(b > 0);
       uint256 c = a / b;
       return c;
   }
   function sub(uint256 a, uint256 b) internal pure returns (uint256) {
       require(b <= a);
       uint256 c = a - b;

       return c;
   }
   function add(uint256 a, uint256 b) internal pure returns (uint256) {
       uint256 c = a + b;
       require(c >= a);

       return c;
   }
   function mod(uint256 a, uint256 b) internal pure returns (uint256) {
       require(b != 0);
       return a % b;
   }
}