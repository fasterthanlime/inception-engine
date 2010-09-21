
#OOC_FLAGS=-v -g +-w -sourcepath=source -DNO_STDIO_REDIRECT +-mwindows -lmingw32 -lSDLmain -lSDL -lopengl32 -lglu32 -lglew32 $(shell echo $$OOC_FLAGS)
OOC_FLAGS=-v -g +-w -sourcepath=source -DNO_STDIO_REDIRECT $(shell echo $$OOC_FLAGS)

OOC?=rock
TEST?=fall

%:
	${OOC} ${OOC_FLAGS} test/$@ -o=$@.x

all:
	@echo "Usage: make <testname>"

clean:
	rm -rf rock_tmp/ .libs/ *.x

prof:
	GC_DONT_GC=1 valgrind --tool=callgrind ./${TEST}.x
