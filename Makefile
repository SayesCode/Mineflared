# Compiler
CC = gcc

# Compiler flags
CFLAGS = -Wall -g

# Directories
INCLUDE_DIR = firewall/include
SRC_DIR = firewall/src
TEST_DIR = firewall/tests
CONFIG_DIR = firewall/config

# Output executable
TARGET = minefirewall

# Source files
SRC_FILES = $(SRC_DIR)/main.c $(SRC_DIR)/rules.c $(SRC_DIR)/utils.c $(SRC_DIR)/firewall.c $(SRC_DIR)/logging.c
TEST_FILES = $(TEST_DIR)/test_rules.c $(TEST_DIR)/test_firewall.c

# Include headers
INCLUDES = -I$(INCLUDE_DIR)

# Default rule to compile the firewall
all: $(TARGET)

# Rule to link the object files and create the executable
$(TARGET): $(SRC_FILES)
	$(CC) $(CFLAGS) $(INCLUDES) -o $(TARGET) $(SRC_FILES)

# Rule to run tests
test: $(TARGET)
	$(CC) $(CFLAGS) $(INCLUDES) -o test_rules $(TEST_DIR)/test_rules.c $(SRC_FILES)
	./test_rules
	$(CC) $(CFLAGS) $(INCLUDES) -o test_firewall $(TEST_DIR)/test_firewall.c $(SRC_FILES)
	./test_firewall

# Clean up the generated files
clean:
	rm -f $(TARGET) test_rules test_firewall
