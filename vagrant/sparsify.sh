#!/usr/bin/env bash

set -e

# Remove vagrant shared folder
VBoxManage sharedfolder remove milxc-snster-vm --name vagrant || true

# Get HD filename
FILENAME=`vboxmanage showvminfo milxc-snster-vm | grep -A2 SATA | grep Location | cut -d':' -f2 | cut -d'(' -f1 | sed -e 's/^[ \t]*//' |  sed -e 's/[ \t]*$//' | sed -e 's/"//g'`

# Split the dir and filename
DIR=`dirname "$FILENAME"`
FILE=`basename "$FILENAME"`

# Get HD UUID
UUID=`vboxmanage showvminfo milxc-snster-vm | grep -A1 SATA | grep UUID | cut -d':' -f 3| cut -d')' -f1 | sed -e 's/^[ \t]*//' |  sed -e 's/[ \t]*$//'`

# echo -e $DIR
# echo -e $FILE
# echo -e $UUID

echo "Old disk is at $DIR/$FILE, moving it away to $DIR/old.vmdk..."
mv -v "$DIR/$FILE" "$DIR/old.vmdk"
echo
echo "Creating a new sparsed disk at $DIR/$FILE from $DIR/old.vmdk..."
virt-sparsify "$DIR/old.vmdk" "$DIR/$FILE"
echo
echo "Setting UUID to $UUID..."
vboxmanage internalcommands sethduuid "$DIR/$FILE" $UUID
echo
echo "Old virtual disk has been moved to $DIR/old.vmdk, you can now confirm its deletion"
rm -iv "$DIR/old.vmdk"
