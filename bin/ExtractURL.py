#! /usr/bin/python

import re
import requests
import sys

def ExtractURL(html_file_name, seed_url) :
	html_file = open(html_file_name);
	try :
		page = html_file.read()
	finally :
		html_file.close()
	# print page
	link_list = re.findall(r"(?<=href=\")" + ".+?(?=\")", page)
	link_list += re.findall(r"(?<=href=\')" + ".+?(?=\')", page)

	for link in link_list :
		if (len(re.findall(r" ", link))) :
			continue
		elif (len(link) >= len("http://")) :
			if (0 == cmp(link[0 : len("http://")], "http://")) :
					if ((len(link) >= len(seed_url)) and (0 == cmp(link[0 : len(seed_url)], seed_url))) :
						print link
			else :
				print seed_url + link
		else :
			print seed_url + link

	return

ExtractURL(sys.argv[1], sys.argv[2])
