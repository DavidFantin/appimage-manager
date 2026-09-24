#!/bin/bash

# Path to the executable under test
APPIMAGE_INSTALL_BIN="./appimage-install"

# Setup isolated test environment in /tmp
TEST_BASE_DIR="/tmp/appimage-install-tests-$$"
export HOME="$TEST_BASE_DIR/home"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"

# Directory references inside isolated environment
APPDIR="$HOME/.local/appimages"
BACKUPDIR="$APPDIR/backups"
BINDIR="$HOME/.local/bin"
CONFIGDIR="$HOME/.config/appimage-install"
CONFIGFILE="$CONFIGDIR/config"
UNTRIMMED_STATEFILE="$CONFIGDIR/.untrimmed_state"

# Helper: Create dummy executable AppImage file
create_dummy_appimage() {
    local PATH_TO_CREATE="$1"
    mkdir -p "$(dirname "$PATH_TO_CREATE")"
    cat > "$PATH_TO_CREATE" << 'EOF'
#!/bin/bash
echo "Dummy AppImage executed successfully"
EOF
    chmod +x "$PATH_TO_CREATE"
}

# shunit2 setup function run before every test
setUp() {
    rm -rf "$TEST_BASE_DIR"
    mkdir -p "$HOME" "$APPDIR" "$BACKUPDIR" "$BINDIR" "$CONFIGDIR"
    cat > "$CONFIGFILE" << EOF
max_backups=1
EOF
}

# shunit2 teardown function run after every test
tearDown() {
    rm -rf "$TEST_BASE_DIR"
}

# ============================================================
# TESTS: INSTALLATION & UPGRADES
# ============================================================

test_fresh_install() {
    echo -e "\n--- RUNNING: test_fresh_install ---"
    create_dummy_appimage "/tmp/RockboxUtility-v1.5.1.AppImage"

    "$APPIMAGE_INSTALL_BIN" "/tmp/RockboxUtility-v1.5.1.AppImage" "rockbox"
    
    assertEquals "Exit code should be 0" 0 $?
    assertTrue "AppImage should exist in APPDIR" "[ -f '$APPDIR/RockboxUtility-v1.5.1.AppImage' ]"
    assertTrue "Symlink should exist in BINDIR" "[ -L '$BINDIR/rockbox' ]"
    assertEquals "Symlink target check" "$APPDIR/RockboxUtility-v1.5.1.AppImage" "$(readlink -f "$BINDIR/rockbox")"
}

test_upgrade_appimage() {
    echo -e "\n--- RUNNING: test_upgrade_appimage ---"
    create_dummy_appimage "/tmp/RockboxUtility-v1.5.1.AppImage"
    create_dummy_appimage "/tmp/RockboxUtility-v1.5.2.AppImage"

    "$APPIMAGE_INSTALL_BIN" "/tmp/RockboxUtility-v1.5.1.AppImage" "rockbox"
    
    # -u takes ONLY the new AppImage path
    echo "y" | "$APPIMAGE_INSTALL_BIN" -u "/tmp/RockboxUtility-v1.5.2.AppImage"

    assertTrue "New active version should exist" "[ -f '$APPDIR/RockboxUtility-v1.5.2.AppImage' ]"
    assertTrue "Old version should be backed up" "[ -f '$BACKUPDIR/RockboxUtility-v1.5.1.AppImage' ]"
    assertEquals "Symlink should point to 1.5.2" "$APPDIR/RockboxUtility-v1.5.2.AppImage" "$(readlink -f "$BINDIR/rockbox")"
}

# ============================================================
# TESTS: ROLLBACKS
# ============================================================

test_rollback_version() {
    echo -e "\n--- RUNNING: test_rollback_version ---"
    create_dummy_appimage "/tmp/RockboxUtility-v1.5.1.AppImage"
    create_dummy_appimage "/tmp/RockboxUtility-v1.5.2.AppImage"

    "$APPIMAGE_INSTALL_BIN" "/tmp/RockboxUtility-v1.5.1.AppImage" "rockbox"
    echo "y" | "$APPIMAGE_INSTALL_BIN" -u "/tmp/RockboxUtility-v1.5.2.AppImage"

    echo "y" | "$APPIMAGE_INSTALL_BIN" rockbox --rollback 1.5.1

    assertTrue "Active version should be 1.5.1" "[ -f '$APPDIR/RockboxUtility-v1.5.1.AppImage' ]"
    assertTrue "1.5.2 should be in backups" "[ -f '$BACKUPDIR/RockboxUtility-v1.5.2.AppImage' ]"
    assertEquals "Symlink should point to 1.5.1" "$APPDIR/RockboxUtility-v1.5.1.AppImage" "$(readlink -f "$BINDIR/rockbox")"
}

