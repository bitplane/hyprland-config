#!/usr/bin/python3
import time
import os
import sys

DEVICE = "/sys/bus/hid/drivers/razerkbd/0003:1532:028C.0006"

def set_key_color(row, col, r, g, b):
    try:
        with open(f"{DEVICE}/matrix_effect_custom", "w") as f:
            f.write("1")
        frame_data = bytes([row, col, col, r, g, b])
        with open(f"{DEVICE}/matrix_custom_frame", "wb") as f:
            f.write(frame_data)
        return True
    except:
        return False

def clear_keyboard():
    """Properly reset all keys to black"""
    try:
        # First set to custom mode
        with open(f"{DEVICE}/matrix_effect_custom", "w") as f:
            f.write("1")
        
        # Reset all positions to black
        for row in range(6):
            for col in range(22):
                frame_data = bytes([row, col, col, 0, 0, 0])
                with open(f"{DEVICE}/matrix_custom_frame", "wb") as f:
                    f.write(frame_data)
        
        # Then set to none effect
        with open(f"{DEVICE}/matrix_effect_none", "w") as f:
            f.write("1")
    except:
        pass

def map_keyboard():
    """Scan entire keyboard and build position map"""
    print("Scanning keyboard matrix... Press Enter for each key that lights up, 'x' if nothing")
    
    # QWERTY layout assumptions for guidance (adjusted for ESC at 0,1)
    layout_guess = {
        # Row 0: Function keys
        (0, 1): "ESC", (0, 2): "F1", (0, 3): "F2", (0, 4): "F3", (0, 5): "F4",
        (0, 6): "F5", (0, 7): "F6", (0, 8): "F7", (0, 9): "F8", (0, 10): "F9",
        (0, 11): "F10", (0, 12): "F11", (0, 13): "F12", (0, 14): "DEL", (0, 15): "POWER",
        
        # Row 1: Number row
        (1, 1): "`", (1, 2): "1", (1, 3): "2", (1, 4): "3", (1, 5): "4",
        (1, 6): "5", (1, 7): "6", (1, 8): "7", (1, 9): "8", (1, 10): "9",
        (1, 11): "0", (1, 12): "-", (1, 13): "=", (1, 15): "BACKSPACE",
        
        # Row 2: QWERTY row
        (2, 1): "TAB", (2, 2): "Q", (2, 3): "W", (2, 4): "E", (2, 5): "R",
        (2, 6): "T", (2, 7): "Y", (2, 8): "U", (2, 9): "I", (2, 10): "O",
        (2, 11): "P", (2, 12): "[", (2, 13): "]", (2, 14): "ENTER",
        
        # Row 3: ASDF row  
        (3, 1): "CAPS", (3, 2): "A", (3, 3): "S", (3, 4): "D", (3, 5): "F",
        (3, 6): "G", (3, 7): "H", (3, 8): "J", (3, 9): "K", (3, 10): "L",
        (3, 11): ";", (3, 12): "'", (3, 13): "#",
        
        # Row 4: ZXCV row
        (4, 1): "SHIFT", (4, 2): "\\", (4, 3): "Z", (4, 4): "X", (4, 5): "C", (4, 6): "V",
        (4, 7): "B", (4, 8): "N", (4, 9): "M", (4, 10): ",", (4, 11): ".",
        (4, 12): "/", (4, 15): "RSHIFT",
        
        # Row 5: Space row
        (5, 1): "CTRL", (5, 2): "FN", (5, 3): "WIN", (5, 5): "ALT",
        (5, 9): "RALT", (5, 11): "RCTRL", (5, 12): "LEFT", (5, 13): "UP", 
        (5, 14): "RIGHT", (5, 15): "DOWN"
    }
    
    key_map = {}
    clear_keyboard()
    time.sleep(1)
    
    for row in range(6):
        for col in range(22):
            set_key_color(row, col, 255, 255, 255)  # White
            
            guess = layout_guess.get((row, col), "?")
            key = input(f"Row {row}, Col {col} (guess: {guess}): ").strip()
            
            if key and key != 'x':
                key_map[(row, col)] = key.upper()
            
            set_key_color(row, col, 0, 0, 0)  # Just turn off this key
            
            if key == 'quit':
                break
        if key == 'quit':
            break
    
    return key_map

def interactive_mode(key_map):
    """Let user set colors on specific keys"""
    while True:
        print("\nAvailable keys:", ', '.join(key_map.values()))
        key = input("Enter key to color (or 'quit'): ").strip().upper()
        
        if key == 'QUIT':
            break
            
        # Find position of key
        pos = None
        for (row, col), mapped_key in key_map.items():
            if mapped_key == key:
                pos = (row, col)
                break
        
        if not pos:
            print(f"Key {key} not found")
            continue
            
        try:
            r = int(input("Red (0-255): "))
            g = int(input("Green (0-255): "))
            b = int(input("Blue (0-255): "))
            
            set_key_color(pos[0], pos[1], r, g, b)
            print(f"Set {key} to RGB({r},{g},{b})")
        except ValueError:
            print("Invalid color values")

def main():
    if len(sys.argv) > 1 and sys.argv[1] == 'map':
        key_map = map_keyboard()
        print("\nKeyboard map:", key_map)
        
        # Save map to file
        with open('keyboard_map.txt', 'w') as f:
            for (row, col), key in key_map.items():
                f.write(f"{row},{col}={key}\n")
        print("Map saved to keyboard_map.txt")
    
    elif os.path.exists('keyboard_map.txt'):
        # Load existing map
        key_map = {}
        with open('keyboard_map.txt', 'r') as f:
            for line in f:
                if '=' in line:
                    pos_str, key = line.strip().split('=')
                    row, col = map(int, pos_str.split(','))
                    key_map[(row, col)] = key
        
        interactive_mode(key_map)
    
    else:
        print("No keyboard map found. Run with 'map' argument first:")
        print("python3 keyboard-mapper.py map")

if __name__ == "__main__":
    main()