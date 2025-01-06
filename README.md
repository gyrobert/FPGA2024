# FPGA2024

## PROJEKT CÍME: Led Strip Control

## HALLGATÓ NEVE: Gyöngyösi Róbert

## SZAK: Távközlés IV.

### PROJEKT LEAÁDSÁNAK IDŐPONTJA:

### A) Projekt célja

A projekt célja egy LED szalag vezérlő megvalósítása FPGA segítségével, amely biztosítja az RGB LED-ek színének és intenzitásának dinamikus beállítását a megfelelő időzítések betartásával. A vezérlő támogatja az animációkat, az adatok pontos továbbítását, és egyedileg vezérelhető LED-eket valósít meg, követve a WS2813 protokoll előírásait.

Az FPGA alapú megoldás lehetővé teszi a nagy pontosságú időzítést és a párhuzamos vezérlési logikát, amely szükséges a Worldsemi HC-F5V-90L-90LED-B-WS2813 IP20 LED szalag megfelelő működtetéséhez. A vezérlés a Digilent Nexys A7 100T fejlesztőlap segítségével került implementálásra, amely biztosítja a szükséges erőforrásokat és interfészeket a projekt számára.

#### Célrendszer jellemzői:

- **Hardver alap**: Digilent Nexys A7 100T FPGA fejlesztőlap.
- **Kimeneti eszköz**: Worldsemi HC-F5V-90L-90LED-B-WS2813 IP20 LED szalag (90 LED-es RGB szalag).
- **Kommunikációs protokoll**: WS2813, amely precíz időzítést és redundáns adatvonalat biztosít.

### B) Követelmények

#### a. Funkcionális követelmények

##### Adatkommunikáció LED szalaggal
A vezérlőnek kompatibilisnek kell lennie a WS2813 protokollal, amely a LED-ek vezérlését időzített jeleken keresztül valósítja meg. Az FPGA vezérlő biztosítja, hogy az adatokat megfelelően továbbítsa a szalagon található 90 RGB LED számára.

##### LED szalag színek és fényerő vezérlése
A vezérlő támogatja egy 24 bites színkód (8 bit vörös, 8 bit zöld, 8 bit kék) továbbítását az egyes LED-ekhez, és lehetőséget nyújt a színek egyedi beállítására.

##### Animációs lehetőségek támogatása
A vezérlő képes egyszerűbb animációk futtatására, például:

- Színek folyamatos görgetése (rainbow effect).
- Pulzálás vagy színváltás előre definiált minták szerint.

##### Állapotvezérlés
A rendszer különböző állapotokban működik

##### Adatok ciklikus frissítése
A vezérlő támogatja az adatok folyamatos frissítését valós idejű működés érdekében, biztosítva az animációk és színváltások folytonosságát.

#### b. Nem funkcionális követelmények

##### Pontosság
Az FPGA vezérlőnek biztosítania kell az időzítések precíz betartását a WS2813 protokoll követelményei szerint:

- **T0H**: Logikai 0 magas szintű időtartama (220–380 ns).
- **T0L**: Logikai 0 alacsony szintű időtartama (580–1600 ns).
- **T1H**: Logikai 1 magas szintű időtartama (580–1600 ns).
- **T1L**: Logikai 1 alacsony szintű időtartama (220–420 ns).

##### Teljesítmény
A vezérlőnek biztosítania kell az adatok időben történő továbbítását a teljes szalag számára, lehetővé téve a valós idejű működést, legalább 30 FPS frissítési sebességgel.

##### Megbízhatóság
A vezérlőnek garantálnia kell az adatok hibamentes továbbítását a LED szalagra, a protokoll által megkövetelt redundáns vonal (backup data line) kihasználásával, amely a WS2813 szalag egyik jellemzője.

##### Fejleszthetőség és bővíthetőség
A vezérlő rendszert modulárisan kell megtervezni, hogy lehetővé tegye a bővítést több LED vezérlésére vagy összetettebb animációk implementálására.

##### Hardver kompatibilitás
A rendszer kompatibilis kell, hogy legyen a Digilent Nexys A7 100T FPGA fejlesztőlappal, amelynek erőforrásai (pl. 100 000 logikai cella) biztosítják a vezérlő logika implementálását.

