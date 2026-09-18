#!/usr/bin/env bash
set -euo pipefail

case "${SCENARIO:-v0}" in
  v0)
    launch_file="intercept.launch.py"
    ;;
  v1)
    launch_file="v1_intercept.launch.py"
    ;;
  v2)
    launch_file="v2_intercept.launch.py"
    ;;
  *)
    echo "Unsupported SCENARIO '${SCENARIO}'. Expected v0, v1, or v2." >&2
    exit 2
    ;;
esac

launch_arguments=(
  "gz_args:=${GZ_ARGS:--r -s}"
  "rviz:=${RVIZ:-false}"
)

for variable in ROBOT_X ROBOT_Y ROBOT_YAW TARGET_X TARGET_Y TARGET_YAW; do
  value="${!variable:-}"
  if [[ -n "${value}" ]]; then
    launch_arguments+=("${variable,,}:=${value}")
  fi
done

exec ros2 launch robot_sim "${launch_file}" "${launch_arguments[@]}"
