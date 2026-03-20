#!/bin/bash
LOCATION="${1:-Melbourne}"
curl -s "https://wttr.in/${LOCATION}?format=3"
