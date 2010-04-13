OOC_FLAGS=-driver=sequence -v -gcc -g -noclean +-w -sourcepath=source/ $(shell echo $$OOC_FLAGS)
OOC?=rock
TEST?=fall

%:
	${OOC} ${OOC_FLAGS} test/$@ -o=$@.x

all:
	@echo "Usage: make <testname>"

clean:
	rm -rf rock_tmp/ *.x

prof:
	GC_DONT_GC=1 valgrind --tool=callgrind ./${TEST}.x
