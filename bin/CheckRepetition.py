#! /usr/bin/python

import sys;

def CheckRepetition(urls, url) :
	urls_file = open(urls)
	line = urls_file.readline()
	while line :
		print line + " " + url
		if (line == url) :
			print "1"
			return
		line = urls_file.readline()

	urls_file.close()
	print "0"
	return

CheckRepetition(sys.argv[1], sys.argv[2])
