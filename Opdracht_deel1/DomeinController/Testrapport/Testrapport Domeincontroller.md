# Testrapport: DomeinController

## Test 1 ()

Uitvoerder(s) test: Jarne Bottelberghe 
Uitgevoerd op: 22/03/2022

## Installatie Windows-Server

Om het testplan te kunnen voltooien moet ik eerst een windows server vm aanmaken volgens de gegeven configuratie. Dit is voor mij foutloos verlopen.

![](./images/instalationDone.png)

![](./images/guestAdditions.png)

## Server agentsmith basisconfiguratie

Ik kan het configuratie script zonder problemen runnen,na het runnen van het configuratiescript moest ik mijn machine heropstarten. Na het heropstarten kunnen we zien dat het sript gewerkt heeft omdat de hostname en de interfaces zijn aangepast.
![](C:\Users\botte\OneDrive\Documenten\GitHub\sep-2122-g04\Opdracht_deel1\DomeinController\Testrapport\images\Schermafbeelding 2022-03-22 181014.png)

![](./images/eth0.png) ![](./images/eth1.png)

## Domein aanmaken  en server promoveren

Ik kan het DC_Script_Domain runnen zonder problemen en het domain veranderd na een restart. 

![](./images/adtree2.png)

## Aanmaken Organizational Units en groepen

Na het runnen van het script zijn de groepen aangemaakt

![](./images/ou.png)

## Aanmaken Shared user Folders

Na het runnen van het script is er een gedeelde map aangemaakt die gedeeld word met het netwerk

![](./images/folder.png)

## Aanmaken users

Na het runnen van het script zijn de users aangemaakt.

![](./images/users.png)

## Group policies

Na het runnen van het script zijn de grouppolicies aangemaakt 

![](./images/grouppolicies.png)

## Configureren van DFS namespace

Het script kon ik runnen zonder problemen. Er werd een folder voor dfs aangemaakt op de C schrijf

![](./images/dfs.png)