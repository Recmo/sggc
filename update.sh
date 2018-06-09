#!/bin/sh
solc --optimize --optimize-runs 200 ./contracts/Test.sol --gas --asm > ./Test.asm
solc --optimize --optimize-runs 200 ./contracts/Unique.sol --gas --asm > ./Unique.asm
yarn test test/Unique.js
