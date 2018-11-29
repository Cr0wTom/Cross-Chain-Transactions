!/usr/bin/python

# todo: Error Checking

import sys

print "Installing Go..."
if sys.platform == "linux" or sys.platform == "linux2":
    os.system("sudo apt-get install golang-1.11-go && sudo ln -s /usr/lib/go-1.10/bin/go /usr/local/bin/go
")
elif sys.platform == "darwin": #all OSX versions
    os.system("brew install go")
os.system("export GOPATH=~/gocode && export PATH=$PATH:$GOPATH/bin")

print "Installing LND"

os.system("go get -d github.com/lightningnetwork/lnd")
os.system("cd $GOPATH/src/github.com/lightningnetwork/lnd")
os.system("make && make install")

print "Installing BTCD..."

os.system("go get -u github.com/Masterminds/glide")
os.system("git clone https://github.com/btcsuite/btcd $GOPATH/src/github.com/btcsuite/btcd")
os.system("cd $GOPATH/src/github.com/btcsuite/btcd && glide install && go install . ./cmd/...")

os.system("")

print "Starting btcd"

os.system("btcd --testnet --rpcuser=REPLACEME --rpcpass=REPLACEME") # Change user and password before usage
