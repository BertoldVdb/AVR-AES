#Copyright (c) 2016, Bertold Van den Bergh
#All rights reserved.
#
#Redistribution and use in source and binary forms, with or without
#modification, are permitted provided that the following conditions are met:
#    * Redistributions of source code must retain the above copyright
#      notice, this list of conditions and the following disclaimer.
#    * Redistributions in binary form must reproduce the above copyright
#      notice, this list of conditions and the following disclaimer in the
#      documentation and/or other materials provided with the distribution.
#    * Neither the name of the author nor the
#      names of its contributors may be used to endorse or promote products
#      derived from this software without specific prior written permission.
#
#THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
#ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR DISTRIBUTOR BE LIABLE FOR ANY
#DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

DEVICE  = atmega328p
F_CPU   = 8000000
AVRDUDE = avrdude -c arduino -p $(DEVICE) -b 57600

CCARCH=avr
CC=$(CCARCH)-gcc
SIZE=$(CCARCH)-size
OBJCOPY=$(CCARCH)-objcopy

CFLAGS=-c -Wall -Os -DF_CPU=$(F_CPU) -mmcu=$(DEVICE)
LDFLAGS=-mmcu=$(DEVICE)

EXECUTABLE=aes_demo
INCLUDES=aes.h
SOURCES_C=main.c aes.c
SOURCES_S=aes_asm.S

OBJECTS_OBJ=$(addprefix obj/,$(SOURCES_C:.c=.o)) $(addprefix obj/,$(SOURCES_S:.S=.o))
INCLUDES_SRC=$(addprefix src/,$(INCLUDES))
SOURCES_SRC=$(addprefix src/,$(SOURCES_C)) $(addprefix src/,$(SOURCES_S))

all: $(EXECUTABLE).hex

flash: $(EXECUTABLE).hex
	sudo $(AVRDUDE) -U flash:w:$(EXECUTABLE).hex:i -P /dev/ttyUSB0

$(EXECUTABLE).hex: obj/$(EXECUTABLE).elf
	$(OBJCOPY) obj/$(EXECUTABLE).elf -O ihex $(EXECUTABLE).hex	
	
obj/$(EXECUTABLE).elf: $(OBJECTS_OBJ)
	$(CC) $(LDFLAGS) $(OBJECTS_OBJ) -o $@
	$(SIZE) $@	
	
obj/%.o: src/%.S $(INCLUDES_SRC)
	$(CC) $(CFLAGS) $< -o $@

obj/%.o: src/%.c $(INCLUDES_SRC)
	$(CC) $(CFLAGS) $< -o $@

clean:
	rm $(OBJECTS_OBJ) obj/$(EXECUTABLE).elf $(EXECUTABLE).hex

