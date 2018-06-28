#!/bin/bash
solc ./contracts/BrainFuck.sol 2>&1 | grep Error
set -e
solc --optimize --optimize-runs 200 --asm ./contracts/BrainFuck.sol > ./contracts/BrainFuck.asm 2> /dev/null
yarn test test/BrainFuck.js
