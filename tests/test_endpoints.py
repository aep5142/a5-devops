"""This python file has the tests for the endpoints of main.py"""

from app.main import app
import pytest

@pytest.fixture
def client():
    app.config["TESTING"] = True
    with app.test_client() as client:
        yield client


def test_multiplication_valid_numbers(client):
    response = client.get("/multiplication?num_1=3&num_2=4")

    assert response.status_code == 200
    assert response.get_json() == {"result": 12.0}

def test_multiplication_string_present(client):
    response = client.get("/multiplication?num_1=Hello_world&num_2=4")

    assert response.status_code == 400
    assert response.get_json() == {
        "error": "Input must be two numbers. Your input was Hello_world and 4"
    }

def test_sort_ascending_valid(client):
    response = client.get("/sort_ascending?numbers_list=[3,2,1]")
    assert response.status_code == 200
    assert response.get_json() == {"sorted": [1.0, 2.0, 3.0]}

def test_sort_ascending_invalid_strings(client):
    response = client.get("/sort_ascending?numbers_list=['a',2,1]")
    assert response.status_code == 400
    assert response.get_json() == {
        "error": "Input must be a list of numbers. Your input was ['a',2,1]"}
    

def test_count_values_valid(client):
    # Test with numbers
    response = client.get("/counts_values?values=1,2,apple,1,apple")
    assert response.status_code == 200
    assert response.get_json() == {"1": 2, "2": 1, "apple": 2}


def test_count_values_invalid(client):
    # Missing parameter
    response = client.get("/counts_values")
    assert response.status_code == 400
    assert response.get_json() == {"error": "Missing 'values' parameter"}

    # Completely invalid input
    response = client.get("/counts_values?values=[1,2,apple,{'bad':1}]")
    assert response.status_code == 400
    assert "error" in response.get_json()




