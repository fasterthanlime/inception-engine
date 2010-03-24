OOC_FLAGS=-v -noclean -g +-O0 -tcc
OOC?=rock

all:
	${OOC} ${OOC_FLAGS} -sourcepath=source/ $(shell cd source/ && find test/ -name "*.ooc")

clean:
	rm -rf *_tmp/
