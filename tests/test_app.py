import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "app"))

from app import app  # noqa: E402

client = app.test_client()


def test_home_returns_200():
    assert client.get("/").status_code == 200


def test_health_ok():
    assert client.get("/health").get_json() == {"status": "ok"}


def test_notices_non_empty_list():
    data = client.get("/api/notices").get_json()
    assert isinstance(data, list) and len(data) > 0


def test_version_returns_json():
    r = client.get("/version")
    assert r.is_json
    assert {"version", "pod"} <= r.get_json().keys()
