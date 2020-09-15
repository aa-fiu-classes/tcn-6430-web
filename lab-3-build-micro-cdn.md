---
layout: page
title: "Lab 1: Build a Micro CDN Using Google Cloud"
group: "Lab 1"

---

* toc
{:toc}

## Overview

The goal of this project is to build a micro CDN "service" using Google Cloud VMs.
This would involve creating VMs, setting up a DNS server, configuring a delegated zone, updating configuration so it gives different results for requests from different clients, and setting up a simple HTTP server to serve actual content.

## Tasks

### 1. Create firewall rule

Go to Google Cloud Console -> VPC Network -> Firewall Rules.  If missing, create a rule "allow-dns" and assign it a tag "allow-dns" so it allows from any source IP address (0.0.0.0/0) to access UDP port 53 and TCP port 53.

### 2. Create VMs

You would need to create 3 VMs (you can leave default 10 GB disk in all cases):

- For authoritative DNS server, say "dns-server-1" (you're free to pick your own name)

  Create micro-instance with Ubuntu 18.04, use `us-central1-c` zone.

  Make sure you have typed in "allow-dns" tag for the firewall.  When creating, expand "Management, security, disks, networking, sole tenancy" section, go to "Networking" tab, and type in `allow-dns` and press enter.
 
- For HTTP server 1, say "http-1"

  Create micro-instance with Ubuntu 18.04, use `us-east1-b` zone.

  Make sure you have selected "Allow HTTP traffic" and "Allow HTTPS traffic".  This will automatically add proper firewall tags.

- For HTTP server 2, say "http-2"

  Create micro-instance with Ubuntu 18.04, use `europe-west2-c` zone.

  Make sure you have selected "Allow HTTP traffic" and "Allow HTTPS traffic".  This will automatically add proper firewall tags.

### 3. Configuring VMs

#### 3.1. "http-1" and "http-2"

Configuration of both VMs is similar.  You just need to install Apache HTTP server and upload some content to be served from this micro-CDN instance.

Before you start, note public IP addresses of both instances. You will need them during configuration of DNS server in the next step.

SSH to the server and start configurations

Update/upgrade packages and install `apache` authoritative DNS server:

```
sudo apt update
sudo apt upgrade
sudo apt install apache2
```

With default configuration, the installed Apache HTTP server will serve content from `/var/www/html` folder.
For your testing, you can upload there any information, such as pictures and videos of your (or your instructor) favorite cats.
For your work verification, you must create the following files:

- on "http-1":

`/var/www/html/instance.txt` with content `http-1` as the first line.
`/var/www/html/owner.txt` with your name as the content

- on "http-2":

`/var/www/html/instance.txt` with content `http-2` as the first line.
`/var/www/html/owner.txt` with your name as the content

To test before going to the next step, you can simply type in your web browser the public IP of the instance and path to the file, such as (use IP of your instance!)

    http://1.1.1.1/instance.txt

#### 3.2. "dns-server-1"

Note public IP address of the VM and send it to the instructor. You will be given delegation of a DNS zone.

SSH to the server and start configurations.

Update/upgrade packages and install `bind9` authoritative DNS server:

```
sudo apt update
sudo apt upgrade
sudo apt install bind9
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
- db.root
- zones.rfc1918
- named.conf.default-zones

Files to modify:

- `/etc/bind/named.conf`: remove the last line that is referencing `/etc/bind/named.conf.default-zones`

- `/etc/bind/named.conf.local`: This is **the** file where you can define zones for which your DNS server will be acting as authoritative DNS.

You can lookup the basic syntax for `named.conf` file online, but essentially it should contain blocks like:

```
zone "delegated.domain.name" {
  type "master"; // bind has also concept of "slave" that automatically sync's zone from master (not part of the lab)
  file "/etc/bind/full.path.to.the.zone.db";
};
```

If we create a proper zone file, this would be enough for the `delegated.domain.name` domain/zone to start functioning.
However, when we setting up DNS server for CDN service, this would not be enough, as we would want to return different results depending on who is asking the question.
While in reality it is done with custom implementations of DNS servers, for micro CDN we could re-use features of Bind.
In particular, Bind supports so called "views" that can return different zone information depending on the requester.

Ultimately, what you need to configure should look like this (make sure you use zone name that have been assigned to you by the instructor):

```
acl "us" {
  geoip country US;  // must be within US (estimated)
  ! 131.94.0.0/16;   // but cannot be on FIU network
};

view "us-outside-fiu" {
  match-clients { us; };

  zone "delegated.domain.name" {
    type master;
    file "/etc/bind/delegated.domain.name-version1";
  };
};

view "default" {
  zone "delegated.domain.name" {
    type master;
    file "/etc/bind/delegated.domain.name-version2";
  };
};
```

Note that there is an `acl` block that defines one filter (feel free to pick your name for it), which is then used inside `view` named "us-outside-fiu" (again, feel free to pick your name) as part of `match-clients` block.
There is also a "default" view that is being matched to anything that was not matched before.

Compared to the basic example I showed you before, you have acl and multiple (duplicate) zone definitions, each in separate views.

To finish DNS configuration, you would need to actually create zone file, e.g., files `/etc/bind/delegated.domain.name-version1` and `/etc/bind/delegated.domain.name-version2`.

Both of them should look the same, with exception of a "A" record for `www` subdomain of your delegated zone.
You can find tons of templates online, you use the following:

```
$TTL	3600
$ORIGIN delegated.domain.name.

@	IN	SOA	delegated.domain.name. your.email.but.replace.at.with.dot. (
		     2019100300	; Serial
			   3600		; Refresh
			   3600		; Retry
			 604800		; Expire
			   3600 )	; Negative Cache TTL
;
@	IN	NS	ns1.delegated.domain.name.

ns1 IN  A   1.2.3.4   ; IP address of dns-server-1

www	IN	A	5.6.7.8   ; IP address of http-1 or http2  ; each of zone files MUST contain exactly 1 resource record for `www` domain
```

After you are done, you can reload DNS server daemon so it picks up the changed you have made.
However, before you do that, it is always a good idea to check sanity of the configuration. You can do it with this command:
 
    sudo /usr/sbin/named-checkconf -z /etc/bind/named.conf
 
If everything is fine, reload DNS server daamon:

    sudo rndc reload 

### 4. Checks

To check if DNS properly returns what you are expecting, use dig command (or [web-based dig](https://www.digwebinterface.com/)) to see what IP address is returned.

    dig www.delegated.domain.name A

If you are on campus or outside US, it should give you IP address of `http-2`, otherwise IP address of `http-1`.

You can do the same without dig, by just pointing your web browser to http://www.delegated.domain.name and any unique file you have uploaded to each of the instances, e.g., http://www.delegated.domain.name/instance.txt

## Conclusion / Submission

In Gradescope, submit

- your name, ID, delegated domain name, and public IP addresses of all created VM instances

- description of any problems, road blocks, what you have learned, what was interesting, not interesting, etc.

