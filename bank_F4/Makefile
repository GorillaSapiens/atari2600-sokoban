BINS = \
           pusher0.bin \
           pusher1.bin \
           pusher2.bin \
           pusher3.bin \
           pusher4.bin \
           pusher5.bin \
           pusher6.bin \
           pusher7.bin

all: pusher.bin dttest.bin

timing:
	../timing.pl < pusher.asm > x
	mv x pusher.asm

dttest.bin: dttest.asm ../deepthought.h
	dasm dttest.asm -DNO_ILLEGAL_OPCODES=0 -ldttest.lst -f3 -v5 -odttest.bin

pusher.bin: $(BINS) Makefile
	cat $(BINS) > pusher.bin
	cp pusher0.sym pusher.sym


pusher0.asm: pusher.asm Makefile
	cat pusher.asm | sed "s/NEXTBANK/\$$1FF5/g" | sed "s/BANKLEVEL/BANK0/g" >pusher0.asm

pusher0.bin: pusher0.asm logo.h pusher0.asm pusher.h levels.h Makefile
	dasm pusher0.asm -DNO_ILLEGAL_OPCODES=0 -lpusher0.lst -f3 -v5 -spusher0.sym -opusher0.bin

pusher1.asm: pusher.asm Makefile
	cat pusher.asm | sed "s/NEXTBANK/\$$1FF6/g" | sed "s/BANKLEVEL/BANK1/g" >pusher1.asm

pusher1.bin: pusher1.asm logo.h pusher1.asm pusher.h levels.h Makefile
	dasm pusher1.asm -DNO_ILLEGAL_OPCODES=0 -lpusher1.lst -f3 -v5 -spusher1.sym -opusher1.bin

pusher2.asm: pusher.asm Makefile
	cat pusher.asm | sed "s/NEXTBANK/\$$1FF7/g" | sed "s/BANKLEVEL/BANK2/g" >pusher2.asm

pusher2.bin: pusher2.asm logo.h pusher2.asm pusher.h levels.h Makefile
	dasm pusher2.asm -DNO_ILLEGAL_OPCODES=0 -lpusher2.lst -f3 -v5 -spusher2.sym -opusher2.bin

pusher3.asm: pusher.asm Makefile
	cat pusher.asm | sed "s/NEXTBANK/\$$1FF8/g" | sed "s/BANKLEVEL/BANK3/g" >pusher3.asm

pusher3.bin: pusher3.asm logo.h pusher3.asm pusher.h levels.h Makefile
	dasm pusher3.asm -DNO_ILLEGAL_OPCODES=0 -lpusher3.lst -f3 -v5 -spusher3.sym -opusher3.bin

pusher4.asm: pusher.asm Makefile
	cat pusher.asm | sed "s/NEXTBANK/\$$1FF9/g" | sed "s/BANKLEVEL/BANK4/g" >pusher4.asm

pusher4.bin: pusher4.asm logo.h pusher0.asm pusher.h levels.h Makefile
	dasm pusher4.asm -DNO_ILLEGAL_OPCODES=0 -lpusher4.lst -f3 -v5 -spusher4.sym -opusher4.bin

pusher5.asm: pusher.asm Makefile
	cat pusher.asm | sed "s/NEXTBANK/\$$1FFA/g" | sed "s/BANKLEVEL/BANK5/g" >pusher5.asm

pusher5.bin: pusher5.asm logo.h pusher1.asm pusher.h levels.h Makefile
	dasm pusher5.asm -DNO_ILLEGAL_OPCODES=0 -lpusher5.lst -f3 -v5 -spusher5.sym -opusher5.bin

pusher6.asm: pusher.asm Makefile
	cat pusher.asm | sed "s/NEXTBANK/\$$1FFB/g" | sed "s/BANKLEVEL/BANK6/g" >pusher6.asm

pusher6.bin: pusher6.asm logo.h pusher2.asm pusher.h levels.h Makefile
	dasm pusher6.asm -DNO_ILLEGAL_OPCODES=0 -lpusher6.lst -f3 -v5 -spusher6.sym -opusher6.bin

pusher7.asm: pusher.asm Makefile
	cat pusher.asm | sed "s/NEXTBANK/\$$1FF4/g" | sed "s/BANKLEVEL/BANK7/g" >pusher7.asm

pusher7.bin: pusher7.asm logo.h pusher3.asm pusher.h levels.h Makefile
	dasm pusher7.asm -DNO_ILLEGAL_OPCODES=0 -lpusher7.lst -f3 -v5 -spusher7.sym -opusher7.bin



logo.h: logo.txt logo2code.pl Makefile
	./logo2code.pl < logo.txt > logo.h

levels.h: translate.pl Makefile
	cat ../levels/Original.slc \
           ../levels/Original01.slc \
           ../levels/Original02.slc \
           ../levels/Original_3.slc \
	   ../levels/Original_Extra_Sharpen.slc \
           ../levels/Ionic_Catalysts.slc \
           ../levels/Various.slc \
           | ./translate.pl > levels.h
#	cat levels/Zone_26.slc | ./translate.pl > levels.h

clean:
	rm -f pusher[0-7]* pusher.sym pusher.lst pusher.bin levels.h logo.h
	rm -f dttest.bin dttest.lst
