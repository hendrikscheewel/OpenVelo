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
import datetime
import urllib.request

networks_url = "http://api.citybik.es/v2/networks?fields=id,name,location"

def load_data(url):
    webURL = urllib.request.urlopen(url)
    data = webURL.read()
    encoding = webURL.info().get_content_charset('utf-8')
    li = json.loads(data.decode(encoding))
    return(li)

def load_networks():
    data = load_data(networks_url)['networks']
    return(data)

def load_stations(network_ID):
    ID_url = "http://api.citybik.es/v2/networks/{ID}".format(ID=network_ID)
    data = load_data(ID_url)['network']['stations']
    
    for i in range(len(data)):
        timestamp = data[i]['timestamp']

        time_of_update = last_update = datetime.datetime.strptime(timestamp,"%Y-%m-%dT%H:%M:%S.%fZ") 
        time_now = datetime.datetime.now()

        time_since_update = time_now - time_of_update

        hours = time_since_update.total_seconds()/(60*60)
        hours_int = int(hours)
        minutes = hours-hours_int
        minutes_int = int(minutes*60)

        data[i]['time_since_update'] = {
            'hours': hours_int,
            'minutes': minutes_int
        }
    return(data)

