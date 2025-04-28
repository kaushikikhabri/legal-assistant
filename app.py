from flask import Flask, request, jsonify
import subprocess
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

@app.route('/query_article', methods=['POST'])
def query_article():
    data = request.get_json()
    article_id = data.get('article_id')

    # Call Prolog to get the article based on ID
    try:
        result = run_prolog_query(article_id)
        return jsonify({'result': result}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

def run_prolog_query(article_id):
    query = f"query_article({article_id})"
    process = subprocess.Popen(
        ['C:/Program Files/swipl/bin/swipl.exe', '-s', 'constitution.pl', '-g', query, '-t', 'halt'],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )
    output, error = process.communicate()

    if error:
        raise Exception(f"Error executing Prolog query: {error.decode()}")

    return output.decode().strip()


if __name__ == '__main__':
    app.run(debug=True)
