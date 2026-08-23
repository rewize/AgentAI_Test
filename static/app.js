const expression = document.querySelector('#expression');
const error = document.querySelector('#error');

async function calculate() {
  const value = expression.value.trim();
  if (!value) return;

  error.textContent = '';
  try {
    const response = await fetch('/api/calc', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ expression: value })
    });
    const data = await response.json();
    if (!response.ok) throw new Error(data.detail || 'Invalid calculation');
    expression.value = String(data.result);
    expression.select();
  } catch (requestError) {
    error.textContent = requestError.message;
  }
}

document.querySelectorAll('[data-value]').forEach((button) => {
  button.addEventListener('click', () => {
    expression.value += button.dataset.value;
    expression.focus();
  });
});

document.querySelector('[data-action="clear"]').addEventListener('click', () => {
  expression.value = '';
  error.textContent = '';
  expression.focus();
});
document.querySelector('[data-action="calculate"]').addEventListener('click', calculate);
expression.addEventListener('keydown', (event) => {
  if (event.key === 'Enter') calculate();
  if (event.key === 'Escape') document.querySelector('[data-action="clear"]').click();
});
