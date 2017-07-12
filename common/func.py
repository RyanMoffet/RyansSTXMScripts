import os, re
filename = 'loadFunctions.m'
funcs = [re.match(r'^function.*[=](.*)[(]',x).group(1).strip()
         for x in open(filename,'r').readlines()
         if re.match('^function',x) and
         os.path.splitext(filename)[0] not in x]
print '\n\n'.join(['function F = ' + os.path.splitext(filename)[0] + '()',
                   'F = struct(' +
                   ','.join(["'"+x+"'"+',@'+x for x in funcs])+');',
                   'return'])
