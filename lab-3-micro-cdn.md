---
layout: page
title: "Lab 3: Build a Micro CDN"
group: "Lab 3"

---

* toc
{:toc}

## Overview

The goal of this project is to build a micro CDN "service" using Google Cloud VMs.
This would involve creating VMs, setting up a DNS server, configuring a delegated zone, updating configuration so it gives different results for requests from different clients, and setting up a simple HTTP server to serve actual content.

## Tasks

### 1. Create second HTTP instance

- Create second instance of HTTP server ("http-2") following [lab 2](lab-2-dnssec-https.html) instruction, but use `europe-west2-c` zone.

  Make sure you have selected "Allow HTTP traffic" and "Allow HTTPS traffic".  This will automatically add proper firewall tags.

### 2. Configuring HTTP Instances

Follow instructions in the [lab 2](lab-2-dnssec-https.html) to configure "http-2" instance in a similar way, just upload a different cat picture.  A cuter one.

### 3. Re-configuring "dns-server-1"

As of right now, we have a functioning authoritative DNS server.
However, for CDN service, we need a little bit more.
We need our DNS server to give different A records for `www` domain, depending on who is asking.
While in reality it is done with custom implementations of DNS servers, for micro CDN we could re-use features of Bind.
In particular, Bind supports so called "views" that can return different zone information depending on the requester.

Ultimately, what you need to configure should look like this (make sure you use zone name that have been assigned to you by the instructor):

    acl "fiu" {
      131.94.0.0/16;  // must be within FIU (estimated)
    };
    
    view "fiu-view" {
      match-clients { fiu; };
    
      zone "delegated.domain.name" {
        type master;
        file "/var/cache/bind/delegated.domain.name-version1";
      };
    };
    
    view "default" {
      zone "delegated.domain.name" {
        type master;
        file "/var/cache/delegated.domain.name-version2";
      };
    };

Note that there is an `acl` block that defines one filter (feel free to pick your name for it), which is then used inside `view` named "fiu-view" (again, feel free to pick your name) as part of `match-clients` block.
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

If you are on campus (or when connected via VPN), it should give you IP address of `http-2`, otherwise IP address of `http-1`.

You can do the same without dig, by just pointing your web browser to http://www.delegated.domain.name and any unique file you have uploaded to each of the instances, e.g., http://www.delegated.domain.name/instance.txt

## Conclusion / Submission

Submit your report to Canvas quiz, answering the posted question.
