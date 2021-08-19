items = $("table tr td:nth-child(2)")

var numbers = ""

for (const [key, value] of Object.entries(items)) {
//   console.log(`${key}: ${value.innerText}`);
	numbers = numbers + value.innerText + "\n";
}

console.log(numbers);