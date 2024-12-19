library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fifo_rs is
    generic (
        -- Largeur des data
        DATA_WIDTH : integer := 8;
        DEPTH      : integer := 16
    );
    port (
        clk       : in  std_logic;
        rst_n     : in  std_logic;
        rx        : in  std_logic;
        tx        : out std_logic
    );
end fifo_rs;

architecture integration of fifo_rs is
    -- Signaux deserializer
    signal s_rx_ack : std_logic;
    signal s_rx_valid : std_logic;
    signal s_rx_data : std_logic_vector(DATA_WIDTH - 1 downto 0);
    
    -- Signaux serializer
    signal s_tx_ack : std_logic;
    signal s_tx_valid : std_logic;
    signal s_tx_data : std_logic_vector(DATA_WIDTH - 1 downto 0);
    
    -- Signaux fifo
    signal s_push : std_logic;
    signal s_pop : std_logic;
    signal s_empty : std_logic;
    signal s_full : std_logic;
    signal s_data_fifo_to_controller : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal s_data_controller_to_fifo : std_logic_vector(DATA_WIDTH - 1 downto 0);

    -- Declaration modules
    -- Deserializer component
    component deserializer port (
        clk    : in  std_logic;
        rst_n  : in  std_logic;
        rx     : in  std_logic;
        ack    : in  std_logic;
        valid  : out std_logic;
        data   : out std_logic_vector(DATA_WIDTH - 1 downto 0)
    ); end component;
    -- Serializer component
    component serializer port (
        clk    : in  std_logic;
        rst_n  : in  std_logic;
        valid  : in std_logic;
        data   : in std_logic_vector(DATA_WIDTH - 1 downto 0);
        ack    : out  std_logic;
        tx     : out  std_logic
    ); end component;
    -- FIFO component
    component fifo port (
        clk    : in  std_logic;
        rst_n  : in  std_logic;
        push   : in  std_logic;
        pop    : in  std_logic;
        din    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        dout   : out std_logic_vector(DATA_WIDTH-1 downto 0);
        full   : out std_logic;
        empty  : out std_logic
    ); end component;
    -- Controller component
    component controller port (
        clk      : in  std_logic;
        rst_n    : in  std_logic;

        rx_data  : in std_logic_vector(DATA_WIDTH - 1 downto 0);
        rx_valid : in std_logic;
        rx_ack   : out std_logic;

        tx_ack   : in std_logic;
        tx_valid : out std_logic;
        tx_data  : out std_logic_vector(DATA_WIDTH - 1 downto 0);
        
        empty    : in  std_logic;
        full     : in  std_logic;
        din      : in  std_logic_vector(DATA_WIDTH - 1 downto 0);

        push     : out std_logic;
        pop      : out std_logic;
        dout     : out  std_logic_vector(DATA_WIDTH - 1 downto 0)
    ); end component;


begin
    -- Deserializer module
    deserializer_module: deserializer
        port map (
            clk => clk,
            rst_n => rst_n,
            rx => rx,
            ack => s_rx_ack,
            valid => s_rx_valid,
            data => s_rx_data
        );

    -- Serializer module
    serializer_module: serializer
        port map (
            clk => clk,
            rst_n => rst_n,
            valid => s_tx_valid,
            data => s_tx_data,
            ack => s_tx_ack,
            tx => tx
        );

    -- FIFO module
    fifo_module: fifo
        port map (
            clk => clk,
            rst_n => rst_n,
            din => s_data_controller_to_fifo,
            push => s_push,
            pop => s_pop,
            dout => s_data_fifo_to_controller,
            empty => s_empty,
            full => s_full
        );
    
    -- Controller module
    controller_module: controller
        port map (
            clk => clk,
            rst_n => rst_n,

            rx_data => s_rx_data,
            rx_valid => s_rx_valid,
            rx_ack => s_rx_ack,

            tx_ack => s_tx_ack,
            tx_valid => s_tx_valid,
            tx_data => s_tx_data,
            
            empty => s_empty,
            full => s_full,
            din => s_data_fifo_to_controller,

            push => s_push,
            pop => s_pop,
            dout => s_data_controller_to_fifo
        );

end integration;


