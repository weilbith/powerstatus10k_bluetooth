#!/bin/bash
#
# PowerStatus10k segment.
# This segment displays the bluetooth status.
# Differ the icon depending on controller power and if a device is connected.
# If connected to at least one device, it shows the alias of the first listed
# device. If more than one device is connected, a count of additional devices is
# displayed.

# Implement the interface function to get the current state.
#
function getState_bluetooth() {
  # Check if a Bluetooth controller is activated.
  any_controller_powered=false

  while IFS=$'\n' read -r controller; do
    address=$(sed 's/Controller\ \([A-Z0-9:]*\)\ .*/\1/' <<<"$controller")
    info=$(bluetoothctl show "$address")

    if [[ "$info" == *"Powered: yes"* ]]; then
      any_controller_powered=true
      break
    fi
  done <<<"$(bluetoothctl list)"

  # Get a list of connected devices.
  device_name_list=()

  while IFS=$'\n' read -r device; do
    address=$(sed 's/Device\ \([A-Z0-9:]*\)\ \(.*\)/\1/' <<<"$device")
    name=$(sed 's/Device\ \([A-Z0-9:]*\)\ \(.*\)/\2/' <<<"$device")
    info=$(bluetoothctl info "$address")

    if [[ "$info" == *"Connected: yes"* ]]; then
      device_name_list+=("$name")
    fi
  done <<<"$(bluetoothctl paired-devices)"

  device_count="${#device_name_list[@]}"

  # Decide on a status icon.
  if [[ $any_controller_powered == true ]]; then
    if [[ $device_count -gt 0 ]]; then
      STATE="$BLUETOOTH_ICON_CONNECTED"
    else
      STATE="$BLUETOOTH_ICON_ON"
    fi
  else
    STATE="$BLUETOOTH_ICON_OFF"
  fi

  # Add note for multiple connected devices.
  [[ $device_count -gt 1 ]] && STATE+=" (+$((device_count - 1)))"
  [[ $device_count -gt 0 ]] && STATE+=" $(abbreviate "${device_name_list[0]}" "bluetooth")"
}
