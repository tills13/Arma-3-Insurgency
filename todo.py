import os
import sys
import time

accepted_fileexts = [".sqf", ".py"]
todo = open(os.path.join(os.getcwd(), "todo.md"), 'w')
# todo: parse todo.md and ignore duplicates/remove comments for things that I've completed.

def main(dir):
	for file in os.listdir(dir):
		if os.path.isdir(os.path.join(dir, file)): main(os.path.join(dir, file))
		else: 
			if file[file.rfind('.'):] in accepted_fileexts:
				 with open(os.path.join(dir, file)) as f:
				 	file_index = 0
				 	for index, line in enumerate(f):
				 		file_index += 1
				 		line = str.replace(line, "\t", "")
				 		line = str.replace(line, "\n", "")
				 		line = str.replace(line, "\r", "")
				 		line.strip()
				 		if "todo:" in line and (line[line.index("todo:") - 2] in "#//"):
				 			todo.write("- [ ] {0} ({1}, {2})\n".format(line[line.index(':') + 2:], file, file_index))

main(os.getcwd())
todo.close()