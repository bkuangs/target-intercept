# syntax=docker/dockerfile:1.7

FROM osrf/ros:jazzy-desktop-full

ARG DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        python3-colcon-common-extensions \
        python3-rosdep \
    && if [ ! -f /etc/ros/rosdep/sources.list.d/20-default.list ]; then rosdep init; fi \
    && rosdep update \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
COPY . src/target-intercept

RUN apt-get update \
    && rosdep install \
        --from-paths src \
        --ignore-src \
        --rosdistro jazzy \
        --as-root apt:false \
        -r \
        -y \
    && rm -rf /var/lib/apt/lists/* \
    && source /opt/ros/jazzy/setup.bash \
    && colcon build \
        --merge-install \
        --cmake-args \
            -DCMAKE_BUILD_TYPE=Release \
            -DBUILD_TESTING=OFF

COPY docker/entrypoint.sh /usr/local/bin/target-intercept-entrypoint
COPY docker/bringup.sh /usr/local/bin/target-intercept-bringup

RUN chmod 0755 \
    /usr/local/bin/target-intercept-entrypoint \
    /usr/local/bin/target-intercept-bringup

ENV GZ_PARTITION=target_intercept \
    ROS_DISTRO=jazzy

ENTRYPOINT ["/usr/local/bin/target-intercept-entrypoint"]
CMD ["/usr/local/bin/target-intercept-bringup"]
