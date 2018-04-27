----------------------------------------------------------------------------------
-- VGA Controller
-- ENGR 378 VGA Controller Lab6
-- Generates the VS, HS, XPosition, and YPosition signals to control VGA signals
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity VGAController is
    Port ( PixelClock : in  STD_LOGIC;
           inRed : in STD_LOGIC_VECTOR (7 downto 0);
			  inGreen : in STD_LOGIC_VECTOR (7 downto 0);
			  inBlue : in STD_LOGIC_VECTOR (7 downto 0);
			  outRed : out STD_LOGIC_VECTOR (7 downto 0);
			  outGreen : out STD_LOGIC_VECTOR (7 downto 0);
			  outBlue : out STD_LOGIC_VECTOR (7 downto 0);
           VertSynchOut : out  STD_LOGIC;
           HorSynchOut : out  STD_LOGIC;
           XPosition : out  STD_LOGIC_VECTOR (10 downto 0);
           YPosition : out  STD_LOGIC_VECTOR (10 downto 0));
end VGAController;

architecture Behavioral of VGAController is

	-- X constants (visible area is 1280 lines)
	-- FOR pixel clock = 108 MHz
	constant XLimit : STD_LOGIC_VECTOR (10 downto 0) := "11010011000"; -- 1688
	constant XVisible : STD_LOGIC_VECTOR (10 downto 0) := "10100000000"; -- 1280
	constant XSynchPulse : STD_LOGIC_VECTOR (10 downto 0) := "00001110000"; -- 112
	constant XBackPorch : STD_LOGIC_VECTOR (10 downto 0) := "00011111000"; -- 248
	
	-- FOR pixel clock = 54 MHz
--	constant XLimit : STD_LOGIC_VECTOR (10 downto 0) := "01101001100"; -- 844
--	constant XVisible : STD_LOGIC_VECTOR (10 downto 0) := "01010000000"; -- 640
--	constant XSynchPulse : STD_LOGIC_VECTOR (10 downto 0) := "00000111000"; -- 56
--	constant XBackPorch : STD_LOGIC_VECTOR (10 downto 0) := "00001111100"; -- 124

	-- Y constants (visible area is 1024 lines)
	constant YLimit : STD_LOGIC_VECTOR (10 downto 0) := "10000101010"; -- 1066
	constant YVisible : STD_LOGIC_VECTOR (10 downto 0) := "10000000000"; -- 1024
	constant YSynchPulse : STD_LOGIC_VECTOR (10 downto 0) := "00000000011"; -- 3
	constant YBackPorch : STD_LOGIC_VECTOR (10 downto 0) := "00000100110"; -- 38
	
	-- for screen resolution VGA Control Signals
	signal XTiming : STD_LOGIC_VECTOR (10 downto 0) := "00000000000";
	signal YTiming : STD_LOGIC_VECTOR (10 downto 0) := "00000000000";
	constant XOffset : STD_LOGIC_VECTOR (10 downto 0) := "00000000000";
	constant YOffset : STD_LOGIC_VECTOR (10 downto 0) := "00000000000";

	signal HorSynch : STD_LOGIC := '0';
	signal VertSynch : STD_LOGIC := '0';
	
begin
		
--	Control logic to calculate Y pixel position
	YPosition <= YTiming - (YSynchPulse + YBackPorch) - YOffset;	
		
-- Control logic to calculate X pixel position
	XPosition <= XTiming - (XSynchPulse + XBackPorch) - XOffset;

	process (Pixelclock)-- control X Timing
	begin
		if Pixelclock'event and Pixelclock = '1' then
			if (XTiming >= XLimit) then
				XTiming <= "00000000000";
			else
				XTiming <= XTiming + 1;
			end if;
		end if;
	end process;
	
	process (Pixelclock)-- control Y TIming
	begin
		if Pixelclock'event and Pixelclock = '1' then
			if (XTiming >= XLimit and YTiming >= YLimit) then -- reset value
				YTiming <= "00000000000";
			elsif (XTiming >= XLimit and YTiming < YLimit) then
				YTiming <= YTiming + 1; -- increment YTiming by one
			else
				YTiming <= YTiming; -- keep current Y value
			end if;
		end if;
	end process;
	
	process (Pixelclock)-- control VerticalSync
	begin
		if Pixelclock'event and Pixelclock = '1' then
			if (YTiming >= 0 and YTiming < YSynchPulse) then
				VertSynch <= '0';
			else
				VertSynch <= '1';
			end if;
		end if;
	end process;
	
	process (Pixelclock)-- control HorizontalSync
	begin
		if Pixelclock'event and Pixelclock = '1' then
			if (XTiming >= 0 and XTiming < XSynchPulse) then -- reset value
				HorSynch <= '0';
			else
				HorSynch <= '1';
			end if;
		end if;
	end process;
	
	-- display black values if drawing off the screen
	outRed <= inRed when XTiming >= ((XSynchPulse + XBackPorch) - XOffset) and XTiming <= ((XSynchPulse + XBackPorch + XVisible) - XOffset)
						 else "00000000";
	outGreen <= inGreen when XTiming >= ((XSynchPulse + XBackPorch) - XOffset) and XTiming <= ((XSynchPulse + XBackPorch + XVisible) - XOffset)
							  else "00000000";
	outBlue <= inBlue when XTiming >= ((XSynchPulse + XBackPorch) - XOffset) and XTiming <= ((XSynchPulse + XBackPorch + XVisible) - XOffset) 
							else "00000000";
	
	-- vertical and horizontal synch signals
	VertSynchOut <= VertSynch;
   HorSynchOut <= HorSynch;

end Behavioral;

