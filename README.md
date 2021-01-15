# SMART-CAI
A **smart contract** based system that automates *European Accident Statements*, special car accidents that do not need a justice involvement between parties (no injured).

## Smart contract clients
The *clients* are registered in the state of the smart contract by transactions.They are divided in **users classes**. More specifically they can access to some specific method according to the **minimality of rights** principle.
1. **Insurers**
2. **Drivers**
3. **Car sensors**

The system is divided in two different smart contract based on the *Solidity* language:
- Event Contract
- Accident Contract


## Event Contract
The event contract is accessed by the **sensors** provided in the cars and by the **Accident Contract**.
The main state is represented by a data structure that records car events (encryted) on the blockchain. 
The main functionalities of this contract are:
1. Store **car events** on the blockchain
2. Store the **drivers data**
3. Store the **insurers data**
4. Get access to the **last events** on which a single car is involved

## Accident Contract
The accident contract is accessed by the **drivers** involved in car accidents to report the details of 
the crash. This allows the contract to automatically notify the insurers providing all the informations needed to start procedures
The main functionalities of this contract are:
1. Report **car accidents**
2. Notify the insurers of the **car accidents**
3. Query **the last events** of a specific car
4. Query **all the accidents** on which a car is involved

