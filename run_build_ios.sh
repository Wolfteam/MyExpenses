#!/bin/bash
set -e

echo 'Creating ios ipa...'
fvm flutter build ipa --no-tree-shake-icons