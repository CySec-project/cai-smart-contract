pragma experimental ABIEncoderV2;

pragma solidity >=0.7.0 <0.8.0;
import '/CarInsurance/Event.sol' ;
import '/CarInsurance/blockchain2emailAPI.sol';


///@title A contract that reports the car accidents to the insurers
contract AccidentContract {
        
    //-------------------------DATA STRUCTURES----------------------------------------------------

    //A data structure that represents a car accident
    //it contains the data of the drivers and the cars involved, 
    //it also contains the last event recorded by the sensors
    //installed on the cars
    struct Accident{
        Driver driverA;
        Event.Car carA ;
        Event.EventRelevated eventA;
        Driver driverB;
        Event.Car carB;
        Event.EventRelevated eventB;
    }
    
    //A data structure that contains the data of a driver.
    //These data can be only accessed by the insurers
    //when the driver is involved in a car accident with
    //another part
    struct Driver{
        string name;
        string lastname;
        string nLicense;
        
    
    }

    //-------------------------SMART CONTRACT STATE----------------------------------------------------

    //An hash table that keeps track of the accidents on which a car
    //is involved onto, the key is a car id which is possessed only
    //by the the insurer and the owner of the veichle
    mapping(uint256 =>Accident[]) private carToCrash;

    //An hash table that stores the informations of the drivers in the 
    //blockchain, it can be only accessed by them, 
    //the key is the address of a driver in the blockchain, 
    //the value is the struct representing the informations of the driver
    mapping(address =>Driver) private drivers;

    //An hash table that stores the address of the drivers belonging
    //the blockchain, it is useful for separating the classes of users
    //in the blockchain
    mapping(address =>bool) private driversToBool;

    //An hash table that stores the history of the accidents of a specific
    //insurer, it can be only be accessed by who possesses the id of the insurer.
    mapping(address => Accident[]) private insurerToAccident;
    
    //The contract that records the informations of the events of the cars
    //that registered in the blockchain. These informations are sended by
    //specific sensors that are aware of predefined events.
    Event e;

    //A variable that represents the state of the contract:
    //if it is false it is working correctly otherwise it is stopped
    bool public contractStopped = false;
    
    
    //--------------------------FUNCTIONALITES----------------------------------------------------
    
    //A modifier for the most critical function, it stops them when the variable
    //contractStopped is set to true by the owner
    modifier haltInEmergency {​​​​
         require(!contractStopped);
    }​​​​

    //This method initialize the contract, it creates another contract and
    //keeps its reference. It contains some useful informations and methods
    //that are used by this contract
    constructor(){
         //Create a new smart contract event
         e = new Event();
    }


    //It is called only by the owner that is the creator of the contract
    //whenever a possible bug or a byzantine beheaviour are found
    //It allows the owner to stop the invocations of the critical functions
    function toggleContractStopped() public onlyOwner {​​​​
        //Change the value of the variable: if it was false it becomes true
        //otherwise it becomes false
        contractStopped =! contractStopped;
    }​​​​


    //It creates a new driver by adding its informations in the blockchain.
    //When the driver is involved in a car accident, the insurer of the 
    //cars can access to its informations to start a procedure.
    function newDriver(string memory name, string memory lastname, string memory nLicense) public{
         //Add a new row of the hash table that stores the drivers
         drivers[msg.sender] = Driver(name, lastname, nLicense);
         //Add the address in the blockchain of the driver
         driversToBool[msg.sender] = true;          
    }




    //A method that checks if the address passed as parameter is registered in the state
    //of the smart contract as a driver, this is useful to separate the clients of the smart contract
    //as classes of users for checking the accesses to private informations
    function containsDriver(address driver) public view returns(bool){
         //If the driver has been added to the blockchain it returns true
         //otherwise it returs false by default
         return driversToBool[driver];
    }
        
 
    //This is the main method of the smart contract.
    //It is called by a driver involved in a car accident with the ids of the cars
    //involved in the crash. The function creates an accident and adds it to 
    //the blockchain, it also send a notification to the insures of the cars involved,
    //alerting them to go check the data of the crash.
    function reportCrash(uint256 idMacchina1, uint256 idMacchina2, address driver2) public haltInEmergency {
         //It checks whether the sender address is a driver, 
         //only drivers can report car accidents, 
         //if it is not a driver the code does not go on
         require(containsDriver(msg.sender));
         require(containsDriver(driver2));
             
         //Finds the car registered in the blockchain
         Event.Car memory carA = e.getCar(idMacchina1);
         Event.Car memory carB = e.getCar(idMacchina1);
         //Finds the last events of the cars involved in the crash
         //according to the sensors of the cars
         Event.EventRelevated memory erA = e.getLastEvent(idMacchina1);
         Event.EventRelevated memory erB = e.getLastEvent(idMacchina2);

         //Finds the drivers of involved in the crash
         //One is the invoker of the function
         //The other driver's address is in the parameters
         Driver memory driverA = drivers[msg.sender];
         Driver memory driverB = drivers[driver2];
            
         //Creates a new struct Accident with all the data needed by the insurer
         //This is useful for the insurers to understand the driver to blame on, 
         //according to the events registered by the sensors
         Accident memory accident = Accident(driverA, carA, erA, driverB, carB, erB);
            
         //Adds the last accidents to the crashes of the cars
         //The crashes are recorded in a stack where the last element
         //is the last crash recorded by the smart contract
         carToCrash[idMacchina1].push(accident);
         carToCrash[idMacchina2].push(accident);

         //Adds the last accidents to the crashes of the insurers
         //The crashes are recorded in a stack where the last element
         //is the last crash recorded by the smart contract
         insurerToAccident[carA.insurer.insurerAddress].push(accident);
         insurerToAccident[carB.insurer.insurerAddress].push(accident);
            
         //It notifies each insurer that a car accident has been happened
         callInsurer(carA.insurer);
         callInsurer(carB.insurer);
             
    }
    

    //It calls another contract that handles emails to notify the emailAddress
    //with a message, it returns true whenever the sending worked otherwise false
    function SendEmail(string memory emailAddress, string memory message) private returns (bool){ 
         //It calls the functions of another contract by using its address      
         return (blockchain2emailAPI(0xDe5EBd0B8879b0a42B23B37e4d76a5E21a0bEF4B).SendEmail(emailAddress, message));
    }



    //The insurer wants to check the data of the last accident
    //This function returns the last accident that is registered
    //on the blockchain for that insurer
    function handleLastAccident() public view returns(Accident memory accident){
         //It checks if the caller is an insurer, this is for security purpose
         //If the caller is not insurer it throws an exception
         require(e.containsInsurer());
         //It gets the last accident of a specific insurer,
         // which is the caller of the method
         accident = insurerToAccident[msg.sender][insurerToAccident[msg.sender].length-1];
    }
    
    //It sends an email to the insurer notifing him that a car accident has happened
    //The insurer can call the function handleLastAccident() to verify the data of 
    //the accident occurred
    function callInsurer(Event.Insurer memory insurer) private {
        //Call another contract API to send the email to the insurer
        SendEmail(insurer.email, "New accident, Go to check on your Accidents List");
    }

    
    //It returns the accidents of a specific car
    //It can only be called by insurers, that need to know the car id
    function checkAccidents(uint idMacchina) public view returns (Accident[] memory accidents){
        //Checks whether the caller is an insurer registered in the blockchain
        require(e.containsInsurer());
        //Returns the accidents of the specific car
        return carToCrash[idMacchina];
    }
    

}


    
    
    
    
    
}
