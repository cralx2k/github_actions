"""
Tests for the calculator application
"""
import pytest
from app import add, subtract, multiply, divide


def test_add():
    """Test addition"""
    assert add(2, 3) == 5
    assert add(-1, 1) == 0
    assert add(0, 0) == 0


def test_subtract():
    """Test subtraction"""
    assert subtract(5, 3) == 2
    assert subtract(0, 5) == -5
    assert subtract(10, 10) == 0


def test_multiply():
    """Test multiplication"""
    assert multiply(3, 4) == 12
    assert multiply(-2, 5) == -10
    assert multiply(0, 100) == 0


def test_divide():
    """Test division"""
    assert divide(10, 2) == 5
    assert divide(9, 3) == 3
    assert divide(1, 2) == 0.5


def test_divide_by_zero():
    """Test division by zero raises error"""
    with pytest.raises(ValueError, match="Cannot divide by zero"):
        divide(10, 0)
