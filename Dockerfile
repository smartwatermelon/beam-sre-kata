# ./Dockerfile

FROM beamdental/sre-kata-app

# Install jq for JSON parsing
RUN apt-get update && \
    apt-get install -y jq curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy entrypoint script
COPY app_scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set entrypoint script as entrypoint
ENTRYPOINT ["/entrypoint.sh"]