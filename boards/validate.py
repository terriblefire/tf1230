#!/usr/bin/python

import argparse

def parsePins(f):
    pins = {}
    for line in f:
        tokens = line.split()
        if len(tokens) == 2 and tokens[1].startswith("S:PIN"):
            pin = tokens[1][5:]
            pins[pin] = tokens[0]
    return pins

def parseUcf(f):
    pins = {}
    for line in f:
        if line.startswith('NET'):
            line = line.replace('"','').replace(";","")
            tokens = line.split()
            # remove the leading NET
            tokens = tokens[1:]
            for item in tokens[1:]:
                if item.lower().startswith('loc'):
                    pin=item[4:]
                    pins[pin] = tokens[0]
    return pins

def validateCpld(CHIP="bus", REV="2", BOARD="tf534"):
    valid = True
    PINFILE="""work/{board}r{rev}_{chip}_top.gyd""".format(board=BOARD,rev=REV,chip=CHIP)
    UCFFILE="""./{board}r{rev}_{chip}.ucf""".format(board=BOARD,rev=REV,chip=CHIP)
    
    print "Parsing Pinfreeze File:",PINFILE,"....",
    with open(PINFILE) as f:
        pins = parsePins(f)
        print "Done"

    print "Parsing UCF File",UCFFILE,"....", 
    with open(UCFFILE) as f:
        locs = parseUcf(f)
        print "Done"

    print "Comparing pincounts...",
        
    if len(pins) != len(locs):
        print "Mismatch!"
        valid = False
    else:
        print "Done"
            
    for pin in pins.keys():
        
        try:
            print "Checking pin", pin, "PIN:", pins[pin], "UCF:",locs[pin],
            if locs[pin] == pins[pin]:
                print "Correct"
            else:
                print "Error"
                valid = False
        except KeyError:
            print "Error - PIN NOT IN UCF FILE!"
            valid = False
        
    for pin in locs.keys():
        try:
            print "Checking pin", pin, "UCF:", locs[pin], "PIN:", pins[pin],
            if locs[pin] == pins[pin]:
                print "Correct"
            else:
                print "Error"
                valid = False
        except KeyError:
            valid = False
            print "Error - Pin not found in design"

            
parser = argparse.ArgumentParser(description='Validate a ucf file against a pinfreeze file.')
parser.add_argument('--rev', help='board revision', default='2')
parser.add_argument('--chip', help='chip name', default='bus')
parser.add_argument('--board', help='board version', default='tf534')
args = parser.parse_args()
    
validateCpld(args.chip, args.rev, args.board)
