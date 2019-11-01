import argparse

def get_parser():
	parser = argparse.ArgumentParser()
	parser.add_argument('--output_file', type=str, required=True)
	parser.add_argument('--input_file', type=str, required=True)
	args = parser.parse_args()
	return args

args = get_parser()

with open(args.input_file,'r') as f:
	inst = f.readlines()
	ans = [item.strip().split('ans: ')[-1] for item in inst if 'ans' in item]

with open(args.output_file,'w') as f:
	f.write('\n'.join(ans))