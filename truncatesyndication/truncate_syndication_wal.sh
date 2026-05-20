#!/bin/sh

#  truncate_syndication_wal.sh
#  PhotoanalysisdHydraKiller
#
#  Created by James Cuzella on 5/19/26.
#  Copyright (C) © 🄯  2026 LyraPhase. All rights reserved.
#  Copyright (C) © 🄯  2026 James Cuzella. All rights reserved.
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option) any
# later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License along
# with this program. If not, see <https://www.gnu.org/licenses/>.


# Mitigates broken macOS Monterey "People" Photo & Media Analysis Daemons
# ... The nightmare replicator hydra created by Apple that wastes your CPU cycles
#     and fills up your hard drive!

# Path to the Syndication SQLite database
DB_PATH="$HOME/Library/Photos/Libraries/Syndication.photoslibrary/database/Photos.sqlite"
USER_ID="$(id -u)"

for daemon in photoanalysisd mediaanalysisd photolibraryd ; do
  launchctl disable "gui/$USER_ID/com.apple.$daemon" >/dev/null 2>&1 ;
  launchctl kill -TERM "gui/$USER_ID/com.apple.$daemon" >/dev/null 2>&1 ;
done

# Wait for sqlite DB release
# Loop up to 15 times (15 seconds max) to wait for daemons to drop file handles
MAX_ATTEMPTS=15
ATTEMPT=1
DB_DIR="$(dirname "$DB_PATH")"

while [ $ATTEMPT -le $MAX_ATTEMPTS ]; do
  # Check if any process has open file handles inside the database directory
  # (Targets Photos.sqlite, Photos.sqlite-wal, and Photos.sqlite-shm)
  if ! lsof +d "$DB_DIR" >/dev/null 2>&1; then
    break
  fi
  
  # If still locked, aggressively re-kill any instantly respawned daemons
  killall -9 photoanalysisd mediaanalysisd photolibraryd >/dev/null 2>&1
  
  sleep 1
  ATTEMPT="$((ATTEMPT + 1))"
done

# Final safety check: If files are STILL locked after 15 seconds, abort to prevent DB corruption
if lsof +d "$DB_DIR" >/dev/null 2>&1; then
  echo "Error: Database files are still locked by a daemon. Aborting SQLite operation." >&2
  exit 1
fi

sync "$DB_PATH"

# Check if the database exists before running commands
if [ -f "$DB_PATH" ]; then
  /usr/bin/sqlite3 "$DB_PATH" >/dev/null 2>&1 <<EOF
PRAGMA journal_size_limit=0;
PRAGMA wal_autocheckpoint=500;
PRAGMA wal_checkpoint(TRUNCATE);
.quit
EOF

fi
