# FPGA2024

## PROJEKT CÍME: Led Strip Control  

## HALLGATÓ NEVE: Gyöngyösi Róbert

## SZAK: Távközlés IV.

### PROJEKT LEAÁDSÁNAK IDŐPONTJA: 



### A) Projekt célja

A projekt célja egy LED szalag vezérlő megvalósítása FPGA segítségével, amely biztosítja az RGB LED-ek színének és intenzitásának dinamikus beállítását a megfelelő időzítések betartásával. A vezérlő támogatja az animációkat, az adatok pontos továbbítását, és egyedileg vezérelhető LED-eket valósít meg, követve a WS2813 protokoll előírásait.

Az FPGA alapú megoldás lehetővé teszi a nagy pontosságú időzítést és a párhuzamos vezérlési logikát, amely szükséges a Worldsemi HC-F5V-90L-90LED-B-WS2813 IP20 LED szalag megfelelő működtetéséhez. A vezérlés a Digilent Nexys A7 100T fejlesztőlap segítségével került implementálásra, amely biztosítja a szükséges erőforrásokat és interfészeket a projekt számára.

#### Célrendszer jellemzői:

Hardver alap: Digilent Nexys A7 100T FPGA fejlesztőlap.
Kimeneti eszköz: Worldsemi HC-F5V-90L-90LED-B-WS2813 IP20 LED szalag (90 LED-es RGB szalag).
Kommunikációs protokoll: WS2813, amely precíz időzítést és redundáns adatvonalat biztosít.
### B) Követelmények

#### a. Funkcionális követelmények

##### Adatkommunikáció LED szalaggal
A vezérlőnek kompatibilisnek kell lennie a WS2813 protokollal, amely a LED-ek vezérlését időzített jeleken keresztül valósítja meg. Az FPGA vezérlő biztosítja, hogy az adatokat megfelelően továbbítsa a szalagon található 90 RGB LED számára.
LED szalag színek és fényerő vezérlése
A vezérlő támogatja egy 24 bites színkód (8 bit vörös, 8 bit zöld, 8 bit kék) továbbítását az egyes LED-ekhez, és lehetőséget nyújt a színek egyedi beállítására.
##### Animációs lehetőségek támogatása
A vezérlő képes egyszerűbb animációk futtatására, például:
Színek folyamatos görgetése (rainbow effect).
Pulzálás vagy színváltás előre definiált minták szerint.
##### Állapotvezérlés
A rendszer különböző állapotokban működik, amelyeket az alábbiak vezérelnek:
###### IDLE: A vezérlő várakozik az indítási jelre.
###### INIT: Felkészülés az adatátvitelre.
###### PROCESSING: Az adatok továbbítása és a LED-ek vezérlése zajlik.
###### DONE: Az adatküldés befejeződött, a LED szalag készen áll.
##### Felhasználói interfész jelek
###### Bemenetek:
clk: Órajel a rendszer működéséhez.
reset: A rendszer visszaállítása alapállapotba.
start: A vezérlés indítását jelző bemenet.
data_in: 24 bites bemeneti adat, amely egy LED színkódját tartalmazza.
###### Kimenetek:
pulse_out: Az FPGA által generált időzített impulzusok, amelyek vezérlik a LED szalagot.
led_ready: Jelzi, ha a LED szalag vezérlés befejeződött és készen áll új adatok fogadására.
##### Adatok ciklikus frissítése
###### A vezérlő támogatja az adatok folyamatos frissítését valós idejű működés érdekében, biztosítva az animációk és színváltások folytonosságát.
#### b. Nem funkcionális követelmények

##### Pontosság
Az FPGA vezérlőnek biztosítania kell az időzítések precíz betartását a WS2813 protokoll követelményei szerint:
T0H: Logikai 0 magas szintű időtartama (220–380 ns).
T0L: Logikai 0 alacsony szintű időtartama (580–1600 ns).
T1H: Logikai 1 magas szintű időtartama (580–1600 ns).
T1L: Logikai 1 alacsony szintű időtartama (220–420 ns).
##### Teljesítmény
A vezérlőnek biztosítania kell az adatok időben történő továbbítását a teljes szalag számára, lehetővé téve a valós idejű működést, legalább 30 FPS frissítési sebességgel.
##### Megbízhatóság
A vezérlőnek garantálnia kell az adatok hibamentes továbbítását a LED szalagra, a protokoll által megkövetelt redundáns vonal (backup data line) kihasználásával, amely a WS2813 szalag egyik jellemzője.
##### Fejleszthetőség és bővíthetőség
A vezérlő rendszert modulárisan kell megtervezni, hogy lehetővé tegye a bővítést több LED vezérlésére vagy összetettebb animációk implementálására.
##### Hardver kompatibilitás
A rendszer kompatibilis kell, hogy legyen a Digilent Nexys A7 100T FPGA fejlesztőlappal, amelynek erőforrásai (pl. 100 000 logikai cella) biztosítják a vezérlő logika implementálását.
##### Energiahatékonyság
A vezérlő áramkörének optimalizáltnak kell lennie az alacsony energiafogyasztás érdekében, különösen nagyobb számú LED vezérlése esetén

### Időzítési követelmények ábrája:
             T0H                              T0L
    +--------------------+           +-----------------------------+
    |                    |           |                             |
    |                    |           |                             |
----+                    +-----------+                             +--------

             T1H                              T1L
    +-----------------------------------+     +--------------------+
    |                                   |     |                    |
    |                                   |     |                    |
----+                                   +-----+                    +--------

   0: T0H = 220–380 ns, T0L = 580–1600 ns
   1: T1H = 580–1600 ns, T1L = 220–420 ns


## Bibliografia: 
### Brassai Sándor Tihamér: Újrakonfigurálható digitális áramkörök terevezési és tesztelési módszerei
https://real.mtak.hu/122602/1/Brassai%20Tihamer_UKDA_REAL.pdf
### Digilent Nexys A7 100T 
https://digilent.com/reference/programmable-logic/nexys-a7/reference-manual?srsltid=AfmBOopPYkZFi67oxJ9jNAWAl1rlxKJ0XegoVE1j3H7AwfHHe00-izdG
### Worldsemi LED
https://www.tme.eu/ro/details/hcbaa90b/surse-de-lumina-benzi-cu-led-uri/worldsemi/hc-f5v-90l-90led-b-ws2813-ip20/

