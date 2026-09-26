def add(a, b):
    return a + b

def divide(a, b):
    if b == 0:
        raise ValueError("division by zero")
    return a / b

def average(nums):
    return sum(nums) / len(nums)
