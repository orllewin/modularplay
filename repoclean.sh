#!/bin/bash

git checkout --orphan tmp
git add -A
git commit -m '...'
git branch -D main
git branch -m main
git push -f origin main