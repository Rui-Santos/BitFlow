Production Setup
=================

Description
------------
It's a Single Small Instance running 32 Bit Ubuntu 10.04 LTS(Long term support)


This is the address the CNAME should point instead of the physical ip address.

Amazon Ec2 Setup
----------------

It can be managed from [Amazon Ec2](https://console.aws.amazon.com/ec2/home)
It is located in the EU-Ireland Zone.
The public key for the machine is in script/bitflow_prod.pem
Use script/go2-production.sh to connect to the production server.

[Cloudwatch](https://console.aws.amazon.com/cloudwatch/home?region=eu-west-1) - It is a paid amazon servce and i have turned it on. It gives us information of machine loads and gives us the ability to create alarms for specific conditions.
 [Elastic IP address](https://console.aws.amazon.com/ec2/home?region=eu-west-1&#s=Addresses). (Elastic ip's are free as long as they are associated with an instance, and start to cost if they are not.) We have assigned a single Elastic IP so that we do not hve to change cnames when the machine is upgraded or terminated.

[EBS](https://console.aws.amazon.com/ec2/home?region=eu-west-1#s=Volumes). It is persistent data storage blocks. We use it to store both the mysql database as well as bitcoin wallet.dat. This needs to snapshotted. It is currently 8G and i am worried that i may not suffice.
[Security Groups](https://console.aws.amazon.com/ec2/home?region=eu-west-1#s=SecurityGroups). This lets us control the access into the machine. As can be seen We allow only the follwoing ports access. This lets us make it secure.
22 (SSH)
80 (HTTP)
443 (HTTPS)

[Snapshots](https://console.aws.amazon.com/ec2/home?region=eu-west-1#s=Snapshots). This lets us back up EBS volumes. I have one setup right aftr doing the setup.



Paths
-----
1) App - /apps/BitFlow/current
2) Shared Stuff  - /apps/Bitflow/shared
3) Bitcoind - /mnt/bitcoind
4) mysql data files - /mnt/mysql
5) Certificate Pubkey - /etc/ssl/certs/www_bitflow_org.pem
6) Certificate Private key - /etc/ssl/private/www_bitflow_org.key  (Keep it very very secret)
7) Nginx Conf - /etc/nginx/nginx.conf
8) Mysql Conf - /etc/mysql/my.conf

Stack
-----
Nginx - Stock Nginx installed via apt-get
        Configuration files in the Source control

Mysql - Stock mysql client + server 
        Configuration file in source control.
		Writes to /mnt which is an ebs volume. It can be and should be snapshotted frequently.




