OOC_FLAGS=-v -noclean -g +-O0 -noclean -driver=sequence -gcc +-w -sourcepath=source/ $(shell echo $$OOC_FLAGS)
OOC?=rock

%:
	${OOC} ${OOC_FLAGS} test/$@ -o=$@.x

all:
	@echo "Usage: make <testname>"

clean:
	rm -rf *_tmp/ *.x
