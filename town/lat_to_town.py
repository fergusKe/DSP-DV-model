#!/usr/bin/env python
# -*- coding: utf8 -*-
import shapefile
import sys

sf = shapefile.Reader("/Users/brianpan/Desktop/data/town/Village_NLSC_123_1050715")

print(sf.fields)

records = sf.records()
shapeRecords = sf.shapeRecords()
total_cols = len(sf.fields)

for idx in range(10):
	if idx in [7,8,9,10]:
		print(sf.fields[idx], records[0][idx].decode('big5', 'ignore'))
	else:	
		print(sf.fields[idx], records[0][idx])

print("locs: ", len(shapeRecords[0].shape.points), " ", shapeRecords[0].shape.points[0])