.PHONY: discover test build docs check clean

discover:
	./tools/discover-purebasic.sh

test:
	./tools/test.sh

build:
	./tools/build.sh

docs:
	./tools/build-docs.sh

check:
	./tools/check.sh

clean:
	./tools/clean.sh
