# Define the compiler and flags
ODIN = odin
SRC_DIR = src
OUT_DIR_DEBUG = out/debug
OUT_DIR_RELEASE = out/release
PROGRAM_NAME = funhalla

# Define the build targets
all: debug release

debug: $(OUT_DIR_DEBUG)/$(PROGRAM_NAME)

release: $(OUT_DIR_RELEASE)/$(PROGRAM_NAME)

# Rule for building the debug version
$(OUT_DIR_DEBUG)/$(PROGRAM_NAME): $(SRC_DIR)/*.odin
	@mkdir -p $(OUT_DIR_DEBUG)
	$(ODIN) build $(SRC_DIR) -out:$(OUT_DIR_DEBUG)/$(PROGRAM_NAME) --debug -define:GL_DEBUG=true

# Rule for building the release version
$(OUT_DIR_RELEASE)/$(PROGRAM_NAME): $(SRC_DIR)/*.odin
	@mkdir -p $(OUT_DIR_RELEASE)
	$(ODIN) build $(SRC_DIR) -out:$(OUT_DIR_RELEASE)/$(PROGRAM_NAME)

# Clean up build artifacts
clean:
	rm -rf $(OUT_DIR_DEBUG) $(OUT_DIR_RELEASE)

.PHONY: all debug release clean
