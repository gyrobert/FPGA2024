library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pulse_fsm is
    Port (
        clk       : in  STD_LOGIC;
        reset     : in  STD_LOGIC;
        start     : in  STD_LOGIC;
        data_in   : in  STD_LOGIC_VECTOR(23 downto 0);
        pulse_out : out STD_LOGIC
    );
end pulse_fsm;

architecture Behavioral of pulse_fsm is

    type state_type is (IDLE, T0H_STATE, T0L_STATE, T1H_STATE, T1L_STATE, DONE);
    signal current_state, next_state : state_type := IDLE;

    signal bit_index : integer range 0 to 23 := 23; -- aktuális bit indexe
    signal counter : integer range 0 to 1600 := 0; -- id?zítési számláló
    signal current_bit : std_logic; -- az aktuális bit értéke
    signal pulse_reg : std_logic := '0'; -- pulse_out regisztere

    -- Id?tartamok (órajelfügg? ciklusszámok, például 10ns órajelhez)
    constant T0H_MIN : integer := 22;  -- 220ns
    constant T0H_MAX : integer := 38;  -- 380ns
    constant T0L_MIN : integer := 58;  -- 580ns
    constant T0L_MAX : integer := 160; -- 1600ns
    constant T1H_MIN : integer := 58;  -- 580ns
    constant T1H_MAX : integer := 160; -- 1600ns
    constant T1L_MIN : integer := 22;  -- 220ns
    constant T1L_MAX : integer := 42;  -- 420ns

begin
    -- Állapotgép regiszter
    process(clk, reset)
    begin
        if reset = '1' then
            current_state <= IDLE;
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;

    -- Állapotgép logika
    process(current_state, start, counter, bit_index, current_bit)
    begin
        -- Alapértékek
        next_state <= current_state;
        pulse_reg <= '0';
        
        case current_state is
            when IDLE =>
                if start = '1' then
                    next_state <= T0H_STATE;
                    bit_index <= 23;
                    counter <= 0;
                end if;

            when T0H_STATE =>
                pulse_reg <= '1';
                if counter >= T0H_MIN and counter <= T0H_MAX then
                    next_state <= T0L_STATE;
                    counter <= 0;
                else
                    counter <= counter + 1;
                end if;

            when T0L_STATE =>
                pulse_reg <= '0';
                if counter >= T0L_MIN and counter <= T0L_MAX then
                    if bit_index > 0 then
                        bit_index <= bit_index - 1;
                        current_bit <= data_in(bit_index - 1);
                        if current_bit = '1' then
                            next_state <= T1H_STATE;
                        else
                            next_state <= T0H_STATE;
                        end if;
                    else
                        next_state <= DONE;
                    end if;
                    counter <= 0;
                else
                    counter <= counter + 1;
                end if;

            when T1H_STATE =>
                pulse_reg <= '1';
                if counter >= T1H_MIN and counter <= T1H_MAX then
                    next_state <= T1L_STATE;
                    counter <= 0;
                else
                    counter <= counter + 1;
                end if;

            when T1L_STATE =>
                pulse_reg <= '0';
                if counter >= T1L_MIN and counter <= T1L_MAX then
                    if bit_index > 0 then
                        bit_index <= bit_index - 1;
                        current_bit <= data_in(bit_index - 1);
                        if current_bit = '1' then
                            next_state <= T1H_STATE;
                        else
                            next_state <= T0H_STATE;
                        end if;
                    else
                        next_state <= DONE;
                    end if;
                    counter <= 0;
                else
                    counter <= counter + 1;
                end if;

            when DONE =>
                next_state <= IDLE;

            when others =>
                next_state <= IDLE;
        end case;
    end process;

    pulse_out <= pulse_reg;

end Behavioral;