# ============================================================
# TESTS: RETENTION & PRUNING LOGIC
# ============================================================

test_automatic_pruning_respects_max_backups() {
    echo -e "\n--- RUNNING: test_automatic_pruning_respects_max_backups ---"
    cat > "$CONFIGFILE" << EOF
max_backups=1
EOF
    create_dummy_appimage "/tmp/RockboxUtility-v1.5.1.AppImage"
    create_dummy_appimage "/tmp/RockboxUtility-v1.5.2.AppImage"
    create_dummy_appimage "/tmp/RockboxUtility-v1.5.3.AppImage"

    "$APPIMAGE_INSTALL_BIN" "/tmp/RockboxUtility-v1.5.1.AppImage" "rockbox"
    touch -m -t 202601010000 "$APPDIR/RockboxUtility-v1.5.1.AppImage"

    echo "y" | "$APPIMAGE_INSTALL_BIN" -u "/tmp/RockboxUtility-v1.5.2.AppImage"
    touch -m -t 202601010001 "$BACKUPDIR/RockboxUtility-v1.5.1.AppImage"
    touch -m -t 202601010001 "$APPDIR/RockboxUtility-v1.5.2.AppImage"

    echo "y" | "$APPIMAGE_INSTALL_BIN" -u "/tmp/RockboxUtility-v1.5.3.AppImage"

    assertTrue "1.5.2 backup should exist" "[ -f '$BACKUPDIR/RockboxUtility-v1.5.2.AppImage' ]"
    assertFalse "1.5.1 backup should be pruned" "[ -f '$BACKUPDIR/RockboxUtility-v1.5.1.AppImage' ]"
}

test_declining_retention_reduction_creates_untrimmed_state() {
    echo -e "\n--- RUNNING: test_declining_retention_reduction_creates_untrimmed_state ---"
    cat > "$CONFIGFILE" << EOF
max_backups=3
EOF
    create_dummy_appimage "/tmp/RockboxUtility-v1.5.1.AppImage"
    create_dummy_appimage "/tmp/RockboxUtility-v1.5.2.AppImage"
    create_dummy_appimage "/tmp/RockboxUtility-v1.5.3.AppImage"
    create_dummy_appimage "/tmp/RockboxUtility-v1.5.4.AppImage"

    "$APPIMAGE_INSTALL_BIN" "/tmp/RockboxUtility-v1.5.1.AppImage" "rockbox"
    
    echo "y" | "$APPIMAGE_INSTALL_BIN" -u "/tmp/RockboxUtility-v1.5.2.AppImage"
    touch -m -t 202601010001 "$BACKUPDIR/RockboxUtility-v1.5.1.AppImage"

    echo "y" | "$APPIMAGE_INSTALL_BIN" -u "/tmp/RockboxUtility-v1.5.3.AppImage"
    touch -m -t 202601010002 "$BACKUPDIR/RockboxUtility-v1.5.2.AppImage"

    echo "y" | "$APPIMAGE_INSTALL_BIN" -u "/tmp/RockboxUtility-v1.5.4.AppImage"
    touch -m -t 202601010003 "$BACKUPDIR/RockboxUtility-v1.5.3.AppImage"

    # Reduce retention limit
    cat > "$CONFIGFILE" << EOF
max_backups=1
EOF

    # Decline trimming ('n')
    create_dummy_appimage "/tmp/RockboxUtility-v1.5.5.AppImage"
    echo "n" | "$APPIMAGE_INSTALL_BIN" -u "/tmp/RockboxUtility-v1.5.5.AppImage"

    assertTrue ".untrimmed_state file should exist" "[ -f '$UNTRIMMED_STATEFILE' ]"
    assertTrue "Old backups should NOT be pruned" "[ -f '$BACKUPDIR/RockboxUtility-v1.5.1.AppImage' ]"

    # Subsequent run: verify pruning remains skipped
    create_dummy_appimage "/tmp/RockboxUtility-v1.5.6.AppImage"
    echo "y" | "$APPIMAGE_INSTALL_BIN" -u "/tmp/RockboxUtility-v1.5.6.AppImage"
    assertTrue "Old backups should STILL persist on subsequent run" "[ -f '$BACKUPDIR/RockboxUtility-v1.5.1.AppImage' ]"
}

# Load shunit2 runner
if [ -f /usr/share/shunit2/shunit2 ]; then
    . /usr/share/shunit2/shunit2
elif [ -f /usr/bin/shunit2 ]; then
    . /usr/bin/shunit2
else
    echo "shUnit2 is required to run tests."
    exit 1
fi