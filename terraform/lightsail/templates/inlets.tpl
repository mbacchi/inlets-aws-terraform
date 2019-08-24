#!/usr/bin/env bash

curl -sLS https://get.inlets.dev | sudo sh

# Lightsail doesn't let you use unique high ports apparently
# so we'll use port 80 here
inlets server --port=80 --token=${token}
