library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Hotel_Management_System_TB is
end Hotel_Management_System_TB;

architecture Behavioral of Hotel_Management_System_TB is

    constant FLOORS : integer := 3;
    constant ROOMS_PER_FLOOR : integer := 5;
    
    signal clk : STD_LOGIC := '0';
    signal reset : STD_LOGIC := '0';
    signal manual_clean_request : STD_LOGIC := '0';
    signal emergency_lock_all : STD_LOGIC := '0';
    signal room_floor : INTEGER range 0 to FLOORS-1 := 0;
    signal room_number : INTEGER range 0 to ROOMS_PER_FLOOR-1 := 0;
    signal pin_input : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal access_request : STD_LOGIC := '0';
    signal lock_request : STD_LOGIC := '0';
    signal unlock_request : STD_LOGIC := '0';
    signal access_granted : STD_LOGIC;
    signal current_time_of_day : STD_LOGIC_VECTOR(1 downto 0);
    signal current_day : STD_LOGIC_VECTOR(2 downto 0);
    signal room_status : STD_LOGIC_VECTOR(7 downto 0);
    
    constant CLOCK_PERIOD : time := 20 ns; 
    
begin

    uut: entity work.Hotel_Management_System
        generic map (
            FLOORS => FLOORS,
            ROOMS_PER_FLOOR => ROOMS_PER_FLOOR,
            DAY_COUNTER_WIDTH => 3
        )
        port map (
            clk => clk,
            reset => reset,
            manual_clean_request => manual_clean_request,
            emergency_lock_all => emergency_lock_all,
            room_floor => room_floor,
            room_number => room_number,
            pin_input => pin_input,
            access_request => access_request,
            lock_request => lock_request,
            unlock_request => unlock_request,
            access_granted => access_granted,
            current_time_of_day => current_time_of_day,
            current_day => current_day,
            room_status => room_status
        );
    
    clk <= not clk after CLOCK_PERIOD / 2;
    
    stim_proc: process
        variable room_id : STD_LOGIC_VECTOR(15 downto 0);
        variable reversed_pin : STD_LOGIC_VECTOR(15 downto 0);
    begin
        reset <= '1';
        wait for 100 ns;
        reset <= '0';
        wait for 100 ns;
        
        report "Test 1: Accessing room with correct PIN";
        room_floor <= 0;
        room_number <= 0;
        
        room_id := (others => '0');
        for i in 0 to 15 loop
            reversed_pin(i) := room_id(15 - i);
        end loop;
        
        pin_input <= reversed_pin;
        access_request <= '1';
        wait for 40 ns;
        access_request <= '0';
        wait for 100 ns;
        
        report "Test 2: Accessing room with wrong PIN";
        pin_input <= X"FFFF";
        access_request <= '1';
        wait for 40 ns;
        access_request <= '0';
        wait for 100 ns;
        
        report "Test 3: Unlocking room";
        pin_input <= reversed_pin;
        unlock_request <= '1';
        wait for 40 ns;
        unlock_request <= '0';
        wait for 100 ns;
        
        report "Test 4: Locking room";
        lock_request <= '1';
        wait for 40 ns;
        lock_request <= '0';
        wait for 100 ns;
        
        report "Test 5: Emergency lock all";
        emergency_lock_all <= '1';
        wait for 100 ns;
        emergency_lock_all <= '0';
        wait for 100 ns;
        
        report "Test 6: Manual cleaning request";
        manual_clean_request <= '1';
        wait for 100 ns;
        manual_clean_request <= '0';
        
        report "Test 7: Observing Automatic Time/Day Changes (Auto-Clean Check)";
        
        for i in 1 to 30 loop
            wait for 100 ns; 
            
            if (room_status(3) = '1') then 
                 report ">>> SUKSES: AUTO CLEANING DETECTED! (Day: " & integer'image(to_integer(unsigned(current_day))) & ") <<<";
            end if;
            
            if (current_time_of_day = "11") then
                 report ">>> SUKSES: NIGHT TIME AUTO-LOCK DETECTED <<<";
            end if;
        end loop;
        
        report "=== FINAL HOTEL MATRIX STATUS ===";
            
        for f in 0 to FLOORS-1 loop
            for r in 0 to ROOMS_PER_FLOOR-1 loop
                room_floor <= f;
                room_number <= r;
                wait for 10 ns; 
                
                report "Floor " & integer'image(f) & 
                        " | Room " & integer'image(r) & 
                        " | Status: " & integer'image(to_integer(unsigned(room_status)));
            end loop;
        end loop;
            
        report "Simulation completed";
        wait;
    end process;
    
    monitor_proc: process
    begin
        wait for 150 ns; 
        
        loop
            wait for 100 ns;
            report "Time: " & integer'image(to_integer(unsigned(current_time_of_day))) & 
                   " Day: " & integer'image(to_integer(unsigned(current_day))) &
                   " Room Status: " & integer'image(to_integer(unsigned(room_status)));
        end loop;
    end process;
    
end Behavioral;