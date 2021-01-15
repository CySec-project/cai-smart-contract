pragma experimental ABIEncoderV2;

pragma solidity >=0.7.0 <0.8.0;
import '/CarInsurance/Event.sol' ;
import '/CarInsurance/blockchain2emailAPI.sol';

contract AccidentContract {
        
    
    
    struct Accident{
        Driver driverA;
        Event.Car carA ;
        Event.EventRelevated eventA;
        Driver driverB;
        Event.Car carB;
        Event.EventRelevated eventB;
    }
    
    
    struct Driver{
        string name;
        string lastname;
        string nLicense;
        
    
    }
    
    mapping(uint256 =>Accident[]) private carToCrash;
    mapping(address =>Driver) private drivers;
    mapping(address =>bool) private driversToBool;
    mapping(uint256 =>Accident[]) private insurerToAccident;
    
    address contractAddress;
    
    Event e;
    
   
    
    constructor(){
         e=new Event();
    
    }

    function newDriver(string memory name, string memory lastname,string memory nLicense)public{
                drivers[msg.sender] = Driver(name, lastname,nLicense);
                driversToBool[msg.sender] = true;
                
    }
              
    function containsDriver(address driver ) public view returns(bool){
        return driversToBool[driver];
    }
        
    function reportCrash(uint256 idMacchina1) public {
        
        }
        
    function reportCrashForBoth(uint256 idMacchina1, uint256 idMacchina2, address driver2) public {
             require(containsDriver(msg.sender));
             require(containsDriver(driver2));
             
            Event.Car memory carA=e.getCar(idMacchina1);
            Event.Car memory carB=e.getCar(idMacchina1);
            Event.EventRelevated memory erA= e.getLastEvent(idMacchina1);
            Event.EventRelevated memory erB= e.getLastEvent(idMacchina2);
            Driver memory driverA = drivers[msg.sender];
            Driver memory driverB = drivers[driver2];
            
            
            Accident memory accident= Accident(driverA, carA, erA, driverB, carB, erB);
            
            carToCrash[idMacchina1].push(accident);
            carToCrash[idMacchina2].push(accident);
            insurerToAccident[carA.insurer.idInsurer].push(accident);
            insurerToAccident[carB.insurer.idInsurer].push(accident);
            
            
            callInsurer(carA.insurer);
            callInsurer(carB.insurer);
             
    }
    
        function SendEmail(string memory EmailAddress, string memory Message) internal returns (bool){
           
        return (blockchain2emailAPI(0xDe5EBd0B8879b0a42B23B37e4d76a5E21a0bEF4B).SendEmail(EmailAddress, Message));
    }
    
    function handleLastAccident(uint256 idInsurer) public view returns(Accident memory accident){
        require(e.containsInsurer());
        
        accident= insurerToAccident[idInsurer][insurerToAccident[idInsurer].length];
    }
    
    function callInsurer(Event.Insurer memory insurer) public  {
    
         SendEmail(insurer.email, "New accident, Go to check on your Accidents List  ");
        }
    
    function checkAccidents(uint idMacchina) public view returns (Accident[] memory accidents){
        require(e.containsInsurer());
        return carToCrash[idMacchina];
  
        }
    

}


    
    
    
    
    
}
