import sys, datetime, os, psycopg, json, time
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
    total    = -1 # -1 to indicate that nothing has been read
    url      = '' 
    date_col = 'report_date'
    start    = datetime.today() - timedelta(days=7) 
    end      = datetime.now()
    sleep    = 39 / 60 # limited by 40 requests per minute
    search   = ''
    connection = None
    saved_rows = 0

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

    def write_json_to_db(self, data):
        query = """
        INSERT INTO raw_data (raw_data) VALUES (%s)
        """

        cursor = self.conn.cursor()
        try:
            cursor.execute(query, (json.dumps(data),))

            self.conn.commit()
            self.saved_rows += cursor.rowcount
        except Exception as e:
            print("something went wrong saving data in the database")
            print(e)
            exit(1)
        finally:
            cursor.close()

    def extract_meta_data(self, data):
        self.total = data['results']['total']
        print(f"total number of rows", self.total)

    def process_response(self, req):
        data = json.loads(req)
        if self.total == -1:
            self.extract_meta_data(data['meta'])
        
        results = data['results']
        for result in results:
            self.write_json_to_db(result)
        
        self.skip += self.limit
        return self.skip >= self.total
    
    def begin_ingest(self):
        self.search = self.build_search()
        while True:
            url = self.url_builder() 
            try:
                resp = self.send_request(url)
                done = self.process_response(resp)
                print(f"Percent complete {int((self.saved_rows / self.total) * 100)}%")
                if done: 
                    break
                time.sleep(0.05)
            except error.HTTPError as e:
                if e.code == 429:
                    print("Rate limited timing out")
                    time.sleep(self.sleep)
                print(f"Http error {e.code} {e.msg}")
                break
        print(f"total of {self.saved_rows} rows saved")

def main():
    url = 'https://api.fda.gov/drug/enforcement.json'
    args = sys.argv
    start_date = datetime.today() - timedelta(days=1)
    end_date = datetime.today()
    date_col = 'report_date'
    limit  = 1000
    db_url = None 

    for i, arg in enumerate(args):
        if arg == '-s':
            start_date = convert_str_datetime(args[i + 1])
        if arg == '-e':
            end_date = convert_str_datetime(args[i + 1])
        if arg == '-c':
            date_col = args[i + 1]
        if arg == "-d":
            db_url = args[i + 1]
        else:
            continue

    if (db_url == None):
        print("Please pass in database url with -d flag")
        sys.exit(1)

    conn = psycopg.connect(db_url)
    controller = RecallController(url, limit, start_date, end_date, conn, date_col)

    try:
        controller.begin_ingest()
    except Exception as e:
        print("something went wrong")
        print(e)
    finally:
        conn.close()


if __name__ == "__main__":
    main()






