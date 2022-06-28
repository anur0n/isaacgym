FROM nvcr.io/nvidia/pytorch:21.09-py3
ENV DEBIAN_FRONTEND=noninteractive 

# dependencies for gym
#
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
 libxcursor-dev \
 libxrandr-dev \
 libxinerama-dev \
 libxi-dev \
 mesa-common-dev \
 zip \
 unzip \
 make \
 gcc-8 \
 g++-8 \
 vulkan-utils \
 mesa-vulkan-drivers \
 pigz \
 git \
 libegl1 \
 git-lfs \
 xauth \
 x11-apps \
 sudo
 
RUN mkdir /var/run/sshd \
RUN mkdir /home/anur0n/.ssh \
RUN chmod 700 /home/anur0n/.ssh \
RUN ssh-keygen -A \
RUN sed -i "s/^.*PasswordAuthentication.*$/PasswordAuthentication no/" /etc/ssh/sshd_config \
RUN sed -i "s/^.*X11Forwarding.*$/X11Forwarding yes/" /etc/ssh/sshd_config \
RUN sed -i "s/^.*X11UseLocalhost.*$/X11UseLocalhost no/" /etc/ssh/sshd_config \
RUN grep "^X11UseLocalhost" /etc/ssh/sshd_config || echo "X11UseLocalhost no" >> /etc/ssh/sshd_config

# Force gcc 8 to avoid CUDA 10 build issues on newer base OS
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 8
RUN update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-8 8

# WAR for eglReleaseThread shutdown crash in libEGL_mesa.so.0 (ensure it's never detected/loaded)
# Can't remove package libegl-mesa0 directly (because of libegl1 which we need)
RUN rm /usr/lib/x86_64-linux-gnu/libEGL_mesa.so.0 /usr/lib/x86_64-linux-gnu/libEGL_mesa.so.0.0.0 /usr/share/glvnd/egl_vendor.d/50_mesa.json

COPY docker/nvidia_icd.json /usr/share/vulkan/icd.d/nvidia_icd.json
COPY docker/10_nvidia.json /usr/share/glvnd/egl_vendor.d/10_nvidia.json

WORKDIR /opt/isaacgym

RUN useradd --create-home anur0n && echo "anur0n:anur0n" | chpasswd
RUN adduser anur0n sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER anur0n

CMD ["/usr/bin/xeyes"]

#COPY $(echo $HOME)/.Xauthority /home/anur0n/.Xauthority

#COPY docker/init_display.sh /opt/program
#CMD ["/bin/bash","/opt/program/init-display.sh"]

# copy gym repo to docker
COPY --chown=anur0n . .

# install gym modules
ENV PATH="/home/anur0n/.local/bin:$PATH"
RUN cd python && pip install -q -e .
RUN cd rsl_rl && pip install -q -e .
RUN cd legged_gym && pip install -q -e .

ENV NVIDIA_VISIBLE_DEVICES=all NVIDIA_DRIVER_CAPABILITIES=all
