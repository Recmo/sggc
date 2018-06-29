#!/bin/bash
solc ./contracts/Unique.sol 2>&1 | grep Error
set -e
solc --optimize --optimize-runs 200 --asm ./contracts/Unique.sol > ./contracts/Unique.asm 2> /dev/null
yarn test test/Unique.js
