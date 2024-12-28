ifeq ($(GOPATH),)
    GOPATH := $(HOME)/go
    $(info GOPATH not set, using default: $(GOPATH))
endif

BINARY := mods
BINARY_DIR := bin
INSTALL_DIR := $(GOPATH)/bin

# Define GOFILES to identify all Go files except test files
GOFILES := $(filter-out %_test.go,$(wildcard *.go))
TST_FILES := $(wildcard *_test.go)

CP := $(shell which cp)
GO := $(shell which go)
GOCYCLO := $(shell which gocyclo 2>/dev/null)

CPFLAGS := -p
TESTFLAGS := -cover -coverprofile=coverage.out

$(shell mkdir -p $(BINARY_DIR))

all: check build

build: $(BINARY_DIR)/$(BINARY)

$(BINARY_DIR)/$(BINARY): $(GOFILES)
	$(GO) build -o $@ $^

clean:
	rm -rf $(BINARY_DIR) coverage.out

test: $(TST_FILES)
	@echo "Running Go tests..."
	$(GO) test $(TESTFLAGS) $(if $(VERBOSE),-v)
	@if [ -x "$(GOCYCLO)" ]; then \
		echo -e "\nRunning cyclomatic complexity test..."; \
		$(GOCYCLO) --over 12 . || exit 0; \
	fi

check: vet

fmt: $(GOFILES)
	$(GO) fmt ./...

vet: $(GOFILES) fmt
	$(GO) vet ./...

run: $(BINARY_DIR)/$(BINARY)
	./$(BINARY_DIR)/$(BINARY)

install: all
	@mkdir -p $(INSTALL_DIR)
	$(CP) $(CPFLAGS) $(BINARY_DIR)/$(BINARY) $(INSTALL_DIR)
	@echo "Installed $(BINARY) to $(INSTALL_DIR)"

.PHONY: all build clean test check fmt vet run install
