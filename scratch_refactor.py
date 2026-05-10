import os

mapping = {
    'Color(0xFFC0321A)': 'AppTheme.red',
    'Color(0xFF8B1A0A)': 'AppTheme.redDark',
    'Color(0xFFF91605)': 'AppTheme.redLight',
    'Color(0xFFF5A524)': 'AppTheme.orange',
    'Color(0xFFF5A623)': 'AppTheme.orange', 
    'Color(0xFFE8920A)': 'AppTheme.orangeDark',
    'Color(0xFFF7F0E6)': 'AppTheme.cream',
    'Color(0xFFF7F2EC)': 'AppTheme.cream', 
    'Color(0xFF1C1C1C)': 'AppTheme.textBlack',
    'Color(0xFF888888)': 'AppTheme.textGray',
    'Color(0xFF555555)': 'AppTheme.textMid',
    'Color(0xFF2BB84A)': 'AppTheme.success',
    'Color(0xFFCC2A2A)': 'AppTheme.error',
    'Color(0xFFD63010)': 'AppTheme.red', 
}

def process_file(filepath):
    if "app_theme.dart" in filepath.replace("\\", "/"):
        return
        
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
        
    replaced_any = False
    
    for hex_color, theme_prop in mapping.items():
        if hex_color in content:
            content = content.replace(hex_color, theme_prop)
            replaced_any = True
            
    if replaced_any:
        if 'theme/app_theme.dart' not in content:
            depth = filepath.replace('\\', '/').split('lib/')[-1].count('/')
            import_str = "import '" + ("../" * depth) + "theme/app_theme.dart';"
            
            lines = content.split('\n')
            last_import = -1
            for i, line in enumerate(lines):
                if line.startswith('import '):
                    last_import = i
            
            if last_import != -1:
                lines.insert(last_import + 1, import_str)
            else:
                lines.insert(0, import_str)
                
            content = '\n'.join(lines)
            
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Refactored {filepath}")

def main():
    root_dir = r"d:\kelompok2\dapur_kuliner_pakndut\lib"
    for subdir, dirs, files in os.walk(root_dir):
        for file in files:
            if file.endswith(".dart"):
                process_file(os.path.join(subdir, file))

if __name__ == "__main__":
    main()
