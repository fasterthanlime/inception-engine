OOC_FLAGS=-driver=sequence -v -gcc -g +-O0 -noclean +-w -sourcepath=source/ $(shell echo $$OOC_FLAGS)
OOC?=rock

%:
	${OOC} ${OOC_FLAGS} test/$@ -o=$@.x

all:
	@echo "Usage: make <testname>"

clean:
	rm -rf rock_tmp/ *.x