##### Energiahatékonyság
A vezérlő áramkörének optimalizáltnak kell lennie az alacsony energiafogyasztás érdekében, különösen nagyobb számú LED vezérlése esetén.

### Időzítési követelmények ábrája:

#### Logikai 0 (T0):
```
             T0H                              T0L
    +--------------------+           +-----------------------------+
    |                    |           |                             |
    |                    |           |                             |
----+                    +-----------+                             +--------
```

#### Logikai 1 (T1):
```
             T1H                              T1L
    +-----------------------------------+     +--------------------+
    |                                   |     |                    |
    |                                   |     |                    |
----+                                   +-----+                    +--------
```

- **0**: T0H = 220–380 ns, T0L = 580–1600 ns
- **1**: T1H = 580–1600 ns, T1L = 220–420 ns

### C) Tervezés

#### Főkomponensek

##### Bemenetek:
- `clk`: Órajel.
- `reset`: Reset jel.
- `start`: Indítási jel.
- `data_in`: 24 bites bemeneti adat.

##### Kimenet:
- `pulse_out`: Kimeneti impulzus.

#### Főmodulok:
- **Állapotgép (state machine):** A vezérlési logikát valósítja meg.
- **Számlálók:** Az időzítések kezelésére szolgálnak.
- **Bit indexelés (bit_index):** A bejövő adat bitjeinek feldolgozásához.
- **LED vezérlő (led_out):** A LED szalag vezérléséhez szükséges jelek előállítása.

#### Állapotgép

Az állapotgép az alábbi állapotokat tartalmazza:

- **IDLE:** Várakozás a `start` jelre.
- **INIT:** A változók inicializálása.
- **PROCESSING:** Az adatfeldolgozás elkezdése.
- **T0H_STATE, T0H_DONE, T0L_STATE, T0L_DONE:** Logikai `0` jel generálása.
- **T1H_STATE, T1H_DONE, T1L_STATE, T1L_DONE:** Logikai `1` jel generálása.
- **BIT_CHECK_STATE:** Ellenőrzés, hogy minden bit ki lett-e küldve.
- **DONE:** Az adatküldés vége, visszatérés az `IDLE` állapotba.

#### Funkcionális blokkok

- **Adatfeldolgozás:** A `data_in` bemeneti adat bitenkénti feldolgozása.
- **Időzítések kezelése:** Számlálók segítségével az egyes impulzusok időzítésének biztosítása.
- **Kimeneti vezérlés:** A `pulse_out` jel generálása az állapotgép és időzítések alapján.

### Tervezés lépései

#### 1) LED szallag működésének megértése:

![LED_module_logika](https://github.com/user-attachments/assets/ddb87f7f-09c7-47c2-a819-7c0d506b377c)

- **Megj.:** A LED szallag több kisebb egységből épül fel, minden egységet egy IC vezérel meg, amely ha a bemeneten(DI) adatot kapva megvilágítja az adott számú LED-et a 24 bites adat szerint, majd ha újabb adatot kap a bemenetén(DI), akkor az előbbi adatot továbbítja a kimenetén(DO) az utánna következő, sorba kötött LED egységre.

#### 2) Állapotgép tervezése:

- **Az állapot logika megrajzolása**
  ![Allapotgep1](https://github.com/user-attachments/assets/f1a5f4c8-9bbb-42ed-a914-02195fc1f77c)
- **Állapotlogika javítása**
  ![Allapotgep2](https://github.com/user-attachments/assets/4927f1db-0496-4ab5-8074-5107fcfca14a)


## Bibliográfia:

### Brassai Sándor Tihamér: Újrakonfigurálható digitális áramkörök tervezési és tesztelési módszerei
[Link](https://real.mtak.hu/122602/1/Brassai%20Tihamer_UKDA_REAL.pdf)

### Digilent Nexys A7 100T
[Link](https://digilent.com/reference/programmable-logic/nexys-a7/reference-manual?srsltid=AfmBOopPYkZFi67oxJ9jNAWAl1rlxKJ0XegoVE1j3H7AwfHHe00-izdG)

### Worldsemi LED
[Link](https://www.tme.eu/ro/details/hcbaa90b/surse-de-lumina-benzi-cu-led-uri/worldsemi/hc-f5v-90l-90led-b-ws2813-ip20/)
