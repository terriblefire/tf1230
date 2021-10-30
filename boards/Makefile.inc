RTLFOLDER=../../rtl/
SOURCES="./$(BOARD)r$(REVISION)_main_top.v $(RTLFOLDER)/main_top.v $(RTLFOLDER)/ata.v $(RTLFOLDER)/arb.v $(RTLFOLDER)/clocks.v $(RTLFOLDER)/autoconfig.v $(RTLFOLDER)/gayle.v $(RTLFOLDER)/sdram.v $(RTLFOLDER)/sdram_init.v"

$(BOARD)r$(REVISION): clean $(BOARD)r$(REVISION)_main $(BOARD)r$(REVISION)_main_288
$(BOARD)r$(REVISION)_main:
	make -f ../Makefile.cpld BOARD=$(BOARD) SOURCES=$(SOURCES) SUBPROJ=main REVISION=$(REVISION) OPTMODE=speed OPTIMISE=speed TARGET=$(TARGET) SERIALNO=$(SERIALNO)
$(BOARD)r$(REVISION)_main_288:
	make -f ../Makefile.cpld BOARD=$(BOARD) SOURCES=$(SOURCES) SUBPROJ=main REVISION=$(REVISION) OPTMODE=speed OPTIMISE=speed TARGET=$(TARGET) SERIALNO=$(SERIALNO) PART=XC95288XL-10-TQ144 JEDEXTRA=_288

zip: distclean $(BOARD)r$(REVISION)
	zip $(BOARD)r$(REVISION)_`date +"%Y_%m_%d"`_alpha.zip *.jed
clean:	
	rm -rf work _xmsgs *.zip
validate:
	../validate.py --board=$(BOARD) --rev=$(REVISION) --chip=main
distclean: clean
	rm -f *.jed *~ *.svf 