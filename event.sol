// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;

contract Event {

    //
    enum eventNames{GiraASinistra, GiraADestra}

    // 
    struct EventRelevated {
        eventNames descr;
        uint256 date;
        uint256 time;
    }

    //
    struct Car {
        uint256 id;
        Owner owner;
        string model;
        Insurer insurer;
    }

    //
    struct Owner{
        string name;
        string surname;
    }
    
    struct Insurer{
        uint256 idInsurer;
        string email;
    }


mapping(address => bool) private sensors;
mapping(uint256 => EventRelevated[]) private carToEvent;
mapping(uint256 => Car) private cars;
mapping(address => bool) private insurersToBool;
mapping(address => Insurer) private insurers;


address AccidentAddress;



function containsSensor()public view returns(bool){
    return sensors[msg.sender];
}

function containsInsurer()public view returns(bool){
    return insurersToBool[msg.sender];
}

function newInsurer(uint256 idInsurer, string memory email) public returns(uint256 id){
    
    id = idInsurer;
    insurersToBool[msg.sender] = true;
    insurers[msg.sender] = Insurer(id, email);
}

function newCar(uint256 idCar, Owner memory owner, string memory model) public returns(uint256 id){
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


