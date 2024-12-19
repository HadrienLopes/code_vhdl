library IEEE;
library STD;
use STD.ENV.FINISH;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fifo_rs_tb is
    generic (
        -- Largeur des data
        DATA_WIDTH : integer := 8
    );
end fifo_rs_tb;

architecture testbench of fifo_rs_tb is
  
    -- Testbench signals
    signal clk       : std_logic := '0';
    signal rst_n     : std_logic := '0';
    signal rx        : std_logic := '0';
    signal tx        : std_logic;
    
    -- Testbench constants
    constant clk_period : time := 20 ns;
    constant CMD_PUSH   : std_logic_vector(DATA_WIDTH - 1 downto 0) := "00000001";
    constant CMD_POP    : std_logic_vector(DATA_WIDTH - 1 downto 0) := "00000010";
    constant CMD_STATUS : std_logic_vector(DATA_WIDTH - 1 downto 0) := "00000100";
    
    -- Main testbench component
    component fifo_rs
        port (
            clk       : in  std_logic;
            rst_n     : in  std_logic;
            rx        : in  std_logic;
            tx        : out std_logic
        );
    end component;
    
begin
    uut: fifo_rs
        port map (
            clk => clk,
            rst_n => rst_n,
            rx => rx,
            tx => tx
        );
        
    -- Clock process
    process
    begin
        clk <= '1';
        wait for clk_period / 2;
        clk <= '0';
        wait for clk_period / 2;
    end process;
    
    -- BLC du reset pour le moment
    --rst_n <= '0';

    
    -- Stimulus
    process
    begin
        rst_n <= '1';
        wait for clk_period;
        
        rst_n <= '0';
        wait for clk_period;
        -- Pause de départ
        wait for 3 * clk_period;
        
        -- Test PUSH
        rx <= '1';
        wait for clk_period;
        for i in 0 to 7 loop
            rx <= CMD_PUSH(DATA_WIDTH - 1 - i);
            wait for clk_period;
        end loop;
        rx <= '0';
        wait for clk_period;
        wait for 3 * clk_period;
        
        -- Test POP
        rx <= '1';
        wait for clk_period;
        for i in 0 to 7 loop
            rx <= CMD_POP(DATA_WIDTH - 1 -i);
            wait for clk_period;
        end loop;
        rx <= '0';
        wait for clk_period;
        wait for 3 * clk_period;
        
        -- Test STATUS
        rx <= '1';
        wait for clk_period;
        for i in 0 to 7 loop
            rx <= CMD_STATUS(DATA_WIDTH - 1 -i);
            wait for clk_period;
        end loop;
        rx <= '0';
        wait for clk_period;
        wait for 3 * clk_period;
        
        -- Fin
        finish;
    end process;

end testbench;
