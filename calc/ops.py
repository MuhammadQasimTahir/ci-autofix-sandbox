def add(a, b):
    return a + b

def div(a, b):
    if b == 0:
        raise ValueError("division by zero")
    return a / b

def average(nums):
    if not nums:
        return 0
    return sum(nums) / len(nums)
