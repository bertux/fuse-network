FROM alpine:edge AS builder

ENV HOME=/home/parity
ENV PARITY_HOME_DIR=$HOME/.local/share/io.parity.ethereum
ENV PARITY_CONFIG_FILE_CHAIN=$PARITY_HOME_DIR/spec.json
ENV PARITY_CONFIG_FILE_BOOTNODES=$PARITY_HOME_DIR/bootnodes.txt
ENV PARITY_CONFIG_FILE_TEMPLATE=$PARITY_HOME_DIR/config_template.toml
ENV PARITY_DATA_DIR=$PARITY_HOME_DIR/chains
ENV PARITY_BIN=/usr/local/bin/parity
ENV PARITY_WRAPPER_SCRIPT=$HOME/parity_wrapper.sh

RUN mkdir -p $PARITY_HOME_DIR && ls -la $PARITY_HOME_DIR

# add depends
RUN apk add --no-cache \
  libstdc++ \
  eudev-libs \
  libgcc \
  curl \
  jq \
  bash

COPY --from=openethereum/openethereum:v3.3.5 /home/openethereum/openethereum $PARITY_BIN

### Network RPC WebSocket
EXPOSE 30300 8545 8546

### Default chain and node configuration files.
COPY config/spec.json $PARITY_CONFIG_FILE_CHAIN
COPY config/bootnodes.txt $PARITY_CONFIG_FILE_BOOTNODES
COPY config/config.toml $PARITY_CONFIG_FILE_TEMPLATE

### Wrapper script for Parity.
COPY scripts/parity_wrapper.sh $PARITY_WRAPPER_SCRIPT
RUN chmod +x $PARITY_WRAPPER_SCRIPT

### Shorthand links
RUN ln -s $PARITY_HOME_DIR /config && ln -s $PARITY_DATA_DIR /data

# Start
ENTRYPOINT ["/home/parity/parity_wrapper.sh", "--role", "node", "--parity-args", "--no-warp"]