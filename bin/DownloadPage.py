#! /usr/bin/python

import urllib2, httplib
import StringIO, gzip
import sys

def DownloadPage(url) :
	request = urllib2.Request(url)
	request.add_header('Accept-encoding', 'gzip')

	response = urllib2.urlopen(request)
	if response.info().get('Content-Encoding') == 'gzip' :
		buff = StringIO.StringIO(response.read())
		page = gzip.GzipFile(fileobj = buff)
		data = page.read()
		print data
	else :
		data = response.read()
		print data

	return

DownloadPage(sys.argv[1])
