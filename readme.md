# PugCityHelper is the Mumble Bot tailored for nut.city
Scripts written in Lua for [piepan](https://github.com/layeh/piepan) on the [Gumble](https://godoc.org/layeh.com/gumble/gumble) implementation of Mumble.

## Steps for installing and running:
1. Download the latest piepan [release](https://github.com/layeh/piepan/releases/tag/v0.9.0) or build the latest version yourself. Place the folder somewhere you can easily access.
2. Place the .lua file somewhere in the folder (ideally in a subfolder) - If you're going to contribute to the repo, the easiest thing to do will be to clone the repo into a folder inside the piepan folder.
3. cd to the piepan folder and use this cmd: `piepan -server="ip:port" -username="desired-name" -certificate="path/to/cert.pem" -key="path/to/key.pem"  path/to/script.lua` with the relevent info replacing the placeholders. Replace the *-certificate* and *-key* flags with *-insecure* if you don't want to use a cert (more info on the piepan github).
3.5 If you need a certificate, see [here](https://github.com/layeh/piepan/issues/14#issuecomment-117834866) Admins running the nut.city bot can get the certs from Zidgel.

Note* Murmur servers without a certificate signed by a CA will be unable to take advantage of bot registration, limiting the functionality of potential administrative actions 
