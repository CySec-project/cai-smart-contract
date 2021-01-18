// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;

///@title A contract that records car events on the blockchain
contract Event {

    //-------------------------DATA STRUCTURES----------------------------------------------------


    //It represents the possibile events that are recorded
    //by the sensors, the ones that needs to be indicated in the 
    //CAI module, the insurers knows who is the driver to blame
    //by this finite number of events
    enum eventNames{ TurnedLeft, 
                     TurnedRight, 
                     WasParked, 
                     WasParking,
                     ChangedLane,
                     WasSurpassing, 
                     WasBackingUp, 
                     NotRespectedPrecedence
                    }

    //A data structure that represents an event 
    //An event is recorded by a sensor on the car
    //The possibile events are a finite number, 
    //the ones that needs to be indicated in the 
    //CAI module
    struct EventRelevated {
        eventNames descr;
        uint256 date;
        uint256 time;
    }

    //A data structure that represents a car 
    //The car has an id, an owner, a model and an insurer
    struct Car {
        uint256 id;
        //The person whose insurance is associated to
        Owner owner;
        //The car model
        string model;
        //The insurer who covers this car
        Insurer insurer;
    }

    //A data structure that represents the owner of the car 
    struct Owner{
        string name;
        string surname;
    }
    
    //A data structure that represents the insurer
    //The insurer has three properties:
    //insurerAddress, the address in the blockchain of the insurer
    //name, the name of the insurer
    //email, the email associated to the insurer
    struct Insurer{
        address insurerAddress;
        string name;
        string email;
    }


    //-------------------------SMART CONTRACT STATE----------------------------------------------------


    //An hash table that keeps the sensors registered in the blockchain
    //The sensors are clients of the smart contracts and register events
    mapping(address => bool) private sensors;

    //An hash table that keeps track of the events relevated by a sensor
    //The last event is analyzed by the insurer when an accident occurs
    mapping(uint256 => EventRelevated[]) private carToEvent;

    //An hash table that keeps the data of the cars registered in the blockchain
    //The data of the cars are used to describe accidents
    mapping(uint256 => Car) private cars;

    //An hash table that keeps the data of the insurers registered in the blockchain
    mapping(address => bool) private insurersToBool;

    //An hash table that keeps the data of the insurers registered in the blockchain
    mapping(address => Insurer) private insurers;

    //The address of the contract that reports the accidents
    address AccidentAddress;


    //-------------------------FUNCTIONALITIES----------------------------------------------------




    function containsSensor()public view returns(bool){
       return sensors[msg.sender];
    }

    function containsInsurer()public view returns(bool){
       return insurersToBool[msg.sender];
    }

    function newInsurer(string memory email, string memory name) public returns(uint256 id){
       insurersToBool[msg.sender] = true;
       insurers[msg.sender] = Insurer(msg.sender, name, email);
    }
    function newSensor() public {
       sensor[msg.sender] = true;
    }

    function addCar(uint256 idCar, Owner memory owner, string memory model) public returns(uint256 id){
       require(containsInsurer());
       id = idCar;
       Insurer memory ins = insurers[msg.sender];
       cars[id] = Car(id, owner, model, ins);
    }

    function addEvent(uint256 idCar, eventNames en, uint256 date, uint256 time) public {
       require(containsSensor());
       carToEvent[idCar].push(EventRelevated(en, date, time));
    }

    function getLastEvent(uint256 idCar)public view returns(EventRelevated memory lastEvent){
       return carToEvent[idCar][(carToEvent[idCar].length)-1];
    }

    function getCar(uint256 idCar)public view returns(Car memory car){
       return cars[idCar];
    }


}


