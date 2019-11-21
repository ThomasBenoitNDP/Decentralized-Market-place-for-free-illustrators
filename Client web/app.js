// The object 'Contracts' will be injected here, which contains all data for all contracts, keyed on contract name:
// Contracts['MyContract'] = {
//  abi: [],
//  address: "0x..",
//  endpoint: "http://...."
// }

function Empty(Contract) {
    this.web3 = null;
    this.instance = null;
    this.Contract = Contract;
}

Empty.prototype.onReady = function() {
    this.init(function () {
        $('#message').append("DApp loaded successfully.");
    });
}

Empty.prototype.init = function() { //cb
    // We create a new Web3 instance using either the Metamask provider
    // or an independent provider created towards the endpoint configured for the contract.
    this.web3 = new Web3(
        (window.web3 && window.web3.currentProvider) ||
        new Web3.providers.HttpProvider(this.Contract.endpoint));
    
    // Create the contract interface using the ABI provided in the configuration.
    var contract_interface = this.web3.eth.contract(this.Contract.abi);
    
    // Create the contract instance for the specific address provided in the configuration.
    this.instance = contract_interface.at(this.Contract.address);
    
    //cb();
    
}


Empty.prototype.update = function () {
    var that = this;
    //let demandeTable = [];
    var event = this.instance.TransferDemande(function(error, result) {
    if (!error) {
  
            // récupérer le JSON sous forme string
            var recep = JSON.stringify(result);
            
            // Décomposer les JSON (Parsing)
            var obj = JSON.parse(recep);

            // Ne sélectionenr uniquement que les arguments
            var objArg = JSON.stringify(obj.args);

            // On ajoute une ligne à notre tableau
            ajouterLigne(objArg);
            
            /*
            demandeTable.push(objArg);
            demandeTable.forEach(element => ajouterLigne(element));
            
            alert(Object.keys(demandeTable));
            demandeTable.forEach(element => alert(element));
            $("#demandes").text((demandeTable));*/
            
        }
    
});

}

Empty.prototype.main = function () {
    $(".demandes").show();
    this.update();
    
}

Empty.prototype.onReady = function () {
    this.init();
    this.main();

};


if(typeof(Contracts) === "undefined") var Contracts={ MyContract: { abi: [] }};
var empty = new Empty(Contracts['MyContract']);

$(document).ready(function() {
    empty.onReady();
});


/* Fonction pour remplir la table des offres */
function ajouterLigne(_input)
{
            
    // Décomposer les JSON (Parsing)
    var obj = JSON.parse(_input);


    // Request's index 
    var c0 = obj.index;

    // payment
    var c1 = obj.remuneration;
    var c2Raw = obj.delai;

    // Deade line
    var c2 = new Date(c2Raw*1000);

    // description
    var c3 = obj.description;

    // the state of request
    var c4Raw = obj.etat;
    switch (c4Raw) {
        case '0':
            c4 = "OPENED";
            break;
        case '1':
            c4 =  "IN PROGESS";
            break;
        case '2':
            c4 = "CLOSED";
            break;
    }

    // The required reputation 
    var c5Raw = obj.minReputation;
   
    if (c5Raw < 5){
        c5 = "Beginner";
    }else if (c5Raw < 8){
        c5 = "Advanced";
    }else {
        c5 = "Expert";
    }
    
	var tableau = document.getElementById("tableau");

	var ligne = tableau.insertRow(+1);

    var colonne0 = ligne.insertCell(0);
	colonne0.innerHTML += c0 

	var colonne1 = ligne.insertCell(1);
	colonne1.innerHTML += c1 

	var colonne2 = ligne.insertCell(2);
	colonne2.innerHTML += c2 

	var date = new Date();
	var colonne3 = ligne.insertCell(3);
	colonne3.innerHTML += c3 

	var colonne4 = ligne.insertCell(4);
	colonne4.innerHTML += c4 

	var colonne5 = ligne.insertCell(4);
	colonne5.innerHTML += c5 


}
