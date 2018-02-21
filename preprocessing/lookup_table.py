import xlrd
import re
# row starts from 1
# col starts from 0

def step_range(start, end, step):
	while start <= end:
		yield start
		start += step

class LookupTable(object):
	def __init__(self, data_path):
		self.data_path = data_path
		self.data_book = xlrd.open_workbook(data_path)
		self.attributes = {}
	def set_sheet_id(self, sheet_id):
		self.cur_sheet_id = sheet_id
		self.sheet = self.data_book.sheet_by_index(sheet_id)

	def get_basic_info(self):
		print("sheet rows: {0} ; sheet cols: {1}".format(self.sheet.nrows,
														  self.sheet.ncols))	
	def get_lookup_cell(self, rowx, colx):
		print("{0}".format(self.sheet.cell_value(rowx=rowx, colx=colx)))
		return self.sheet.cell_value(rowx=rowx, colx=colx)
	def set_all_lookup_attributes(self):
		for idx in step_range(0, self.sheet.ncols-2, 2):
			#should modify to separate /
			attribute_names = self.sheet.cell_value(1, idx)
			attribute_names = re.split('/', attribute_names)
			for aidx, val in enumerate(attribute_names):
				if val is not "":
					self.attributes[val] = idx
			# 			
		return self.attributes.keys()

	# return lookup dic	
	def get_lookup_attributes(self, lookup_attribute):
		lookup_table = {}
		if lookup_attribute in self.attributes.keys():
			cidx = self.attributes[lookup_attribute]
			ridx = 3
			didx = cidx + 1
			ddidx = cidx + 2
			while(ridx < self.sheet.nrows):
				if lookup_attribute == 'HOUSETOWN' or lookup_attribute == 'CONNTOWN' or lookup_attribute == 'PERMTOWN':
					code_val = self.sheet.cell_value(ridx, didx)
					if code_val == "":
						break
					des_val = self.sheet.cell_value(ridx, ddidx)
				else:
					code_val = self.sheet.cell_value(ridx, cidx)
					if code_val == "":
						break
					des_val = self.sheet.cell_value(ridx, didx)
					
				lookup_table[code_val] = des_val
				ridx += 1
			return lookup_table		
		else:	
			return False

if __name__ == "__main__":
	book = LookupTable('/Users/brianpan/Desktop/data/data/lookup_table.xlsx')
	book.set_sheet_id(1)

	book.get_basic_info()

	print(book.set_all_lookup_attributes())
	print(book.get_lookup_attributes('HOUSETOWN'))
	x = book.get_lookup_attributes('HOUSETOWN')
	print(x['6300900000'])