'''
 Copyright (C) 2020  Hendrik Scheewel

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; version 3.

 ubuntu-calculator-app is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
'''

import json
import urllib.request

# def GetInfo(var):
#     info = [i[var] for i in li]
#     return(info)

# def GetLoc(var):
#     if var == 'x':
#         var = 'lat'
#     if var == 'y':
#         var = 'lng'
#     coord = [j[var] for j in [i['position'] for i in li]]
#     return(coord)

def AllInfo(contract_name):	
    urlData = 'https://api.jcdecaux.com/vls/v1/stations?apiKey=6d5071ed0d0b3b68462ad73df43fd9e5479b03d6&contract='+contract_name
    webURL = urllib.request.urlopen(urlData)
    data = webURL.read()
    encoding = webURL.info().get_content_charset('utf-8')
    li = json.loads(data.decode(encoding))
    li = sorted(li, key=lambda k: k['number']) 
    return(li)
    
def package_info():
    return("json Version:"+json.__version__+"|| urllib Path:"+urllib.__path__[0])

