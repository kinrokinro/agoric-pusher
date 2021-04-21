#!/bin/bash
cat << 'EOT' > $HOME/agoric_pusher.sh
#!/bin/bash
while true 
do
	function sendPush {
	curl -X POST -H "Content-Type: application/json" \
		-d '{"message": "Your node stoped responding!", "token": "YOUR_APP_KEY", "user": "YOUR_USER_KEY"}' \
		https://api.pushover.net/1/messages.json
	}
	(: </dev/tcp/localhost/26656) &>/dev/null && echo "Agoric works fine..." || (echo "Agoric stopped work, send push..." && sendPush && sleep 600)
	sleep 60
done
EOT
chmod +x $HOME/agoric_pusher.sh
sudo tee <<EOF >/dev/null /etc/systemd/system/agoric_pusher.service
[Unit]
Description=Agoric node monitor
After=network-online.target
[Service]
User=$USER
ExecStart=/bin/bash $HOME/agoric_pusher.sh
Restart=on-failure
RestartSec=3
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload && sudo systemctl enable agoric_pusher && sudo service agoric_pusher restart && sudo service agoric_pusher status
