import xlrd
import xlwt
import datetime
import re

from lookup_table import LookupTable
from token_table import TokenTable

def step_range(start, end, step):
	while start <= end:
		yield start
		start += step

# do birthday trans
def birthday_trans(old_type):
	if len(old_type) < 7:
		return ''
	year = old_type[0:3]
	if year == '000':
		return ''
	else:
		year = str(int(year) + 1911)
		month = old_type[3:5]
		day = old_type[5:7]	
		birthdate = year + '/' + month + '/' + day
		return birthdate

def age_trans(birthdate):
	if birthdate == '':
		return ''
	else:	
		now_year = datetime.datetime.now().year
		try:
			age = now_year - int(re.split('/', birthdate)[0])
			print(int(re.split('/', birthdate)[0]))
		except ValueError as e:
			print(birthdate)
			return ''
		return age

def generate_token(sheet):
	output = xlwt.Workbook(encoding="utf-8")

	# two separate sheet
	token_sheet = output.add_sheet("1")
	print(sheet, token_sheet)
	token_table = TokenTable(sheet, token_sheet)

	token_table.get_basic_info()
	token_list = ["家暴因素.可複選.", "成人家庭暴力兩造關係", 
				"暴力型態.可複選.", "EDUCATION", "off_EDUCATION"]

	token_hash = token_table.set_token_attr(token_list)
	output.save("/Users/brianpan/Desktop/data/token.xlsx")

	return token_hash
	
# 對 DVAS做資料binary化

# mutiple token 轉換
def trans_token(token, used_token_list):
	return int(used_token_list[token]) - 1  		

def tokenize_sheet():
	# book file
	book = xlrd.open_workbook('/Users/brianpan/Desktop/data/DVAS建模用.xlsx')
	# load sheet 2 已補過特定missing value
	# load sheet 0 沒補過資料的
	sheet = book.sheet_by_index(3)

	# load token
	token_hash = generate_token(sheet)
	print(token_hash)

	# output file
	output = xlwt.Workbook(encoding="utf-8")
	output_sheet = output.add_sheet("1")

	clean_list = ["家暴因素.可複選.", "成人家庭暴力兩造關係",
				"MAIMED", "off_MAIMED", 
				"暴力型態.可複選.", "EDUCATION", "off_EDUCATION"]
	wcol = 0
	for idx in range(sheet.ncols):
		attribute = sheet.cell_value(rowx=0,colx=idx)
		
		print("--- {0}% Start cleaning : {1} ---".format(round((idx/sheet.ncols)*100, 2), attribute))
		
		# need clean
		if attribute in token_hash.keys():
			used_token_list = token_hash[attribute]
			# mutiple one to cols
			if attribute == "家暴因素.可複選." or attribute == "暴力型態.可複選.":
				
				# should sort key again !!!
				expand_cols = sorted(token_hash[attribute].keys())
				
				print(expand_cols)

				sub_feature_num = len(expand_cols) - 1 
				for l_idx, expand_col in enumerate(expand_cols):
					if expand_col != "":
						output_sheet.write(0, wcol+l_idx-1, attribute + "-"+ expand_col)
				for ridx in step_range(1, sheet.nrows-1, 1):
					data_val = sheet.cell_value(rowx=ridx,colx=idx)
					# 拿後面本次家暴因素補值
					if attribute == "家暴因素.可複選.":
						overwrite_val = sheet.cell_value(rowx=ridx,colx=idx+2)
					else:
						overwrite_val = sheet.cell_value(rowx=ridx,colx=idx+1)
						
					if data_val == '':
						data_val = overwrite_val

					# missing value
					if data_val == '':
						for sub_idx in range(sub_feature_num):
							output_sheet.write(ridx, wcol + sub_idx, "NA")
					else:
						try:
							tokens = re.split(",", data_val)
							is_idx = [trans_token(token, used_token_list) for token in tokens]
						except:
							print(data_val)

						for sub_idx in range(sub_feature_num):
							if sub_idx in is_idx:
								output_sheet.write(ridx, wcol+sub_idx, 1)
							else:
								output_sheet.write(ridx, wcol+sub_idx, 0)
										
				# should ignore '' token		
				wcol += sub_feature_num
			# one col
			else:			
				output_sheet.write(0, wcol, attribute)
				
				for ridx in step_range(1, sheet.nrows-1, 1):
					data_val = sheet.cell_value(rowx=ridx, colx=idx)
					
					if attribute == "MAIMED" or attribute == "off_MAIMED":
						if data_val == '':
							output_sheet.write(ridx, wcol, "NA")
						else:
							to_parse = re.split(",", data_val)[0]
							if re.match('疑似身心障礙.*', to_parse):
								write_val = used_token_list["身心障礙"]
								output_sheet.write(ridx, wcol, write_val)
							elif re.match('領有身心障礙.*', to_parse):
								write_val = used_token_list["疑似身心障礙者"]
								output_sheet.write(ridx, wcol, write_val)
							else:
								write_val = used_token_list["非身心障礙者"]
								output_sheet.write(ridx, wcol, write_val)	
					elif attribute == "EDUCATION" or attribute == "off_EDUCATION":
						if data_val == '' or data_val == '不詳':
							output_sheet.write(ridx, wcol, "NA")
						else:
							output_sheet.write(ridx, wcol, used_token_list[data_val])	
					# 成人家庭暴力兩造關係	
					else:
						if data_val == '':
							output_sheet.write(ridx, wcol, "NA")
						else:	
							output_sheet.write(ridx, wcol, used_token_list[data_val])
				wcol += 1
		else:
			output_sheet.write(0, wcol, attribute)
			for ridx in range(sheet.nrows):
				if ridx == 0:
					print("--")
				else:
					cell_val = sheet.cell_value(rowx=ridx,colx=idx)
					output_sheet.write(ridx, wcol, cell_val)	
			wcol += 1

	output.save("/Users/brianpan/Desktop/data/DVAS_clean.xlsx")

