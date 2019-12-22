from PIL import Image
import os
import json

rgb_dict = {}
eight_bit_dict = {}
file2id = {}
id = 0
for file in os.listdir('.'):
    try:
        im = Image.open(file)
    except:
        print("Open %s failed"%file)
        continue
    file2id[file] = id
    id += 1
    rgb = im.convert('RGB')
    dim_x, dim_y = rgb.size
    rgbs = []
    eights = []
    for y in range(dim_y):
        for x in range(dim_x):
            r, g, b = rgb.getpixel((x, y))
            rgbs.append((r << 16) + (g << 8) + b)
            eights.append(((r // 32) << 5) + ((g // 32) << 2) + (b // 64))
    rgb_dict[file] = rgbs
    eight_bit_dict[file] = eights
with open('rgb.txt', 'w') as f:
    for k, v in rgb_dict.items():
        f.write(k + '\t')
        for item in v:
            f.write(hex(item) + ' ')
        f.write('\n')
with open("eight_bits.txt", 'w') as f:
    for k, v in eight_bit_dict.items():
        f.write(k + '\t')
        for item in v:
            f.write(hex(item) + ' ')
        f.write('\n')
with open("tower.coe", 'w') as f:
    for k, v in eight_bit_dict.items():
        for item in v:
            f.write(hex(item) + '\n')
with open("file2id.json", 'w') as f:
    json.dump(file2id, f)
