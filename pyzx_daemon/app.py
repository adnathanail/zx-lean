from flask import Flask, jsonify, request
from flask_cors import CORS

from lib.lean_to_pyzx import zxlean_to_pyzx
from lib.pyzx_to_img import render_to_base64

app = Flask(__name__)
CORS(app)


@app.route("/diagram", methods=["POST"])
def diagram():
    data = request.get_json()
    try:
        g = zxlean_to_pyzx(data)
        image = render_to_base64(g)
        return jsonify({"status": "ok", "image": image})
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500


if __name__ == "__main__":
    app.run(host="127.0.0.1", port=5050, debug=True)
