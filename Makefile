.PHONY: discover test build check clean

discover:
	./tools/discover-purebasic.sh

test:
	./tools/test.sh

build:
	./tools/build.sh

check:
	./tools/check.sh

clean:
	./tools/clean.sh

