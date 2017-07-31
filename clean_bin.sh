#!/bin/bash
find . \( -name *.bin -o -name *.swift.test -o -name *.html.test \) -exec rm -rf {} +
