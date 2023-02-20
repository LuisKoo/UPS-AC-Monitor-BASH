#Introduction
To prevent files from being damaged or lost due to unexpected power loss, a UPS needs to be connected in front of the Linux BOX. The bash script here is to automatically shut down the Linux BOX in case of AC power failure. The script executes every 2 minutes. No need to pay for UPS management features.
This script monitors existing IP-enabled external devices such as routers or managed switches or wireless APs (AC power loss has no effect on these devices, they will come back to work when powered on). Make sure that no external devices are connected to the UPS, that is, external devices will automatically shut down after an AC power failure. Check whether the external AC power is on by pinging the IP of the device. If the IP of the device cannot be ping-ed, set the Linux BOX to shut down after 5 minutes. The script continues monitoring for 5 minutes. If the IP can be ping-ed within 5 minutes, the shutdown queue will be canceled and normal operation will resume.
The time parameters such as 2 minutes and 5 minutes here can be adjusted according to your own situation.
To automatically start Linux after AC power is restored, set the AC auto-on option in the device BIOS. For details, please refer to the motherboard BIOS setting instructions.

#Usage
1. Add the script to the self-starting, and the script itself will execute in an infinite loop. Set LOOP=1 and LOOP_GAP=120
2. Or set a crontab job and let the script execute every 2 minutes. set LOOP=0
3. Currently check the AC power supply through ping the gateway IP obtained by /sbin/route, which can be modified according to the actual situation
