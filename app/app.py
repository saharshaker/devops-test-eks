from flask import Flask, Response
from datetime import datetime
import pytz
from prometheus_client import Counter, generate_latest
from flask_basicauth import BasicAuth

app = Flask(__name__)

app.config['BASIC_AUTH_USERNAME'] = 'prom'
app.config['BASIC_AUTH_PASSWORD'] = '1234'
basic_auth = BasicAuth(app)

gandalf_counter = Counter('gandalf_requests_total', 'total requests to gandalf endpoint')
colombo_counter = Counter('colombo_requests_total', 'total requests to colombo endpoint')

@app.route('/gandalf')
def gandalf():
    gandalf_counter.inc()
    html = '''
    <html>
    <body>
    <img src="https://upload.wikimedia.org/wikipedia/en/e/e9/Gandalf600ppx.jpg" width="400">
    </body>
    </html>
    '''
    return html

@app.route('/colombo')
def colombo():
    colombo_counter.inc()
    colombo_tz = pytz.timezone('Asia/Colombo')
    current_time = datetime.now(colombo_tz)
    time_str = current_time.strftime('%Y-%m-%d %H:%M:%S')
    
    html = f'''
    <html>
    <body>
    <h1>current time in colombo</h1>
    <h2>{time_str}</h2>
    </body>
    </html>
    '''
    return html

@app.route('/metrics')
@basic_auth.required
def metrics():
    data = generate_latest()
    return Response(data, mimetype="text/plain; version=0.0.4; charset=utf-8")
    
@app.route('/iamalive')
def healthz():
    return 'ok', 200

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
