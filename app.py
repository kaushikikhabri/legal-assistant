import ast
import re
import string
import subprocess
from difflib import get_close_matches
from flask import Flask, request, jsonify, render_template
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# -----------------------------
# Route 1: Homepage for Crime Form
# -----------------------------

# -----------------------------
# Route 2: Form Submission - Crime Classification
# -----------------------------
@app.route('/submit', methods=['POST'])
def submit():
    data = request.get_json()
    print("Received data:", data)
    app.logger.info("Received data: %s", data)

    crime_description = data.get('crime_description', '')
    weapon_used = 'Yes' if data.get('weapon') == 'on' else 'No'
    weapon_type = data.get('weapon_type') if weapon_used == 'Yes' else None
    victim_status = data.get('victim_status', '')
    crime_type = data.get('crime_type', [])
    additional_details = data.get('additional_details', '')

    ipc_results = call_prolog(crime_description, weapon_used, weapon_type, victim_status, crime_type)
    app.logger.info("IPC results: %s", ipc_results)

    return render_template('ipc.html', ipc_results=ipc_results)

def call_prolog(crime_description, weapon_used, weapon_type, victim_status, crime_types):
    prolog_command = [
        'C:/Program Files/swipl/bin/swipl.exe', '-s', 'crime_analysis.pl',
        '-g', f'classify_crime("{crime_description}", "{weapon_used}", "{weapon_type}", "{victim_status}")',
        '-t', 'halt'
    ]
    print("Prolog command:", prolog_command)

    try:
        result = subprocess.check_output(prolog_command, stderr=subprocess.PIPE).decode()
        return result
    except subprocess.CalledProcessError as e:
        return f"Final Analysis: {e.output.decode()}"

# -----------------------------
# Route 3: Smart Legal Assistant
# -----------------------------
def load_qa_pairs():
    qa_pairs = []
    with open("legal_qa.pl", "r", encoding="utf-8") as file:
        for line in file:
            match = re.match(r'question\("(.*?)",\s*"(.*?)"\)\.', line.strip())
            if match:
                question, answer = match.groups()
                qa_pairs.append((question, answer))
    return qa_pairs

qa_pairs = load_qa_pairs()
all_questions = [q for q, _ in qa_pairs]

def tokenize(text):
    text = text.lower().translate(str.maketrans('', '', string.punctuation))
    return set(text.split())

def find_best_keyword_match(user_question):
    user_tokens = tokenize(user_question)
    best_match = None
    max_overlap = 0

    for question, answer in qa_pairs:
        question_tokens = tokenize(question)
        overlap = len(user_tokens & question_tokens)
        if overlap > max_overlap:
            max_overlap = overlap
            best_match = (question, answer)

    return best_match if max_overlap >= 2 else None

def run_smart_query(user_question):
    best_match = find_best_keyword_match(user_question)
    if best_match:
        return best_match[1]

    close = get_close_matches(user_question, all_questions, n=1, cutoff=0.5)
    if close:
        matched_q = close[0]
        for q, a in qa_pairs:
            if q == matched_q:
                return a

    return "Sorry, I couldn't find a relevant answer. Try rephrasing your question."

@app.route('/query_question', methods=['POST'])
def query_question():
    data = request.get_json()
    user_question = data.get('question')
    try:
        result = run_smart_query(user_question)
        return jsonify({'result': result}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# -----------------------------
# Route 4: Lawyer Matching by Case Type
# -----------------------------
@app.route('/get_lawyers', methods=['POST'])
def get_lawyers():
    try:
        data = request.get_json()
        case_type = data.get('case_type', '').lower()

        # Update the Prolog command to only retrieve the lawyer's name
        prolog_command = [
            'C:/Program Files/swipl/bin/swipl.exe', '-s', 'lawyer.pl',
            '-g', f"findall(Name, (lawyer(Name, Specs, Level, Years), member({case_type}, Specs)), Result), write(Result)",
            '-t', 'halt'
        ]

        result = subprocess.check_output(prolog_command, stderr=subprocess.PIPE).decode().strip()
        print("Raw Prolog output:", result)

        # Step 1: Clean up the output to extract just the lawyer names
        # Replace the Prolog output with only the names
        result = result.replace('lawyer(', '').replace(')', '').replace('[', '').replace(']', '')

        # Step 2: Extract the lawyer names from the Prolog list
        lawyer_names = result.split(',')
        lawyer_names = [name.strip() for name in lawyer_names]  # Clean up any extra spaces

        # Step 3: Return the names as a JSON response
        return jsonify({'matched_lawyers': lawyer_names}), 200

    except subprocess.CalledProcessError as e:
        return jsonify({'error': e.output.decode()}), 500
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# -----------------------------
# Run Flask App
# -----------------------------
if __name__ == '__main__':
    app.run(debug=True)
