#!/usr/bin/env bash

counter=0

while :; do
  counter=$((counter + 1))
  tput cup 0 0 # Send cursor to top-left
  lolcat "$1" --seed=$counter --force --spread=100 --truecolor
  sleep 0.05
done
