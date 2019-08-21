#!/usr/bin/env bash

curl -sLS https://get.inlets.dev | sudo sh

inlets server --port=8090 --token=${token}
