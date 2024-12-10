library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity led_strip_controller is
    Port (
        clk       : in  STD_LOGIC;
        reset     : in  STD_LOGIC;
        start     : in  STD_LOGIC;
        data_in   : in  STD_LOGIC_VECTOR(23 downto 0);
        pulse_out : out STD_LOGIC;
        led_ready : out STD_LOGIC
    );
end led_strip_controller;

architecture Behavioral of led_strip_controller is

    -- Állapotok
    type state_type is (IDLE, INIT, CLEAR_LEDS, PROCESSING, T0H_STATE, T0L_STATE, T1H_STATE, T1L_STATE, BIT_CHECK_STATE, DONE);
    signal current_state, next_state : state_type := IDLE;

    -- Számlálók és változók
    signal bit_index : integer range 0 to 23 := 23; 
    signal counter : integer range 0 to 1600 := 0; 
    signal current_bit : std_logic;
    signal pulse_reg : std_logic := '0'; -- pulse_out
    signal led_buffer : std_logic_vector(23 downto 0) := (others => '0'); 

   
    constant T0H_MIN : integer := 22;  -- 220ns
    constant T0H_MAX : integer := 38;  -- 380ns
    constant T0L_MIN : integer := 58;  -- 580ns
    constant T0L_MAX : integer := 160; -- 1600ns
    constant T1H_MIN : integer := 58;  -- 580ns
    constant T1H_MAX : integer := 160; -- 1600ns
    constant T1L_MIN : integer := 22;  -- 220ns
    constant T1L_MAX : integer := 42;  -- 420ns

begin
   
    reg:process(clk, reset)
    begin
        if reset = '1' then
            current_state <= IDLE;
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;

   
   logic:process(current_state, start, counter, bit_index, current_bit)
    begin
        -- Alapértékek
        next_state <= current_state;
        pulse_reg <= '0';
        led_ready <= '0';
       

        case current_state is
            -- IDLE 
            when IDLE =>
                if start = '1' then
                 next_state <= INIT;
                else
                    next_state <= IDLE;
                end if;

            -- INIT 
            when INIT =>
              counter <= 0;
              bit_index <= 23;
              next_state <= CLEAR_LEDS;
                      
            -- CLEAR_LEDS 
            when CLEAR_LEDS =>
                led_buffer <= (others => '0'); 
                next_state <= PROCESSING;

            -- PROCESSING 
            when PROCESSING =>
             
                    current_bit <= led_buffer(bit_index);
                    if current_bit = '1' then
                        next_state <= T1H_STATE;
                    else
                        next_state <= T0H_STATE;
                    end if;
                    counter <= 0;

            --Pulse generalas
            when T0H_STATE =>
                pulse_reg <= '1';
                if counter >= T0H_MAX then
                    next_state <= T0L_STATE;
                    counter <= 0;
                else
                    counter <= counter + 1;
                    next_state <= T0H_STATE;
                end if;

            when T0L_STATE =>
                pulse_reg <= '0';
                if counter >= T0L_MAX then
                    next_state <= BIT_CHECK_STATE;
                    counter <= 0;
                else
                    counter <= counter + 1;
                    next_state <= T0L_STATE;
                end if;
                
            
                    
                    

            when T1H_STATE =>
                pulse_reg <= '1';
                if counter >= T1H_MAX then
                    next_state <= T1L_STATE;
                    counter <= 0;
                else
                    counter <= counter + 1;
                    next_state <= T1H_STATE;
                end if;

            when T1L_STATE =>
                pulse_reg <= '0';
                if counter >= T1L_MAX then
                    next_state <= BIT_CHECK_STATE;
                    counter <= 0;
                else
                    counter <= counter + 1;
                    next_state <= T1L_STATE;
                end if;
             
             when BIT_CHECK_STATE =>
                if bit_index = 0 then
                    next_state <= DONE;
                else
                    bit_index <= bit_index - 1;
                    next_state <= PROCESSING;
                end if;
                  
            -- DONE 
            when DONE =>
                led_ready <= '1';
                next_state <= IDLE;

            when others =>
                next_state <= IDLE;
        end case;
    end process;

    pulse_out <= pulse_reg;

end Behavioral;




