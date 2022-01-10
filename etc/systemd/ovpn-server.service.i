[Unit]
After=syslog.target network-online.target
Wants=network-online.target

[Service]
Type=notify
PrivateTmp=true
WorkingDirectory=/etc/openvpn-server
ExecStart=openvpn --status /etc/openvpn-server/status.log --status-version 2 --suppress-timestamps --config /etc/openvpn-server/server.conf
CapabilityBoundingSet=NONE
DeviceAllow=/dev/null r
DeviceAllow=/dev/net/tun rw
ProtectSystem=true
ProtectHome=true
KillMode=process
RestartSec=0s
Restart=on-failure

[Install]
WantedBy=multi-user.target
