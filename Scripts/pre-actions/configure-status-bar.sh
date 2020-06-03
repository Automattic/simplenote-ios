#!/bin/bash

IPHONE_TIME=$(ruby -e "require 'time';puts Time.new(2007, 1, 9, 9, 42, 0).iso8601")

xcrun simctl boot "${TARGET_DEVICE_IDENTIFIER}"

xcrun simctl status_bar "${TARGET_DEVICE_IDENTIFIER}" override \
    --time $IPHONE_TIME \
    --dataNetwork wifi \
    --wifiMode active \
    --wifiBars 3 \
    --cellularMode active \
    --batteryState charged \
    --batteryLevel 100

