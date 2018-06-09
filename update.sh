#!/bin/sh
solc --optimize --optimize-runs 200 ./contracts/Test.sol --gas --asm > ./Test.asm
solc --optimize --optimize-runs 200 ./contracts/BrainFuck.sol --gas --asm > ./BrainFuck.asm
yarn test test/BrainFuck.js
