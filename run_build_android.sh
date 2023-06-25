#!/bin/bash
set -e

echo 'Creating android bundle...'
fvm flutter build appbundle --no-tree-shake-icons