import ast
import operator
from pathlib import Path

from fastapi import FastAPI, HTTPException
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel


OPERATORS = {
	ast.Add: operator.add,
	ast.Sub: operator.sub,
	ast.Mult: operator.mul,
	ast.Div: operator.truediv,
	ast.FloorDiv: operator.floordiv,
	ast.Mod: operator.mod,
	ast.Pow: operator.pow,
}

BASE_DIR = Path(__file__).resolve().parent
app = FastAPI(title="Calculator API")
app.mount("/static", StaticFiles(directory=BASE_DIR / "static"), name="static")


class CalculationRequest(BaseModel):
	expression: str


def calculate(expression):
	"""Calculate a basic arithmetic expression safely."""
	tree = ast.parse(expression, mode="eval")
	return evaluate(tree.body)


def evaluate(node):
	if isinstance(node, ast.Constant) and isinstance(node.value, (int, float)):
		return node.value

	if isinstance(node, ast.UnaryOp) and isinstance(node.op, (ast.UAdd, ast.USub)):
		value = evaluate(node.operand)
		return value if isinstance(node.op, ast.UAdd) else -value

	if isinstance(node, ast.BinOp) and type(node.op) in OPERATORS:
		left = evaluate(node.left)
		right = evaluate(node.right)
		return OPERATORS[type(node.op)](left, right)

	raise ValueError("Use numbers and operators: +, -, *, /, //, %, or **")


@app.get("/")
def serve_ui():
	return FileResponse(BASE_DIR / "index.html")


@app.post("/api/calc")
def calculate_expression(request: CalculationRequest):
	try:
		return {"result": calculate(request.expression)}
	except (SyntaxError, ValueError, TypeError, ZeroDivisionError, OverflowError) as error:
		raise HTTPException(status_code=400, detail=str(error)) from error


