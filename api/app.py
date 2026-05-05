from flask import Flask, jsonify
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST

app = Flask(__name__)
REQ = Counter("http_requests_total", "Total HTTP Requests")

@app.route("/")
def home():
    REQ.inc()
    return "API is running"

@app.route("/health")
def health():
    return jsonify(status="ok")

@app.route("/metrics")
def metrics():
    return generate_latest(), 200, {"Content-Type": CONTENT_TYPE_LATEST}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
