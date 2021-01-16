# SMART-CAI
A **smart contract** based system that automates *European Accident Statements*, special car accidents that do not need a justice involvement between parties (no injured).

The blockchain technology is born to make transactions possible among untrusted parties. In the context of car insurance the parts involved (drivers and insurers) do not fully trust each other for economic reasons: hence, using a blockchain-like system seems to be the best way to automatize and to handle accidents reports.

**SMART-CAI** is a system that is able to handle car accident reports using the **Ethereum** platform.

## Smart contract clients
The *clients* are registered in the state of the smart contract by transactions. They are divided in **user classes**. More specifically, they can access to some specific smart contract functionalities according to the **minimality of rights** principle. The main clients are: 
1. **Insurers**
2. **Drivers**
3. **Car sensors**

The system is divided in two different smart contracts (with a correlated lifecycle) based on the *Solidity* language:
- Event Contract
- Accident Contract


## Event Contract
The event contract is accessed by the **sensors** embedded in the cars and by the **Accident Contract**.
The state is represented by a data structure that records car events (encrypted) on the blockchain. 
The main functionalities of the contract are:
1. Store **car events** on the blockchain
2. Store the **drivers data**
3. Store the **insurers data**
4. Get access to the **last events** on which a single car is involved

## Accident Contract
The accident contract is accessed by the **drivers** involved in car accidents to report the details of 
the crash. This allows the contract to automatically notify the insurers, providing all the informations needed to start refund procedures.
The contract ensures that a byzantine behavior for the drivers is unlikely because of the sensors embedded on cars.
The main functionalities of this contract are:
1. Report **car accidents**
2. Notify the insurers of the **car accidents**
3. Query **the last events** of a specific car
4. Query **all the accidents** on which a car is involved

