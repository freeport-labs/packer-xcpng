# packer-xcpng

## About
Packer script to build a qemu image of an XCP-NG Install. This isn't quite working yet and ultimately should be able to support a BMC Deployment.

## Goals

Create and image of XCP to deploy to bare-metal.

## Usage

#### Secrets file.
Create a secrets file called `secrets.pkrvars.hcl` in the repo root with your root password hash.

```
#secrets.pkrvars.hcl
root_pass_hash = "<value_of_rootpass_hash>"
```

#### Building

Build the image with:

##### BIOS Systems
```shell
[user@buildmachine ~]# packer build -var-file=secrets.pkrvars.hcl xcpng-8.2-bios.pkr.hcl
```

##### UEFI Systems
```shell
[user@buildmachine ~]# packer build -var-file=secrets.pkrvars.hcl xcpng-8.2-uefi.pkr.hcl
```

# Known Issues
The system will reboot after install and not shut down. Packer will only build the image if the VM cleanly shuts down. Currently this must be done manually. I tried to create a post-install script to shutdown the host but have not been able to get this to work yet. Alternative would be use a packer post-processor to trigger a clean VM shutdown.

# Todo

- Create image to match size of target disk, instead of expanding after install. QEMU Compression should help make this managable and we can expand during the imaging process.

- Support configuring networking on the host either via the answerfile.xml process or a first-boot mechanicsm.

- Thoughts: Many BMC Cloud providers support / require the use of LACP Bonds for connectivity. There is no garuntee (though high likelyhood) that the network will be configrued with `no lacp suspend-individual` which allows a single interface to function as long as no LACP PDU's are recieved within a certain time window. This is usually done to allow PXE installations to work on top-of-rack switches. Still, we should attempt to configure networking ahead of time in a case a where provider does not have this configured.

- Bonds should additionally support vlans. This is a bit tricky to do for the management NIC in XCP-NG out of the box. 

# What is currently not working.

When we image the drive via DD and reboot, Dom0 is unable to find the root parition label and we crash out to dracut. This is peculiar as GRUB2 is able to see the root-label without issue and Xen is even able to boot and start Dom0.

When installing from ISO this was not an issue. I suspect either there was an issue with block-size alignment or not using the full disk when imaging. (Right now we create a 60GB image without a local SR).

Command I am using to image the drive...

```shell
apt install -y qemu-utils
qemu-img dd -f qcow2 -O raw bs=4K if=packer-xcp-ng of=/dev/nvm0n1`
```
