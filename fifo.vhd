library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fifo is
    generic (
        DATA_WIDTH : integer := 8; -- Largeur des data
        DEPTH      : integer := 16 -- Profondeur de la FIFO
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
end fifo;

architecture Behavioral of fifo is
    type memory_array is array (0 to DEPTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal mem    : memory_array := (others => (others => '0'));
    signal wr_ptr  : natural range 0 to DEPTH-1 := 0;
    signal rd_ptr  : natural range 0 to DEPTH-1 := 0;
    signal count  : natural range 0 to DEPTH := 0;
begin
  
    -- Signaux FULL et EMPTY
    full <= '1' when count = DEPTH else '0';
    empty <= '1' when count = 0 else '0';

    process(clk, rst_n)
    begin
        if rst_n = '1' then
            count <= 0;
            wr_ptr <= 0;
            rd_ptr <= 0;
        end if;
        
        if rising_edge(clk) then
            -- Gestion de PUSH
            if push = '1' and count < DEPTH then
                mem(wr_ptr) <= din;
                wr_ptr <= (wr_ptr + 1) mod DEPTH;
                count <= count + 1;
            end if;

            -- Gestion de POP
            if pop = '1' and count > 0 then
                dout <= mem(rd_ptr);
                mem(rd_ptr) <= (others => '0');
                rd_ptr <= (rd_ptr + 1) mod DEPTH;
                count <= count - 1;
            end if;
        end if;
    end process;

end Behavioral;


