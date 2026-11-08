# Documentation of commands to do when dealing with Talos

## Patch machine config (including enabling Kernel modules)
```
talosctl patch mc --patch <patch-file> -n <NODE-IP> -e <ENDPOINT-ID>
```

## Upgrade the Talos Linux image

Grab the extension schematic ID via 
```
curl -X POST --data-binary @<extensions-file> https://factory.talos.dev/schematics
```

Once the schematic ID is determine upgrade the Talos image of the node via
```
talosctl upgrade --image factory.talos.dev/metal-installer/<schematic-ID>:v<VERSION> -n <NODE-IP> -e <ENDPOINT-ID>
```

You can actually grab the schematic ID and `--image` arguments from the [Talos Image Factory](https://factory.talos.dev/) after walkthrough their UI.