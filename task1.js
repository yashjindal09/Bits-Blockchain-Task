// task1.js
function showDetails(itemName) {
  const modal = document.getElementById('detailsModal');
  const itemNameElement = document.getElementById('itemName');
  const itemImageElement = document.getElementById('itemImage');

  itemNameElement.textContent = itemName;
  itemImageElement.src = `images/${itemName.toLowerCase().replace(' ', '')}.jpg`;

  modal.style.display = 'block';
}

function closeModal() {
  const modal = document.getElementById('detailsModal');
  modal.style.display = 'none';
}

document.getElementById('connectButton').addEventListener('click', () => {

});