# clean 被害人相對人, 通報表資料
def lookup_process():
	lookup_book = LookupTable('/Users/brianpan/Desktop/data/data/lookup_table.xlsx')
	lookup_book.set_sheet_id(1)

	lookup_book.get_basic_info()

	print(lookup_book.set_all_lookup_attributes())

	# start process
	# book = xlrd.open_workbook('/Users/brianpan/Desktop/data/通報表被害人相對人資料.xls')
	book = xlrd.open_workbook('/Users/brianpan/Desktop/data/data/個案被害人相對人資料.xls')
	sheet = book.sheet_by_index(0)
	print(sheet.nrows, sheet.ncols)
	#
	output = xlwt.Workbook(encoding="utf-8")
	output_sheet = output.add_sheet("1")
	for idx in range(sheet.ncols):
		attribute = sheet.cell_value(rowx=0,colx=idx)
		print("--- {0}% Start cleaning : {1} ---".format(round((idx/sheet.ncols)*100, 2), attribute))
		if lookup_book.get_lookup_attributes(attribute) is not False:
			print(attribute)
			
			output_sheet.write(0, idx, attribute)
			lookup_attributes = lookup_book.get_lookup_attributes(attribute)
			
			# lookup loop 
			if attribute == 'MAIMED' or attribute == 'SITUATIONITEM' or attribute == 'SPECIALNOTE' or attribute == 'CASEROLE' or attribute == 'INCOMETYPE':
				for ridx in step_range(1, sheet.nrows-1, 1):
					origin_data = sheet.cell_value(rowx=ridx, colx=idx)
					if origin_data != "":
						char_list = list(origin_data)
						try:
							if len(char_list) > 1:
								modify_data = ",".join([lookup_attributes[char_idx] for char_idx in char_list])
							else:
								modify_data = lookup_attributes[char_list[0]]
						except KeyError as e:
							print("cell : {0},{1},{2} failed".format(ridx, idx, origin_data))
							output_sheet.write(ridx, idx, origin_data)
						else:
							output_sheet.write(ridx, idx, modify_data)
			else:
				
					# print(sheet.cell_value(rowx=1, colx=idx))	
				for ridx in step_range(1, sheet.nrows-1, 1):
					origin_data = sheet.cell_value(rowx=ridx, colx=idx)
					if origin_data != '':
						try:
							modify_data = lookup_attributes[str(origin_data)]
						except KeyError as e:
							print("cell : {0},{1},{2} failed".format(ridx, idx, origin_data))
							output_sheet.write(ridx, idx, origin_data)
						else:
							output_sheet.write(ridx, idx, modify_data)	
		else:
			for ridx in range(sheet.nrows):
				modify_data = sheet.cell_value(rowx=ridx, colx=idx)
				if ridx == 0:
					print('--')
				elif attribute == 'BDATE':
					modify_data = birthday_trans(modify_data)
					BDATE_IDX = idx
				elif attribute == 'AGE':
					birthdate = birthday_trans(sheet.cell_value(rowx=ridx,colx=BDATE_IDX))
					modify_data = age_trans(birthdate)
				output_sheet.write(ridx, idx, modify_data)
	

	# output.save("/Users/brianpan/Desktop/data/通報表被害人相對人資料_clean.xls")
	output.save("/Users/brianpan/Desktop/data/data/個案被害人相對人資料_clean.xls")
# load lookup table
if __name__ == "__main__":
	tokenize_sheet()


