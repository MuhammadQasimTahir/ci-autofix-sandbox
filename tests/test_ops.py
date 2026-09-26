from calc.ops import add, divide, average
import pytest

def test_add():
    assert add(2, 3) == 5

def test_divide():
    assert divide(10, 2) == 5

def test_divide_zero():
    with pytest.raises(ValueError):
        divide(1, 0)

def test_average():
    assert average([2, 4, 6]) == 4
