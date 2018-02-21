import xlrd
import xlwt

import re

def step_range(start, end, step):
	while start <= end:
		yield start
		start += step

class TokenTable(object):
	def __init__(self, target_sheet, token_sheet):
		self.target_sheet = target_sheet
		self.token_sheet = token_sheet
	def get_basic_info(self):
		print("target sheet rows: {0} ; sheet cols: {1}".format(self.target_sheet.nrows,
														  self.target_sheet.ncols))
	def set_token_attr(self, token_list =[]):
		if len(token_list) > 0:
			col_inx = 0
			token_hash = {}

			while(col_inx < self.target_sheet.ncols):
				target_attr = self.target_sheet.cell_value(0, col_inx)
				if(target_attr in token_list):
					token_hash[target_attr] = []
					# loop each row
					ridx = 1
					while(ridx < self.target_sheet.nrows):
						# different use different parsing strategy
						parse_val = self.parse_cell(target_attr, ridx, col_inx)						
						# check parse_val is Array or string
						if type(parse_val) is list:
							for parse_cell in parse_val:
								if(parse_cell not in token_hash[target_attr]):
									token_hash[target_attr].append(parse_cell)
						else:	
							if(parse_val not in token_hash[target_attr]):
									token_hash[target_attr].append(parse_val)
						ridx = ridx + 1
					

					token_hash[target_attr].sort()

				col_inx = col_inx + 1
			
			for dic_val in ["MAIMED", "off_MAIMED"]:
				token_hash[dic_val] = ['', '非身心障礙者', '疑似身心障礙者', '身心障礙']
			# print token hash	
			# print(token_hash)

			# start col_id
			token_cid = 0

			# return hash
			return_hash = {}
			# start write to token sheet
			for key, val_arr in token_hash.items():
				token_rid = 0
				tmp_token_cid = token_cid
				return_hash[key] = {}

				# write header
				title_arr = [key, "原始名稱", "代碼"]
				for i in range(0,3):
					self.token_sheet.write(token_rid, tmp_token_cid, title_arr[i])
					tmp_token_cid += 1
				
				token_rid += 1
					
				# # write content
				for i, content_val in enumerate(val_arr):
					self.token_sheet.write(token_rid, token_cid+1, content_val)
					self.token_sheet.write(token_rid, token_cid+2, i)
					return_hash[key][content_val] = i
					token_rid += 1

				token_cid += 3

			return return_hash
	# parse data strategy				
	def parse_cell(self, target_attr, ridx, cidx):
		cell_value = self.target_sheet.cell_value(ridx, cidx)
		
		# 是空的需要補值 可複選
		if target_attr == "家暴因素.可複選.":
			if cell_value == "":
				backup_cell = self.target_sheet.cell_value(ridx, cidx+1)
				return re.split(",", backup_cell)
			else:
				cell_values = re.split(",", cell_value)
				return cell_values
		# 一般型只要建token list 單選
		if target_attr == "成人家庭暴力兩造關係" or target_attr == "EDUCATION" or target_attr == "off_EDUCATION":
			return cell_value
		# 一般型只要建token list 可複選
		if target_attr == "暴力型態.可複選.":
			cell_values = re.split(",", cell_value)
			return cell_values
		# 需要split - 單選
		# if target_attr == "MAIMED" or target_attr == "off_MAIMED":
		# 	cell_value = re.split("－", cell_value)[0]
		# 	return cell_value

# if __name__ == "__main__":
# 	book = xlrd.open_workbook('/Users/brianpan/Desktop/data/DVAS建模用.xlsx')
# 	sheet = book.sheet_by_index(0)

# 	# output file
# 	output = xlwt.Workbook(encoding="utf-8")

# 	# two separate sheet
# 	token_sheet = output.add_sheet("1")
# 	print(sheet, token_sheet)
# 	token_table = TokenTable(sheet, token_sheet)

# 	token_table.get_basic_info()
# 	token_list = ["家暴因素.可複選.", "成人家庭暴力兩造關係", 
# 				"暴力型態.可複選.", "EDUCATION", "off_EDUCATION"]

# 	token_table.set_token_attr(token_list)
# 	output.save("/Users/brianpan/Desktop/data/token.xlsx")
