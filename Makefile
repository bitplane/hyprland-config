.PHONY: install clean whisper-cpp check-deps

# Directories
CONFIG_DIR = $(HOME)/.config
BIN_DIR = $(HOME)/.local/bin
CACHE_DIR = $(HOME)/.cache/dictate
BUILD_DIR = ./build
WHISPER_BUILD = $(BUILD_DIR)/whisper.cpp

# Dependencies
DEPS = hyprland waybar gnome-terminal fuzzel mako grim slurp wf-recorder wl-copy wtype rofimoji ncal sox curl jq

install: check-deps whisper-cpp
	@echo "Installing Hyprland configuration..."

	# Create directories
	mkdir -p $(CONFIG_DIR)/{hypr,waybar}
	mkdir -p $(BIN_DIR)
	mkdir -p $(CACHE_DIR)/models

	# Install Python dependencies (pyudev for battery-monitor)
	@echo "Installing Python dependencies..."
	@if command -v pip3 >/dev/null 2>&1; then \
		pip3 install --user pyudev; \
		echo "✓ pyudev installed"; \
	else \
		echo "✗ pip3 not found, please install python3-pip"; \
	fi

	# Link configs
	ln -sf $(PWD)/config/hypr/hyprland.conf $(CONFIG_DIR)/hypr/hyprland.conf
	ln -sf $(PWD)/config/waybar/config $(CONFIG_DIR)/waybar/config
	ln -sf $(PWD)/config/waybar/style.css $(CONFIG_DIR)/waybar/style.css

	# Link scripts
	chmod +x bin/*
	for script in bin/*; do \
		script_name=$$(basename $$script); \
		ln -sf $(PWD)/$$script $(BIN_DIR)/$$script_name; \
		echo "  Linked $$script_name"; \
	done

	# Download Whisper model if needed
	@if [ ! -f $(CACHE_DIR)/models/ggml-base.bin ]; then \
		echo "Downloading Whisper base model..."; \
		curl -L https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.bin \
			-o $(CACHE_DIR)/models/ggml-base.bin; \
	else \
		echo "✓ Whisper model already downloaded"; \
	fi

	@echo ""
	@echo "✓ Installation complete!"
	@echo "Restart Hyprland or reload config with: hyprctl reload"

whisper-cpp:
	@if [ ! -f bin/whisper-server ]; then \
		echo "Building whisper.cpp..."; \
		mkdir -p $(BUILD_DIR); \
		if [ ! -d $(WHISPER_BUILD) ]; then \
			git clone https://github.com/ggml-org/whisper.cpp.git $(WHISPER_BUILD); \
		fi; \
		cd $(WHISPER_BUILD) && \
		cmake -B build -DWHISPER_BUILD_SERVER=ON && \
		cmake --build build --config Release && \
		cd $(PWD) && \
		cp $(WHISPER_BUILD)/build/bin/whisper-server bin/whisper-server && \
		echo "✓ whisper-server built"; \
	else \
		echo "✓ whisper-server already built"; \
	fi

check-deps:
	@echo "Checking dependencies..."
	@missing=""; \
	for dep in $(DEPS); do \
		if command -v $$dep >/dev/null 2>&1; then \
			echo "✓ $$dep"; \
		else \
			echo "✗ $$dep (missing)"; \
			missing="$$missing $$dep"; \
		fi; \
	done; \
	if [ -n "$$missing" ]; then \
		echo ""; \
		echo "Missing dependencies. Install with:"; \
		echo "  sudo apt install$$missing"; \
		echo ""; \
	fi

clean:
	rm -rf $(BUILD_DIR)
	rm -f bin/whisper-server
	@echo "Cleaned build artifacts"
