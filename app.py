from flask import Flask, request, jsonify
import subprocess
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

@app.route('/query_question', methods=['POST'])
def query_question():
    data = request.get_json()
    user_question = data.get('question')

    try:
        result = run_prolog_query(user_question)
        return jsonify({'result': result}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500


def run_prolog_query(user_question):
    # Escape quotes
    escaped_question = user_question.replace('"', '\\"')
    query = f'question("{escaped_question}", Answer), write(Answer)'
    
    process = subprocess.Popen(
        ['C:/Program Files/swipl/bin/swipl.exe', '-s', 'legal_qa.pl', '-g', query, '-t', 'halt'],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )
    output, error = process.communicate()

    if error and error.strip():
        raise Exception(f"Error executing Prolog query: {error.decode()}")

    return output.decode().strip()




if __name__ == '__main__':
    app.run(debug=True)