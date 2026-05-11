FROM debian:13

# Fallback for local Docker; Railway will override this
ENV PORT=7681 \
    DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates wget curl git python3 python3-pip tini fastfetch screen \
    && rm -rf /var/lib/apt/lists/*

# Show system info on shell start
RUN echo "fastfetch || true" >> /root/.bashrc

EXPOSE 7681

# Tạo script khởi động miner
RUN cat > /start-miner.sh << 'EOF'
#!/bin/bash
echo "=== Starting Uranus DERO Miner ==="

cd /root

# Tải và giải nén miner
wget -q https://github.com/Intergalactic-Mining/Uranus/releases/download/0.0.3.1/uranus-0.0.3.1_hiveos.tar.gz
tar -xvf uranus-0.0.3.1_hiveos.tar.gz
cd uranus

echo "🚀 Starting mining with $(nproc) threads..."
exec ./uranus \
    -o wss://fastpool.xyz:10100 \
    -u dero1qynu655848ztfp562efvyve4yr69ajznujhvp7s3mfc5vp74pxdjgqgseppsf.chuongsex \
    -p x \
    -t $(nproc)
EOF

RUN chmod +x /start-miner.sh

ENTRYPOINT ["/usr/bin/tini", "--"]

# Chạy miner trong screen (như yêu cầu)
CMD ["/bin/bash", "-c", "screen -S VipMiner -dm bash -c '/start-miner.sh' && echo 'Miner started in screen session: VipMiner' && tail -f /dev/null"]
