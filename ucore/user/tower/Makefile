INCLUDES := ../libs/
INCLUDES += ../../kern/include/


tower: tower.c map.c item.c *.h
	CFLAGS=-I../libs bash ../../compile_userapp_raw.sh $< $@

clean:
	rm -f tower

.PHONY: clean
