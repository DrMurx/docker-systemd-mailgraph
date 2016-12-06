# docker-systemd-mailgraph

A container running the mailgraph analyzer script, suitable for systemd-based environment such as CoreOS.

It runs in a container with the host's systemd journal directory being mounted and pipes the journal directly into mailgraph. Optional `jq` filters can be applied to filter for the proper journal entries. 

**Note that this image is just a quick and dirty hack. Not for real use.**


## Credits

Copyright (c) 2016 Jan Kunzmann <jan-github@phobia.de>, see [LICENSE.md](LICENSE.md).
