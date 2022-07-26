# Lastenboek Opdracht 1: DNS + Domein Controller

## Deliverables
### DNS:
* Benader de server via SSH: zorg ervoor dat je nooit met het root account kan inloggen en  dat  je  enkel  (!) door  middel  van  ssh-keys  kan inloggen  (dus  niet  door  een  gebruikersnaam en wachtwoord in te geven).
* Dit  is  de  authoritative  DNS-server  voor  het  domein  “thematrix.local”.  Queries  voor  andere domeinen worden geforward naar een geschikte externe DNS-server.
* Voor elke host binnen het domein zijn er A (IPv4), AAAA (IPv6) en PTR (IPv4 en (!) IPv6) records voorzien, in de gepaste zonebestanden.
* Voorzie voor elke host geschikte CNAME-records om de functie van een server aan te duiden (bv. www, imap, smtp, ...). 
* Voorzie waar nuttig/nodig ook andere records (bv. NS, MX, SRV, ...). 

### Domein Controller:
* Je zal deze server installeren zonder DNS functionaliteit aangezien je voor de DNS-configuratie de server uit 3.3 zal aanspreken.
* Werkstations hebben geen eigen gebruikers, authenticatie gebeurt telkens via de Domain Controller. Maak hiervoor onderstaande afdelingen (groepen) aan op de domeincontroller. Voorzie als accounts verschillende personen.
    * IT Administratie
    * Verkoop
    * Administratie
    * Ontwikkeling
    * Directie
* Maak een duidelijk onderscheid tussen gebruikers, computers en groepen. Voeg enkele gebruikers toe (bv. via een CSV-bestand) en minstens 5 werkstations (één in IT Administratie, één in Ontwikkeling, één in Verkoop, één in Administratie en één in Directie).
* Werk volgende beleidsregels uit op gebruikersniveau:
    * verbied iedereen uit alle afdelingen behalve IT Administratie de toegang tot het control panel
    * verwijder het games link menu uit het start menu voor alle afdelingen
    * verbied iedereen uit de afdelingen Administratie en Verkoop de toegang tot de eigenschappen van de netwerkadapters.
    * Voorzie voor de gebruikers een filesysteem door gebruik te maken van DFS

## Deeltaken
### DNS:

1. Vagrant omgeving opzetten
    - Verantwoordelijke: Joris D'haen
    - Tester: Jordy Vanneste, Nathan Staelens
2. DNS server IPv4
    - Verantwoordelijke: Gilles De Praeter, Jarne Bottelberghe, Joris D'haen
    - Tester: Jordy Vanneste, Nathan Staelens
3. DNS server IPv6
    - Verantwoordelijke: Gilles De Praeter, Joris D'haen
    - Tester: Jordy Vanneste, Nathan Staelens
4. DNS server forwarding
    - Verantwoordelijke: Gilles De Praeter
    - Tester: Jordy Vanneste, Nathan Staelens
5. SSH
    - Verantwoordelijke: Gilles De Praeter
    - Tester: Jordy Vanneste, Nathan Staelens
6. DNS Testplan 
    - Verantwoordelijke: Gilles De Praeter, Jarne Bottelberghe
    - Tester: Jordy Vanneste, Nathan Staelens
7. DNS Testrapport
    - Verantwoordelijke: Jordy Vanneste, Nathan Staelens
    - Tester: Gilles De Praeter, Jarne Bottelberghe, Joris D'haen

### Domein Controller:

1. DNS verbinding
    - Verantwoordelijke: Joris D'haen, Gilles De Praeter
    - Tester: Jarne Bottelberghe
2. DC configuratie
    - Verantwoordelijke: Joris D'haen
    - Tester: Jarne Bottelberghe
3. DC DFS
    - Verantwoordelijke: Joris D'haen
    - Tester: Jarne Bottelberghe
4. DC Domain
    - Verantwoordelijke: Joris D'haen
    - Tester: Jarne Bottelberghe
5. DC Folders
    - Verantwoordelijke: Joris D'haen
    - Tester: Jarne Bottelberghe
6. DC Group Policies 
    - Verantwoordelijke: Joris D'haen
    - Tester: Jarne Bottelberghe
7. DC Groups
    - Verantwoordelijke: Joris D'haen
    - Tester: Jarne Bottelberghe
8. DC Users 
    - Verantwoordelijke: Joris D'haen, Gilles De Praeter
    - Tester: Jarne Bottelberghe
9. Werkstation configuratie
    - Verantwoordelijke: Joris D'haen, Gilles De Praeter
    - Tester: Jarne Bottelberghe
10. Werkstation join domain 
    - Verantwoordelijke: Joris D'haen, Gilles De Praeter
    - Tester: Jarne Bottelberghe
11. Domein Controller Testplan 
    - Verantwoordelijke: Joris D'haen
    - Tester: Jarne Bottelberghe
12. Domein Controller Testrapport
    - Verantwoordelijke: Jarne Bottelberghe
    - Tester: Gilles De Praeter, Joris D'haen


## Tijdbesteding

### DNS:

| Student             | Geschat | Gerealiseerd |
| :---                | ---:    | ---:         |
| Gilles De Praeter   |   19    |    27.75     |
| Jarne Bottelberghe  |   9     |    14        |
| Joris D'haen        |   8     |    14.75     |
| Jordy Vanneste      |   0.5   |    2         |
| Nathan Staelens     |   2     |    2.1       |
| **totaal**          |   38.5  |    60.6      |

### Domein Controller:

| Student             | Geschat | Gerealiseerd |
| :---                | ---:    | ---:         |
| Gilles De Praeter   |   4     |    5         |
| Jarne Bottelberghe  |   2     |    2.5       |
| Joris D'haen        |   20    |    26        |
| Jordy Vanneste      |   6     |    0.75      |
| Nathan Staelens     |   2     |    1         |
| **totaal**          |   34    |    35.25     |

(na oplevering van de taak een schermafbeelding toevoegen van rapport tijdbesteding voor deze taak)
