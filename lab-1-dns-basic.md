---
layout: page
title: "Lab 1: Get DNS rolling"
group: "Lab 1"

---

* toc
{:toc}

## Overview

The goal of this project is to configure your own DNS zone and practice (=experience pain) with tools necessary to secure the zone (DNSSEC).
This involves creating a VM, setting up a DNS server, configuring a delegated zone, generating and configuring crypto keys, and communicating necessary security parameters to the parent zone (=to the instructor).

## Tasks

### 1. Create firewall rule

Go to `Google Cloud Console` -> `VPC Network` -> `Firewall Rules`.  If missing, create a rule `"allow-dns"` and assign it a tag `"allow-dns"` so it allows from any source IP address (0.0.0.0/0) to access UDP port 53 and TCP port 53.
Note that we went through this process in Lecture 4, recording of which is available in Canvas.

### 2. Create VM

- Create VM instance "dns-server-1" (you're free to pick your own name)

  Use general-purpose, E2 series, e2-micro with Ubuntu 20.04 LTS image, use `us-central1-c` zone.

  Make sure you have typed in `"allow-dns"` tag for the firewall.  When creating, expand `"Management, security, disks, networking, sole tenancy"` section, go to `"Networking"` tab, and type in `allow-dns` and press enter.
 
Note that if you want direct ssh/scp access to the created VM, you can add your public SSH key in `"Management, security, disks, networking, sole tenancy"` -> `"Security"` tab.

### 3. Configuring VMs

#### 3.1. "dns-server-1"

**Note public IP address of the VM and send it to the instructor. You will be given delegation of a DNS zone.**

SSH to the server and start configurations.

Update/upgrade packages and install `bind9` authoritative DNS server:

```
sudo apt update
sudo apt upgrade
sudo apt install sshguard bind9
```

And now you are ready for the fun part, configuring DNS server.

With the default settings, Bind configuration is located in `/etc/bind` folder.
Bind can work as caching resolver, authoritative resolver, or both.  In our lab, we will use only the authoritative part, so we will need to delete a few files and then create a few files.

Files to delete:

- db.0
- db.127
- db.255
- db.empty
- db.local
- zones.rfc1918
- named.conf.default-zones

Files to modify:

- `/etc/bind/named.conf`: remove the last line that is referencing `/etc/bind/named.conf.default-zones`

- `/etc/bind/named.conf.local`: This is **the** file where you can define zones for which your DNS server will be acting as authoritative DNS.

You can lookup the basic syntax for `named.conf` file online, but essentially it should contain blocks like:

```
zone "delegated.domain.name" {
  type master; // bind has also concept of "slave" that automatically sync's zone from master (not part of the lab)
  file "/etc/bind/full.path.to.the.zone.db";
};
```

NOTE that `full.path.to.the.zone` is just an example! and you need to use your own zone name (you will receive this from the instructor in this lab).  Same applies to `delegated.domain.name` below.

If we create a proper zone file (`/etc/bind/full.path.to.the.zone.db` in the example above, but the exact filename is your choice), this would be enough for the `delegated.domain.name` domain/zone to start functioning.

To finish DNS configuration, you would need to actually create zone file, e.g., `/etc/bind/full.path.to.the.zone.db`.

For this lab, the zone should just contain SOA, NS, A, and the requested TXT records. The next lab will expand the set of records.
For example, you can copy paste the following and then modify relevant parts:

```
$TTL	3600
$ORIGIN delegated.domain.name.

@	IN	SOA	delegated.domain.name. your.email.but.replace.at.with.dot. (
		     2021090300	; Serial
			   3600		; Refresh
			   3600		; Retry
			 604800		; Expire
			   3600 )	; Negative Cache TTL
;
@	IN	NS	ns1.delegated.domain.name.

ns1 IN  A   1.2.3.4   ; IP address of dns-server-1

lab1 IN TXT "This is lab1"
lab1 IN TXT "Or Sparta!"
```

As a requirement for the lab, your zone must contain **two** TXT records highlighted above:

- `lab1.<delegated.domain.name.>` TXT "This is lab1"
- `lab1.<delegated.domain.name.>` TXT "Or Sparta!"

After you are done, you can reload DNS server daemon so it picks up the changed you have made.
However, before you do that, it is always a good idea to check sanity of the configuration. You can do it with this command:
 
    sudo /usr/sbin/named-checkconf -z /etc/bind/named.conf
 
If everything is fine, reload DNS server daamon:

    sudo rndc reload 

### 4. Configure DNSSEC

To configure DNSSEC for the zone, just follow [these instructions](https://www.digitalocean.com/community/tutorials/how-to-setup-dnssec-on-an-authoritative-bind-dns-server-2).

.

.

.

Ok, I just wanted to highlight that doing by hand can be daunting and not really feasible in the long run.
Luckily, there are various tools that you can use to mostly automate the process.

However, we will defer this to another lab.  For lab-1, try to read the linked instructions and gather ideas about the process, and questions about the process.


### 5. Checks

To check if DNS properly returns what you are expecting, use dig command (or [web-based dig](https://www.digwebinterface.com/)) to see what IP address is returned.

    dig -t txt lab1.<delegated.domain.name>

If everything works, you should get two TXT records you have configured.

## Conclusion / Submission

In your submission include:

- Your name, ID, delegated domain name, and public IP addresses of the created VM instance

- Answer to the following questions:

    * After you do section 4 check, list records (exact or highlights) that would have been cached by the caching resolver.  You may need to perform recursive query by hand, as we did in lecture 3.

    * Imagine the case that after the same check root zone and all top level domain name servers become unaccessible (but second and all other servers still work).  Give 5 examples (diverse) of domain names that the caching resolver will still be able to get and give 2 examples of ones that will not.

    * If you run another query `dig -t txt lab1-ne.<delegated.domain.name>`, it should return no valid records.  If you run the same record again, will the caching resolver try to contact your authoritative name server or it has cached something.  If it has cached, what did it cache, for how long, and can you control this time (and if you can, how).

- Description of any problems, road blocks, what you have learned, what was interesting, not interesting, etc.

- Describe how DNSSEC is configured for the zone, including steps one need to perform. 
