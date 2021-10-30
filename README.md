# tf1230

TF1230 source files. 

Released int Creative Commons CC-BY-ND license. 

TF1230 is distributed with absolutely no warranty. If you make a mistake you could blow up your A1200. I take no responsibility for this. 

The TF1230 is an 030 accelerator fixed at 50Mhz with 64Mb of SDRAM (128Mb possible), and is intended to work with CF cards or IDE2SD card type devices. The IDE interface does not work with long cables. It is intended to be CHEAP Because thats pretty much all Amiga users care about. You need the ehide.device to use the onboard ide.

There was a design decision to make with the TF ide. Do we make it work as the default ide device and break PCMCIA support, do we add a rom on the card (and more expense) or do we just provide a driver that you can put in a cheap rom and run that way (or just run from disk). I figured the cheapest and least invasive option was the best for a home build solution.

**Before you start building :- You can buy these from Supaduper & AlenPPC (AmiBay) completely built for less than it will cost you to buy the parts and the time it will take you if you bill your time at minimum wage.**

Also do not ask me to reroute the board to a different DRC so you can use your local boardhouse. I dont feel like spending 100 hours of my time to save you $10. The DRC on this board is 7-7-7 and any boardhouse that doesnt totally suck can do this. Also it 4 layer and dont ask if i can be made 2 layer. The answer is no. 

If you need help with this the best place to get it is the exxos forum https://www.exxoshost.co.uk/forum/ 

The SDRAM Controller is derived from my Archie core and the clock controller code is designed to simulate a PLL with adjustable phase. 

This is not an exercise in German over engineering. Its engineered to do an exact task and nothing more. You will need to do the timing fixes or put a clock buffer on the clock line on this board. I didnt do this because i believe that the timing changes are needed on Amigas and not doing them is bad for them long term. Cards that let you get away without doing it are doing you a diservice. It would be like cards letting you go longer without a recap. Its 

That said you are free to sell this on your webshop provided you give credit and do not vastly overprice it. However CE marking is your own issue not mine. AmigaKit may not sell this ever... anyone else can. 

On the other hand if you have an actual firmware bugfix send me a pull request with testing evidence. It will be appreciated greatly. 

For crashes please check that the crash doesnt happen in WinUAE for a A1200 with A1200 IDE and 64MB ZIII Ram before making a bug report. Most of the crashes we have seen over the years are repeatable in that environment.

The purpose of this card is for you to get more enjoyment from your Amiga for very little money. Please do that. 


