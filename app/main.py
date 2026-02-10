"""This is the python file to which we will create the Flask App for the Homework"""

from flask import Flask, request, jsonify
import ast

app = Flask(__name__)


@app.route("/")
def root():
    return "Welcome to A3-Devops-App"

@app.route("/multiplication", methods=["GET"])
def multiplication():
    num_1 = request.args.get("num_1")
    num_2 = request.args.get("num_2")

    try:
        num_1 = float(num_1)
        num_2 = float(num_2)
    except (TypeError, ValueError):
        return jsonify(error=f"Input must be two numbers. Your input was {num_1} and {num_2}"), 400

    result = num_1 * num_2
    return jsonify(result=result)


@app.route("/sort_ascending", methods=["GET"])
def sort_ascending():
    list_numbers = request.args.get("numbers_list")

    if not list_numbers:
        return jsonify(error="Missing 'numbers_list' parameter"), 400

    try:
        # Accept either a JSON-style list like "[1, 2, 3]" or a comma-separated string "1,2,3"
        if isinstance(list_numbers, str) and list_numbers.strip().startswith("["):
            nums = ast.literal_eval(list_numbers)
        else:
            nums = [s.strip() for s in list_numbers.split(",") if s.strip() != ""]

        # Convert all items to float
        nums = [float(n) for n in nums]
    except (ValueError, SyntaxError, TypeError):
        return jsonify(error=f"Input must be a list of numbers. Your input was {list_numbers}"), 400

    nums_sorted = sorted(nums)
    return jsonify(sorted=nums_sorted)

@app.route("/counts_values", methods=["GET"])
def count_values():
    values = request.args.get("values")
    if not values:
        return jsonify(error="Missing 'values' parameter"), 400

    try:
        # Accept either a JSON-style list like "[1, 2, 3]" or a comma-separated string "1,2,3"
        if isinstance(values, str) and values.strip().startswith("["):
            items = ast.literal_eval(values)
        else:
            items = [s.strip() for s in values.split(",") if s.strip() != ""]
    except Exception:
        return jsonify(error=f"Input must be a list of values. Your input was {values}"), 400

    # Count occurrences
    counts = {}
    for item in items:
        counts[str(item)] = counts.get(str(item), 0) + 1

    return jsonify(counts)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
        