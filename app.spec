# -*- mode: python ; coding: utf-8 -*-

block_cipher = None

a = Analysis(
    ['connection_handler.py'],  # Main script path
    pathex=[],
    binaries=[],
    datas=[
        ('epoch50.tflite', '.'),  # Include the TFLite model
        ('interpreter.py', '.'),  # Include the custom interpreter module
    ],
    hiddenimports=[
        'flask',
        'flask_cors',
        'PIL',
        'PIL._imagingtk',
        'PIL._tkinter_finder',
        'cv2',
        'numpy',
        'tensorflow',
        'tensorflow.lite.python.interpreter',
    ],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)

pyz = PYZ(
    a.pure, 
    a.zipped_data,
    cipher=block_cipher
)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.zipfiles,
    a.datas,
    [],
    name='VendiServer',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=True,  # Keep console window open to see server logs
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    icon='Flask/vendi_icon.ico',  # Add an icon file if you have one, otherwise remove this line
) 