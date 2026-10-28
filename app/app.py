import os
import socket

from flask import Flask, jsonify, render_template

app = Flask(__name__)

NOTICES = [
    {"id": 1, "title": "Mid-sem exams start Monday", "tag": "Exams"},
    {"id": 2, "title": "Hackathon registrations close Friday", "tag": "Events"},
    {"id": 3, "title": "Library open till 10 PM this week", "tag": "Campus"},
]


def version():
    return os.environ.get("APP_VERSION", "v1")


@app.route("/")
def home():
    return render_template("index.html", notices=NOTICES, version=version(), pod=socket.gethostname())


@app.route("/health")
def health():
    return jsonify(status="ok")


@app.route("/version")
def get_version():
    return jsonify(version=version(), pod=socket.gethostname())


@app.route("/api/notices")
def notices():
    return jsonify(NOTICES)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
