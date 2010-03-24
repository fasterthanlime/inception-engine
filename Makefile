OOC_FLAGS=-v -noclean -g +-O0
OOC?=rock

all:
	${OOC} ${OOC_FLAGS} -sourcepath=source/ test/hiworld -o=hiworld

clean:
	rm -rf *_tmp/
