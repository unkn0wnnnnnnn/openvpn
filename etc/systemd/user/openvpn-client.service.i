[Unit]
After=syslog.target network-online.target
Wants=network-online.target

[Service]
Type=notify
PrivateTmp=true
WorkingDirectory=/etc/openvpn/client
ExecStart=openvpn --suppress-timestamps --nobind --config /etc/openvpn/client/config.ovpn
CapabilityBoundingSet=NONE
LimitNPROC=NONE
DeviceAllow=/dev/null r
DeviceAllow=/dev/net/tun rw
ProtectSystem=true
ProtectHome=true
KillMode=process

[Install]
WantedBy=multi-user.target
