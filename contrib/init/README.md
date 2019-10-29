###How to install
1. copy the systemd service file in /etc/systemd/system as buzzcoind.service
2. Start the service and enable at start up.
	```
	sudo systemctl start buzzcoind.service
	sudo systemctl enable buzzcoind.service
	```
3. Check if it's running
	`sudo systemctl status buzzcoind.service`
4. To stop and disable it any time:
	```
	sudo systemctl stop buzzcoind.service
	sudo systemctl disable buzzcoind.service
	```	
	

`systemctl list-unit-files | grep enabled`
