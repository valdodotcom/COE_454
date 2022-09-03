# normal recursion depth maxes out at ~ 1000
def normal_factorial(n):
    if n == 0:
        return 1
    else:
        return factorial(n - 1) * n

# python doesn't support tail-call optimization by default
# this class enables it to be done, using the decorator

class Recurse(Exception):
    def __init__(self, *args, **kwargs):
        self.args = args
        self.kwargs = kwargs


def recurse(*args, **kwargs):
    raise Recurse(*args, **kwargs)


def tail_recursive(f):
    def decorated(*args, **kwargs):
        while True:
            try:
                return f(*args, **kwargs)
            except Recurse as r:
                args = r.args
                kwargs = r.kwargs
                continue

    return decorated


# tail recursion works as long as computer can handle
@tail_recursive
def factorial(n, accumulator=1):
    if n == 0:
        return accumulator
    recurse(n - 1, accumulator=accumulator * n)


print(factorial(1500))
