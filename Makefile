.SUFFIXES:
OPTION=-D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -m64
SHELL=/bin/sh


all: chin_lib.o count group generate_pattern remove_poly_n ngs_qc exgrep

chin_lib.o: chin_lib.c chin_lib.h
	gcc $(OPTION) $(MACHINE_DEPENDENT) -c chin_lib.c -o chin_lib.o

count: count.c chin_lib.o
	gcc $(OPTION) -O count.c -o count

group: group.c chin_lib.o
	gcc $(OPTION) -O -I. group.c -o group chin_lib.o -lm

remove_poly_n: remove_poly_n.c chin_lib.o
	gcc $(OPTION) -O -I. remove_poly_n.c -o remove_poly_n chin_lib.o -lm

generate_pattern: generate_pattern.c chin_lib.o
	gcc $(OPTION) -O -I. generate_pattern.c -o generate_pattern chin_lib.o -lm

ngs_qc: ngs_qc.c chin_lib.o chin_lib.h
	gcc $(OPTION) -I. ngs_qc.c -o ngs_qc chin_lib.o -lm

exgrep: exgrep.c chin_lib.o
	gcc $(OPTION) -O -I. exgrep.c -o exgrep chin_lib.o -lm

