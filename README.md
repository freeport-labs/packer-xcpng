# packer-curtin-xcpng

## About
Packer script to build a qemu image of an XCP-NG Install. This isn't quite working yet and ultimately should be able to be deployed via curtin to support a BMC Deployment.

## Goals

Create and image of XCP to deploy to bare-metal.

# Todo

[] - Create image to match size of target disk, instead of expanding after install. QEMU Compression should help make this managable and we can expand during the imaging process.
[] - Support configuring networking on the host either via the answerfile.xml process or a first-boot mechanicsm.

  Thoughts: Many BMC Cloud providers support / require the use of LACP Bonds for connectivity. There is no garuntee (though high likelyhood) that the network will be configrued with `no lacp suspend-individual` which allows a single interface to function as long as no LACP PDU's are recieved within a certain time window. This is usually done to allow PXE installations to work on top-of-rack switches.

  Still, we should attempt to configure networking ahead of time in a case a where provider does not have this configured.

  Bonds should additionally support vlans. This is a bit tricky to do for the management NIC in XCP-NG out of the box.

# What is currently not working.

When we image the drive via DD and reboot, Dom0 is unable to find the root parition label and we crash out to dracut. This at peculiar as GRUB2 is able to see the root-label without issue and Xen is even able to boot and start Dom0.

When installing from ISO this was not an issue. I suspect either there was an issue with block-size alignment or not using the full disk when imaging. (Right now we create a 60GB image without a local SR).
