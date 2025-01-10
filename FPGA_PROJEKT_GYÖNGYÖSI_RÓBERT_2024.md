# FPGA2024

## PROJEKT CÍME: Led Strip Control

## HALLGATÓ NEVE: Gyöngyösi Róbert

## SZAK: Távközlés IV.

### PROJEKT LEAÁDSÁNAK IDŐPONTJA: 2025.01.07 3:00

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

### D) Tervezés lépései

#### 1) LED szallag működésének megértése:

![LED_module_logika](https://github.com/user-attachments/assets/ddb87f7f-09c7-47c2-a819-7c0d506b377c)

- **Megj.:** A LED szallag több kisebb egységből épül fel, minden egységet egy IC vezérel meg, amely ha a bemeneten(DI) adatot kapva megvilágítja az adott számú LED-et a 24 bites adat szerint, majd ha újabb adatot kap a bemenetén(DI), akkor az előbbi adatot továbbítja a kimenetén(DO) az utánna következő, sorba kötött LED egységre.

#### 2) Állapotgép tervezése:

- **Az állapot logika megrajzolása**
  
  ![Allapotgep1](https://github.com/user-attachments/assets/f1a5f4c8-9bbb-42ed-a914-02195fc1f77c)

  - **Megj.:** A rajz az iniciális elképzelést ábrázolja.
  
- **Állapotlogika javítása**
  
  ![Allapotgep2](https://github.com/user-attachments/assets/4927f1db-0496-4ab5-8074-5107fcfca14a)

  - **Megj.:** A rajz a végleges logikát szemlélteti.

#### 3) Művelet automaták:

##### Állapot automata:

![State_logic](https://github.com/user-attachments/assets/73eb99b5-8944-4ec2-acd4-e4dc1ebb473a)

- **Megj.:** Ez az automata felelős a megfelelő állapot kiválasztásáért.

##### Számláló automata:

![Counter_logic](https://github.com/user-attachments/assets/eb7a841f-aa1d-45b6-b4dd-c54bd5967dc1)

- **Megj.:** Ez az automata az időzítésért felelős, hogy a jelek pontosan generálodjanak.

##### LED impulzus automata:

![LED_logic](https://github.com/user-attachments/assets/46bbf577-c573-41dd-8aa4-3508493eff09)

- **Megj.:** Ez az automata felel a kimeneten való helyes impulzus kiküldéséről.

##### Bit index automata:

![bit_index_logic](https://github.com/user-attachments/assets/995b451b-d0aa-4585-a662-a46e4e752407)

- **Megj.:** Ez az automata végzi el az indexelést, hogy a 24 bites adatot fel lehessen dolgozni eggyessével, bittenként.

  #### 4) Fázisműveletek:

| current_state | start | reset | counter_next | led_out_next | bit_index_next |
|---------------|-------|-------|--------------|--------------|----------------|
| IDLE | 0 | 1 | 0 | 0 | 0 |
| INIT | 1 | 0 | 0 | led_out | bit_index |
| PROCESSING | 1 | 0 | 1 | led_out | bit_index |
| TOH_STATE | 1 | 0 | counter+1 | 0 | bit_index |
| TOH_DONE | 1 | 0 | 0 | led_out | bit_index |
| TOL_STATE | 1 | 0 | counter+1 | 0 | bit_index |
| TOL_DONE | 1 | 0 | 0 | led_out | bit_index |
| T1H_STATE | 1 | 0 | counter+1 | 0 | bit_index |
| T1H_DONE | 1 | 0 | 0 | led_out | bit_index |
| T1L_STATE | 1 | 0 | counter+1 | 1 | bit_index |
| T1L_DONE | 1 | 0 | 0 | led_out | bit_index |
| BIT_CHECK_STATE | 1 | 0 | 0 | led_out | bit_index-1 |
| DONE | 1 | 0 | 0 | led_out | 0 |

### E) Tesztelés:

#### VHDL Test Bench kód:

##### Lépések:

- **Reset aktíválása néhány órajelig **
- **A kiküldendő adat beolvasása **
- **Start aktíválása amíg a folyamat befejeződik és minden adat kiküldésre kerül **
  
```vhdl
-- Tesztelési folyamat
stim_proc: process
begin
    -- Reset állapot
    reset <= '1';
    wait for clk_period;
    reset <= '0';

    -- Adat küldése és start jel generálása
    wait for clk_period;
    data_in <= "101010101010101010101010";
    wait for clk_period;
    start <= '1';
    wait for clk_period * 5;
    start <= '0';

    -- Várakozás a folyamat befejezésére
    wait for clk_period * 100;
    wait;
end process;
```
- **Megj.:** Az adott kódrészlet a rendszer szimulációját teszi lehetővé.

  #### Szimulacio:
  ![Untitled1](https://github.com/user-attachments/assets/48935063-fd48-41b5-9904-dc54362fe20d)


## Üzembe helyezés:

### Hardver követelmények

- FPGA fejlesztőpanel (Digilent Nexys A7 100T).
- Programozó kábel az FPGA konfigurálásához.
- 5V-os LED szalag (pl. WS2812 vagy kompatibilis).
- Tápellátás a LED szalaghoz.
- Ellenállás (330–470 Ω) a LED szalag adatvonalának védelmére (opcionális, de ajánlott).
- Kondenzátor (1000 µF, 6.3V vagy nagyobb) a LED szalag tápvonalának stabilizálására (opcionális, de ajánlott).

### Szoftver követelmények

- FPGA fejlesztőeszköz (Vivado).

### Kód letöltése és fordítása

1. Nyisd meg az FPGA fejlesztőeszközt (Vivado).
2. Töltsd be a VHDL projektet.
3. Fordítsd le a projektet a céleszközre optimalizálva.
5. Töltsd fel a generált bitfájlt az FPGA-ra a programozó kábellel.

### LED szalag csatlakoztatása

1. **Adatvonal csatlakoztatása**:  
   Kösd a LED szalag adat bemenetét (DIN) az FPGA megfelelő GPIO kimenetére, amelyhez a pulse_out jel van rendelve.

2. **Tápellátás**: 
   Kösd a LED szalag VCC és GND pontjait megfelelő feszültségforráshoz. (Opcionális)  Használj 1000 µF kondenzátort a stabilizálás érdekében.

3. **(Opcionális)  Védelmi komponensek**:  
   Illessz be egy 330–470 Ω-os ellenállást a GPIO kimenet és a LED szalag adatbemenete közé.

### Rendszer indítása

1. **Resetelés**:  
   Indításkor állítsd reset bemenetre az 1 értéket a start kapcsoló melletti kapcsoló segítségével néhány órajelciklusig, majd vissza 0 értéket.

2. **Start jel**:  
   Állítsd a start bemeneti jelet 1-re az adatküldés elindításához a kapcsoló 1-es pozicióba tételével.

3. **Adatok betöltése**:  
   Töltsd be a data_in bemenetbe a 24 bites színt adatként, RGB formátumban (pl. data_in => "111111111111111111111111" a fehér színhez).

4. **Figyeld a pulse_out jelet**:  
   Ez jelzi az FPGA által generált időzítéseket a LED szalag számára.

### További megjegyzések

- Ha nagyobb LED szalagot használsz, ügyelj a tápellátás megfelelő méretezésére.
- Szükség esetén bővítsd a vezérlő logikát, hogy több LED-et is kezeljen sorosan.
- Ezzel a lépéssorozattal a LED Strip Controller működése üzembe helyezhető és ellenőrizhető.


## Bibliográfia:

### Brassai Sándor Tihamér: Újrakonfigurálható digitális áramkörök tervezési és tesztelési módszerei
[Link](https://real.mtak.hu/122602/1/Brassai%20Tihamer_UKDA_REAL.pdf)

### Digilent Nexys A7 100T
[Link](https://digilent.com/reference/programmable-logic/nexys-a7/reference-manual?srsltid=AfmBOopPYkZFi67oxJ9jNAWAl1rlxKJ0XegoVE1j3H7AwfHHe00-izdG)

### Worldsemi LED
[Link](https://www.tme.eu/ro/details/hcbaa90b/surse-de-lumina-benzi-cu-led-uri/worldsemi/hc-f5v-90l-90led-b-ws2813-ip20/)

| Vezetéknév     | Keresztnév | Jelenlét | Általános | Tervezés | Mérések | Pont. Dok. | Tervezés | Implementálás | Szimuláció/Mérések | Valós megvalósítás | Valós rendszeren mérések | Pont. Projekt Gyak | Kérdések | Pluszpont | Projekt Jegy | Megjegyzések | Projekt komplexitása |
|----------------|------------|----------|-----------|----------|---------|------------|----------|----------------|--------------------|-------------------|-------------------------|-------------------|----------|-----------|--------------|---------------|----------------------|
|           |     | 10       | 10        | 10       | 10      | 30         | 10       | 10             | 10                 | 10                | 10                      | 50                | 10       | 1         | 100          |            |                      |
|     Gyöngyösi            |   Róbert           |    16      |      7     |      7    |      6   |    20        |   6       |         6       |    3                | 0                  |            0             |        15           |      6    |      0     |      50      |               |          4            |
