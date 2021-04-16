CC = gcc
CFLAGS = -g -Wall -std=c99 -c
LDFLAGS = -g -Wall

BUILD_DIR = ./build

# A phony target is one that is not really the name of a file;
# rather it is just a name for a recipe to be executed when you make an explicit request.
# You can read more about them here: https://www.gnu.org/software/make/manual/html_node/Phony-Targets.html
.PHONY : all test clean

all : philphix

philphix : philphix.o hashtable.o
	$(CC) $(LDFLAGS) -o philphix $(BUILD_DIR)/philphix.o $(BUILD_DIR)/hashtable.o

philphix.o : src/philphix.c src/philphix.h src/hashtable.h build_dir
	$(CC) $(CFLAGS) src/philphix.c -o $(BUILD_DIR)/philphix.o

hashtable.o : src/hashtable.c src/hashtable.h build_dir
	$(CC) $(CFLAGS) src/hashtable.c -o $(BUILD_DIR)/hashtable.o

build_dir :
	mkdir -p $(BUILD_DIR)

clean :
	rm -f $(BUILD_DIR)/*.o philphix tests/sanity/testOutput

# Make sure you leave testpassedall as the last thing in this line. You can add your own custom tests before it.
test: testbasic testedge testpassedall

testbasic: clean philphix
	touch tests/sanity/testOutput
	rm tests/sanity/testOutput
	@echo "================Running Program...================="
	cat tests/sanity/test | ./philphix tests/sanity/replace > tests/sanity/testOutput
	@echo "================Program Finished!=================="
	@echo ""
	@echo "Difference between test output and reference output"
	@echo "---------------------------------------------------"
	@diff tests/sanity/testOutput tests/sanity/reference
	@echo "-----------------------None!-----------------------"
	@echo

testedge: philphix
	@echo "Making the test files!"
	@echo
	@echo "A A" > null.txt
	@echo "================Running Program...================="
	cat philphix | ./philphix null.txt > newphilphix
	@echo "================Program Finished!=================="
	@echo ""
	@echo "Difference between test output and reference output"
	@echo "---------------------------------------------------"
	@diff philphix newphilphix
	@echo "-----------------------None!-----------------------"
	@rm -f null.txt newphilphix
	@echo

testpassedall:
	@echo "You have passed all of the tests!"
