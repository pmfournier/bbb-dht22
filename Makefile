CFLAGS+=-Wall -Werror
LDLIBS+= -lpthread -lprussdrv

all: dht22.bin dht22

clean:
	rm -f dht22 *.o *.bin

dht22.bin: dht22.p
	pasm -b $^

dht22: dht22.o
