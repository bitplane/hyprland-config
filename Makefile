.PHONY: install clean whisper-cpp eww check-deps

# Directories
CONFIG_DIR = $(HOME)/.config
BIN_DIR = $(HOME)/.local/bin
CACHE_DIR = $(HOME)/.cache/dictate
BUILD_DIR = ./build
WHISPER_BUILD = $(BUILD_DIR)/whisper.cpp

# Dependencies (binary:package if different)
DEPS = hyprland waybar gnome-terminal fuzzel mako:mako-notifier grim slurp wf-recorder wl-copy:wl-clipboard wtype wofi wob thunar brightnessctl playerctl blueman-applet:blueman gvim:vim-gtk3 ncal sox curl jq hyprpaper pipewire pw-loopback:pipewire

install: check-deps whisper-cpp eww
	@echo "Installing Hyprland configuration..."

	# Create directories
	mkdir -p $(BIN_DIR)
	mkdir -p $(CACHE_DIR)/models

	# Install Python dependencies
	@echo "Installing Python dependencies..."
	@if command -v pip3 >/dev/null 2>&1; then \
		pip3 install pyudev rofimoji; \
		echo "✓ Python dependencies installed"; \
	else \
		echo "✗ pip3 not found, please install python3-pip"; \
	fi

	# Clean broken symlinks and empty dirs in config
	@find $(CONFIG_DIR) -xtype l -delete 2>/dev/null || true
	@find $(CONFIG_DIR) -type d -empty -delete 2>/dev/null || true

	# Link configs
	@find $(PWD)/config -type f | while read file; do \
		dest="$(CONFIG_DIR)/$${file#$(PWD)/config/}"; \
		mkdir -p "$$(dirname "$$dest")"; \
		ln -sf "$$file" "$$dest"; \
		echo "  Linked $$dest"; \
	done

	# Generate and link soundboard config
	@mkdir -p $(BUILD_DIR)
	@$(PWD)/bin/soundboard-generate
	@ln -sf $(PWD)/build/soundboard.yuck $(CONFIG_DIR)/eww/soundboard.yuck
	@echo "  Linked soundboard.yuck (generated)"

	# Clean broken symlinks and empty dirs in bin
	@find $(BIN_DIR) -xtype l -delete 2>/dev/null || true
	@find $(BIN_DIR) -type d -empty -delete 2>/dev/null || true

	# Link scripts
	chmod +x bin/*
	for script in bin/*; do \
		script_name=$$(basename $$script); \
		ln -sf $(PWD)/$$script $(BIN_DIR)/$$script_name; \
		echo "  Linked $$script_name"; \
	done

	# Link libraries
	@if [ -d lib ]; then \
		mkdir -p $(HOME)/.local/lib; \
		for lib in lib/*; do \
			ln -sf $(PWD)/$$lib $(HOME)/.local/lib/$$(basename $$lib); \
		done; \
		echo "  Linked libraries"; \
	fi

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
	@if [ ! -d lib ] && [ -d $(WHISPER_BUILD)/build/src ]; then \
		mkdir -p lib && \
		cp $(WHISPER_BUILD)/build/src/libwhisper.so* lib/ && \
		cd lib && \
		ln -sf libwhisper.so.* libwhisper.so.1 && \
		ln -sf libwhisper.so.1 libwhisper.so && \
		echo "✓ whisper libraries copied"; \
	fi

eww:
	@if [ ! -f bin/eww ]; then \
		echo "Building eww (this takes a few minutes)..."; \
		echo "Note: requires libgtk-3-dev libdbusmenu-glib-dev libpango1.0-dev libgtk-layer-shell-dev"; \
		mkdir -p $(BUILD_DIR); \
		if [ ! -d $(BUILD_DIR)/eww ]; then \
			git clone https://github.com/elkowar/eww.git $(BUILD_DIR)/eww; \
		fi; \
		cd $(BUILD_DIR)/eww && cargo build --release --no-default-features --features=wayland && \
		cp target/release/eww $(PWD)/bin/eww && \
		echo "✓ eww built"; \
	else \
		echo "✓ eww already built"; \
	fi

check-deps:
	@echo "Checking dependencies..."
	@missing=""; \
	for entry in $(DEPS); do \
		bin=$${entry%%:*}; \
		pkg=$${entry#*:}; \
		if command -v $$bin >/dev/null 2>&1; then \
			echo "✓ $$bin"; \
		else \
			echo "✗ $$bin (missing)"; \
			missing="$$missing $$pkg"; \
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
