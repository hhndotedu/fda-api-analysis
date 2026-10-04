import sys, datetime, os, psycopg
from urllib import request, error
from datetime import datetime, timedelta


def convert_str_datetime(str_date):
    format = '%m-%d-%Y'
    try:
        return datetime.strptime(str_date, format)
    except:
        print(str.format('Please enter date in {}', format))
        sys.exit(1)

def convert_datetime_str(date):
    return date.strftime('%Y%m%d')


def process_request(resp):
    print(resp)

class RecallController:
    limit    = 1000
    skip     = 0 
    total    = 0
    url      = '' 
    date_col = 'report_date'
    start    = datetime.today() - timedelta(days=7) 
    end      = datetime.now()
    search   = ''
    connection = None

    def __init__(self, url, limit, start, end, conn, date_col):
        self.limit    = limit
        self.skip     = 0
        self.url      = url
        self.start    = start
        self.end      = end
        self.conn     = conn
        self.date_col = date_col

    def url_builder(self):
        return str.format('{}?search={}&limit={}&skip={}', self.url, self.search, self.limit, self.skip)

    def build_search(self):
        # ?search=report_date:[20040101+TO+20131231]&limit=1
        if self.end != None:
            return str.format("{}:[{}+TO+{}]", self.date_col, convert_datetime_str(self.start), convert_datetime_str(self.end))
        else:
            return str.format("{}:{}", self.date_col, convert_datetime_str(self.start)) 

    def send_request(self, url):
        req = request.Request(url)

        with request.urlopen(req) as response:
           return response.read()

    def process_response(self, req):
        print(req)
        return True 

    def begin_ingest(self):
        self.search = self.build_search()
        while True:
            url = self.url_builder() 
            try:
                resp = self.send_request(url)
                done = self.process_response(resp)
                if done: 
                    break
            except error.HTTPError as e:
                print(f"Http error {e.code} {e.msg}")
                break

def main():
    url = 'https://api.fda.gov/drug/enforcement.json'
    args = sys.argv
    start_date = datetime.today() - timedelta(days=7)
    end_date = datetime.today()
    date_col = 'report_date'
    limit  = 1000
    db_url = os.getenv('FDA_CONN', None)

    if (db_url == None):
        print("Please set FDA_CONN enviroment variable")
        sys.exit(1)

    for i, arg in enumerate(args):
        if arg == '-s':
            start_date = convert_str_datetime(args[i + 1])
        if arg == '-e':
            end_date = convert_str_datetime(args[i + 1])
        if arg == '-c':
            date_col = args[i + 1]
        else:
            continue

    conn = psycopg.connect(db_url)
    controller = RecallController(url, limit, start_date, end_date, conn, date_col)

    controller.begin_ingest()

if __name__ == "__main__":
    main()






