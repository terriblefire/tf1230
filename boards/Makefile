PREFIX:=tf330
BOARDS:=$(PREFIX)r2 $(PREFIX)r3 $(PREFIX)r1
.PHONY: $(BOARDS)
FOLDER:=$(PREFIX)_`date +"%Y_%m_%d"`
all: clean
	rm -rf ./$(PREFIX)_*
	mkdir ./$(FOLDER)
	@- $(foreach BOARD,$(BOARDS), make -C $(BOARD); \
	cp $(BOARD)/*.jed ./$(FOLDER);)
	zip $(FOLDER)_alpha.zip ./$(FOLDER)/*
	rm -rf $(FOLDER)
clean: 
	@- $(foreach BOARD,$(BOARDS), make -C $(BOARD) clean;)
distclean: 
	@- $(foreach BOARD,$(BOARDS), make -C $(BOARD) distclean;)
	rm -rf $(BOARD)_20*
