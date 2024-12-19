library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity fifo_tb is
end fifo_tb;

architecture Behavioral of fifo_tb is
    constant DATA_WIDTH   : integer := 8;
    constant DEPTH        : integer := 16;
    constant clock_period : time    := 10ns;
    constant reset_time   : time    := (clock_period * 10) + 10ns;

    signal clk    : std_logic := '0';
    signal rst_n  : std_logic := '0';
    signal push   : std_logic := '0';
    signal pop    : std_logic := '0';
    signal din    : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal dout   : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal full   : std_logic;
    signal empty  : std_logic;

    component fifo
        generic (
            DATA_WIDTH : integer;
            DEPTH      : integer
        );
        port (
            clk    : in  std_logic;
            rst_n  : in  std_logic;
            push   : in  std_logic;
            pop    : in  std_logic;
            din    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            dout   : out std_logic_vector(DATA_WIDTH-1 downto 0);
            full   : out std_logic;
            empty  : out std_logic
        );
    end component;
begin
    uut: fifo
        generic map (
            DATA_WIDTH => DATA_WIDTH,
            DEPTH      => DEPTH
        )
        port map (
            clk    => clk,
            rst_n  => rst_n,
            push   => push,
            pop    => pop,
            din    => din,
            dout   => dout,
            full   => full,
            empty  => empty
        );

    -- Clock
    clk_process: process
    begin
        while true loop
            clk <= '0';
            wait for (clock_period / 2);
            clk <= '1';
            wait for (clock_period / 2);
        end loop;
    end process;
    
    -- Reset
    reset_process: process
    begin
        while true loop
            rst_n <= '0';
            wait for (37+5)*clock_period + 3ns;
            rst_n <= '1';
            wait for clock_period - 3ns;
            rst_n <= '0';
            wait for (37-5-6)*clock_period + 5ns;
            rst_n <= '1';
            wait for 5*clock_period - 5ns;
        end loop;
    end process;
    
    
    -- Test
    stimulus: process
    begin
        
        -- ## PUSH TESTS SECTION ## --
        -- Data IN without PUSH
        din <= std_logic_vector(to_unsigned(10, DATA_WIDTH));
        wait for clock_period;
        
        -- Fill the FIFO
        for i in 0 to 15 loop
            push <= '1';
            din <= std_logic_vector(to_unsigned(i, DATA_WIDTH));
            wait for clock_period;
        end loop;
        push <= '0';
        wait for clock_period;

        -- PUSH on FIFO full
        push <= '1';
        din <= std_logic_vector(to_unsigned(10, DATA_WIDTH));
        wait for clock_period;
        
        -- End the PUSH test
        push <= '0';


        -- ## POP TESTS SECTION ## ---
        -- Empty the FIFO
        for i in 0 to 15 loop
            pop <= '1';
            wait for clock_period;
        end loop;
        pop <= '0';
        wait for clock_period;
        
        -- POP on empty FIFO
        pop <= '1';
        wait for clock_period;
    end process;

end Behavioral;
