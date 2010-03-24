OOC_FLAGS=-v -noclean -g +-O0 -gcc +-w -sourcepath=source/ $(shell echo $$OOC_FLAGS)
OOC?=rock

%:
	${OOC} ${OOC_FLAGS} test/$@

all:
	${OOC} ${OOC_FLAGS} $(shell cd source/ && find test/ -name "*.ooc")

clean:
	rm -rf *_tmp/
