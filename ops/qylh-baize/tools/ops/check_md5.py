#!/usr/bin/python
# -*- coding:utf-8 -*-

# python check_md5.py 资源路径
# python check_md5.py client/project/update/release/android
import json
import hashlib
import sys
import os

def md5sum(fileName):
    md5 = None
    if os.path.isfile(fileName):
        f = open(fileName,'rb')
        md5_obj = hashlib.md5()
        md5_obj.update(f.read())
        hash_code = md5_obj.hexdigest()
        f.close()
        md5 = str(hash_code).lower()
    return md5


if __name__ == "__main__":
    path = os.path.abspath(sys.argv[1])
    with open(os.path.join(path, "update_files.json"), 'r') as json_file:
        files = json.loads(json_file.read())
        check_fail = False
        for f in files:
            checksum = md5sum(os.path.join(path, f['abName']))
            # print f['abName'], checksum
            if checksum == None:
                check_fail = True
                print f['abName'], "文件不存在"
            elif checksum != f['md5']:
                check_fail = True
                print f['abName'], checksum, f['md5'], "MD5不一致"
        if check_fail:
            sys.exit(1)
        sys.exit(0)
