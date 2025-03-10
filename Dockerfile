ARG FIXPOINT_BUILDER="ghcr.io/kidq330/ghcup_dockerfile:latest"

# mise is written in rust so the image includes rustup by default
# however the only requirement is for BASE_DEBIAN to be a debian based container with cargo available
ARG BASE_DEBIAN="ghcr.io/kidq330/mise_dockerfile:latest"

FROM $FIXPOINT_BUILDER as fixpoint-builder
WORKDIR /

RUN \
  ghcup install stack \
  && apt-get -qq update && apt-get install -qqy --no-install-recommends z3 \
  && /bin/rm -rf /var/lib/apt/lists/* \
  && git clone https://github.com/ucsd-progsys/liquid-fixpoint.git && cd liquid-fixpoint && stack install

FROM $BASE_DEBIAN
COPY --from=fixpoint-builder /liquid-fixpoint/.stack-work/install/*/*/*/bin/fixpoint /usr/bin/fixpoint

RUN apt-get -qq update && apt-get install -qqy --no-install-recommends z3 \
  && /bin/rm -rf /var/lib/apt/lists/* \
  && git clone https://github.com/flux-rs/flux && cd flux && cargo xtask install