const app = document.getElementById('app');
const title = document.getElementById('title');
const subtitle = document.getElementById('subtitle');
const audienceText = document.getElementById('audienceText');
const saveToast = document.getElementById('saveToast');
const searchInput = document.getElementById('searchInput');
const categoryFilters = document.getElementById('categoryFilters');
const itemFiltersBlock = document.getElementById('itemFiltersBlock');
const shopFiltersBlock = document.getElementById('shopFiltersBlock');
const playerFiltersBlock = document.getElementById('playerFiltersBlock');
const shopSelect = document.getElementById('shopSelect');
const shopLocationSelect = document.getElementById('shopLocationSelect');
const teleportToShopMarkerButton = document.getElementById('teleportToShopMarkerButton');
const openCreateShopButton = document.getElementById('openCreateShopButton');
const adminPlayerSelect = document.getElementById('adminPlayerSelect');
const itemsList = document.getElementById('itemsList');
const resultsCount = document.getElementById('resultsCount');
const selectedCount = document.getElementById('selectedCount');
const selectedLabel = document.getElementById('selectedLabel');
const selectedMeta = document.getElementById('selectedMeta');
const selectedDescription = document.getElementById('selectedDescription');
const amountInput = document.getElementById('amountInput');
const radiusInput = document.getElementById('radiusInput');
const radiusWrapper = document.getElementById('radiusWrapper');
const playerWrapper = document.getElementById('playerWrapper');
const playerSelect = document.getElementById('playerSelect');
const reviewText = document.getElementById('reviewText');
const giveButton = document.getElementById('giveButton');
const createItemName = document.getElementById('createItemName');
const createItemLabel = document.getElementById('createItemLabel');
const createItemType = document.getElementById('createItemType');
const createItemWeight = document.getElementById('createItemWeight');
const createItemImage = document.getElementById('createItemImage');
const createItemUnique = document.getElementById('createItemUnique');
const createItemUseable = document.getElementById('createItemUseable');
const createItemShouldClose = document.getElementById('createItemShouldClose');
const createItemDescription = document.getElementById('createItemDescription');
const createItemButton = document.getElementById('createItemButton');
const deleteItemButton = document.getElementById('deleteItemButton');
const refreshButton = document.getElementById('refreshButton');
const openCreateItemButton = document.getElementById('openCreateItemButton');
const closeButton = document.getElementById('closeButton');
const targetTabs = Array.from(document.querySelectorAll('.target-tab'));
const navTabs = Array.from(document.querySelectorAll('.nav-tab'));
const itemsDock = document.getElementById('itemsDock');
const recipesDock = document.getElementById('recipesDock');
const shopsDock = document.getElementById('shopsDock');
const playersDock = document.getElementById('playersDock');
const propsDock = document.getElementById('propsDock');
const detailModal = document.getElementById('detailModal');
const detailBackdrop = document.getElementById('detailBackdrop');
const detailCloseButton = document.getElementById('detailCloseButton');
const detailTitle = document.getElementById('detailTitle');
const createItemModal = document.getElementById('createItemModal');
const createItemBackdrop = document.getElementById('createItemBackdrop');
const createItemCloseButton = document.getElementById('createItemCloseButton');
const createShopModal = document.getElementById('createShopModal');
const createShopBackdrop = document.getElementById('createShopBackdrop');
const createShopCloseButton = document.getElementById('createShopCloseButton');
const shopLabel = document.getElementById('shopLabel');
const shopMeta = document.getElementById('shopMeta');
const shopCoords = document.getElementById('shopCoords');
const teleportToShopNpcButton = document.getElementById('teleportToShopNpcButton');
const moveShopNpcButton = document.getElementById('moveShopNpcButton');
const deleteShopNpcButton = document.getElementById('deleteShopNpcButton');
const shopItemName = document.getElementById('shopItemName');
const shopItemPrice = document.getElementById('shopItemPrice');
const shopItemCount = document.getElementById('shopItemCount');
const shopItemCurrency = document.getElementById('shopItemCurrency');
const shopItemLicense = document.getElementById('shopItemLicense');
const shopItemGrade = document.getElementById('shopItemGrade');
const shopItemMetadata = document.getElementById('shopItemMetadata');
const shopReviewText = document.getElementById('shopReviewText');
const openShopAddProductButton = document.getElementById('openShopAddProductButton');
const saveShopProductButton = document.getElementById('saveShopProductButton');
const deleteShopProductButton = document.getElementById('deleteShopProductButton');
const createShopKey = document.getElementById('createShopKey');
const createShopLabel = document.getElementById('createShopLabel');
const createShopButton = document.getElementById('createShopButton');
const adminSelectedPlayerLabel = document.getElementById('adminSelectedPlayerLabel');
const adminSelectedPlayerMeta = document.getElementById('adminSelectedPlayerMeta');
const adminSelectedPlayerDescription = document.getElementById('adminSelectedPlayerDescription');
const playerArmorInput = document.getElementById('playerArmorInput');
const playerReviewText = document.getElementById('playerReviewText');
const healPlayerButton = document.getElementById('healPlayerButton');
const teleportToPlayerButton = document.getElementById('teleportToPlayerButton');
const teleportPlayerToMeButton = document.getElementById('teleportPlayerToMeButton');
const setPlayerArmorButton = document.getElementById('setPlayerArmorButton');
const vehicleModelInput = document.getElementById('vehicleModelInput');
const vehiclePlateInput = document.getElementById('vehiclePlateInput');
const spawnVehicleButton = document.getElementById('spawnVehicleButton');
const spectateButton = document.getElementById('spectateButton');
const unspectateButton = document.getElementById('unspectateButton');
const viewInventoryButton = document.getElementById('viewInventoryButton');
const playerInventoryBlock = document.getElementById('playerInventoryBlock');
const playerInventoryList = document.getElementById('playerInventoryList');
const playerHealthInput = document.getElementById('playerHealthInput');
const setPlayerHealthButton = document.getElementById('setPlayerHealthButton');
const propLabel = document.getElementById('propLabel');
const propMeta = document.getElementById('propMeta');
const propCoords = document.getElementById('propCoords');
const propReviewText = document.getElementById('propReviewText');
const teleportToPropButton = document.getElementById('teleportToPropButton');
const deletePropButton = document.getElementById('deletePropButton');
const recipeLabel = document.getElementById('recipeLabel');
const recipeMeta = document.getElementById('recipeMeta');
const recipeBlueprintInfo = document.getElementById('recipeBlueprintInfo');
const recipeReviewText = document.getElementById('recipeReviewText');
const recipeKeyInput = document.getElementById('recipeKeyInput');
const recipeItemInput = document.getElementById('recipeItemInput');
const recipeLabelInput = document.getElementById('recipeLabelInput');
const recipeAmountInput = document.getElementById('recipeAmountInput');
const recipeDurationInput = document.getElementById('recipeDurationInput');
const recipeImageInput = document.getElementById('recipeImageInput');
const recipeDescriptionInput = document.getElementById('recipeDescriptionInput');
const recipeIngredientsInput = document.getElementById('recipeIngredientsInput');
const recipeMetadataInput = document.getElementById('recipeMetadataInput');
const recipeBlueprintItemInput = document.getElementById('recipeBlueprintItemInput');
const recipeBlueprintLabelInput = document.getElementById('recipeBlueprintLabelInput');
const recipeBlueprintImageInput = document.getElementById('recipeBlueprintImageInput');
const recipeBlueprintAutoCreateInput = document.getElementById('recipeBlueprintAutoCreateInput');
const saveRecipeButton = document.getElementById('saveRecipeButton');
const newRecipeButton = document.getElementById('newRecipeButton');
const deleteRecipeButton = document.getElementById('deleteRecipeButton');

const resourceName = typeof GetParentResourceName === 'function' ? GetParentResourceName() : 'codex_adminitemoverlay';

const state = {
    open: false,
    view: 'items',
    items: [],
    shops: [],
    players: [],
    props: [],
    recipes: [],
    limits: {
        maxAmount: 1000,
        defaultNearbyDistance: 10,
        maxNearbyDistance: 50,
    },
    imageBase: '',
    selectedItem: null,
    selectedShopKey: '',
    selectedShopLocationIndex: 0,
    selectedShopProductIndex: null,
    selectedAdminPlayerId: null,
    selectedPropId: null,
    selectedRecipeKey: null,
    search: '',
    category: 'all',
    target: 'self',
    detailOpen: false,
    createItemOpen: false,
    createShopOpen: false,
};

let saveToastTimeout = null;

function post(endpoint, payload = {}) {
    return fetch(`https://${resourceName}/${endpoint}`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify(payload),
    });
}

function showSavedToast(text = 'Gespeichert') {
    if (!saveToast) return;

    saveToast.textContent = text;
    saveToast.classList.remove('hidden');

    if (saveToastTimeout) {
        clearTimeout(saveToastTimeout);
    }

    saveToastTimeout = window.setTimeout(() => {
        saveToast.classList.add('hidden');
    }, 1800);
}

function normalize(value) {
    return String(value || '').toLowerCase();
}

function prettifyCategory(category) {
    if (category === 'all') return 'Alle';
    if (category === 'item') return 'Items';
    if (category === 'weapon') return 'Waffen';
    if (category === 'ammo' || category === 'muni') return 'Muni';
    return category;
}

function getCardClass(item) {
    const type = normalize(item.type);
    if (type.includes('weapon')) return 'weapon';
    if (type.includes('ammo')) return 'ammo';
    return 'item';
}

function getVisualText(item) {
    const label = item.label || item.name || '?';
    const words = label.split(/\s+/).filter(Boolean);
    if (words.length >= 2) return `${words[0][0] || ''}${words[1][0] || ''}`.toUpperCase();
    return label.slice(0, 2).toUpperCase();
}

function getImageUrl(item) {
    if (!state.imageBase || !item || !item.image) return '';
    return `${state.imageBase}${item.image}`;
}

function getCategories() {
    const unique = new Set(['all']);
    for (const item of state.items) unique.add(normalize(item.type || 'item'));
    return Array.from(unique);
}

function getSelectedShop() {
    return state.shops.find((shop) => shop.key === state.selectedShopKey) || null;
}

function getFilteredItems() {
    const query = normalize(state.search);
    return state.items.filter((item) => {
        const matchesCategory = state.category === 'all' || normalize(item.type) === state.category;
        const matchesSearch = !query || normalize(item.label).includes(query) || normalize(item.name).includes(query);
        return matchesCategory && matchesSearch;
    });
}

function getFilteredShopProducts() {
    const shop = getSelectedShop();
    const query = normalize(state.search);
    if (!shop) return [];
    return (shop.products || []).filter((product) => {
        return !query || normalize(product.label).includes(query) || normalize(product.name).includes(query);
    });
}

function getFilteredPlayers() {
    const query = normalize(state.search);
    return state.players.filter((player) => {
        return !query
            || normalize(player.name).includes(query)
            || normalize(player.citizenid).includes(query)
            || String(player.id).includes(query);
    });
}

function getSelectedProp() {
    return state.props.find((prop) => Number(prop.id) === Number(state.selectedPropId)) || null;
}

function getFilteredProps() {
    const query = normalize(state.search);
    return state.props.filter((prop) => {
        return !query
            || normalize(prop.label).includes(query)
            || normalize(prop.type).includes(query)
            || String(prop.id).includes(query);
    });
}

function getSelectedRecipe() {
    return state.recipes.find((recipe) => String(recipe.key) === String(state.selectedRecipeKey)) || null;
}

function getFilteredRecipes() {
    const query = normalize(state.search);
    return state.recipes.filter((recipe) => {
        return !query
            || normalize(recipe.label).includes(query)
            || normalize(recipe.item).includes(query)
            || normalize(recipe.key).includes(query)
            || normalize(recipe.blueprintItem).includes(query);
    });
}

function renderRecipeItemOptions() {
    const previousValue = recipeItemInput.value;
    recipeItemInput.innerHTML = '';

    const placeholder = document.createElement('option');
    placeholder.value = '';
    placeholder.textContent = 'Item auswaehlen';
    recipeItemInput.appendChild(placeholder);

    for (const item of state.items) {
        const option = document.createElement('option');
        option.value = item.name;
        option.textContent = `${item.label} (${item.name})`;
        recipeItemInput.appendChild(option);
    }

    if (previousValue && state.items.find((item) => item.name === previousValue)) {
        recipeItemInput.value = previousValue;
    }
}

function resetRecipeEditor() {
    recipeKeyInput.value = '';
    recipeItemInput.value = '';
    recipeLabelInput.value = '';
    recipeAmountInput.value = '1';
    recipeDurationInput.value = '5000';
    recipeImageInput.value = '';
    recipeDescriptionInput.value = '';
    recipeIngredientsInput.value = '{}';
    recipeMetadataInput.value = '{}';
    recipeBlueprintItemInput.value = '';
    recipeBlueprintLabelInput.value = '';
    recipeBlueprintImageInput.value = '';
    recipeBlueprintAutoCreateInput.value = 'yes';
    state.selectedRecipeKey = null;
}

function fillRecipeEditor(recipe) {
    if (!recipe) {
        resetRecipeEditor();
        return;
    }

    recipeKeyInput.value = recipe.key || '';
    recipeItemInput.value = recipe.item || '';
    recipeLabelInput.value = recipe.label || '';
    recipeAmountInput.value = String(Number(recipe.amount || 1));
    recipeDurationInput.value = String(Number(recipe.duration || 5000));
    recipeImageInput.value = recipe.image || '';
    recipeDescriptionInput.value = recipe.description || '';
    recipeIngredientsInput.value = JSON.stringify(recipe.ingredients || {}, null, 2);
    recipeMetadataInput.value = JSON.stringify(recipe.metadata || {}, null, 2);
    recipeBlueprintItemInput.value = recipe.blueprintItem || '';
    recipeBlueprintLabelInput.value = recipe.blueprintLabel || '';
    recipeBlueprintImageInput.value = '';
    recipeBlueprintAutoCreateInput.value = 'yes';
}

function renderPlayers() {
    playerSelect.innerHTML = '';
    adminPlayerSelect.innerHTML = '';

    for (const player of state.players) {
        const option = document.createElement('option');
        option.value = String(player.id);
        option.textContent = `${player.id} - ${player.name}`;
        playerSelect.appendChild(option);

        const adminOption = document.createElement('option');
        adminOption.value = String(player.id);
        adminOption.textContent = `${player.id} - ${player.name}`;
        adminPlayerSelect.appendChild(adminOption);
    }

    if (state.selectedAdminPlayerId != null) {
        adminPlayerSelect.value = String(state.selectedAdminPlayerId);
    }
}

function renderCategories() {
    categoryFilters.innerHTML = '';
    for (const category of getCategories()) {
        const button = document.createElement('button');
        button.type = 'button';
        button.className = `chip${state.category === category ? ' active' : ''}`;
        button.textContent = prettifyCategory(category);
        button.addEventListener('click', () => {
            state.category = category;
            renderCategories();
            renderCatalog();
        });
        categoryFilters.appendChild(button);
    }
}

function renderItemOptions() {
    const previousValue = shopItemName.value;
    shopItemName.innerHTML = '';

    const placeholder = document.createElement('option');
    placeholder.value = '';
    placeholder.textContent = 'Item auswaehlen';
    shopItemName.appendChild(placeholder);

    for (const item of state.items) {
        const option = document.createElement('option');
        option.value = item.name;
        option.textContent = `${item.label} (${item.name})`;
        shopItemName.appendChild(option);
    }

    if (previousValue && state.items.find((item) => item.name === previousValue)) {
        shopItemName.value = previousValue;
    }
}

function upsertCreatedItem(item) {
    if (!item || !item.name) return;

    const normalizedItem = {
        name: String(item.name).toLowerCase(),
        label: item.label || item.name,
        type: item.type || 'item',
        description: item.description || '',
        weight: Number(item.weight || 0),
        unique: item.unique === true,
        image: item.image || `${String(item.name).toLowerCase()}.png`,
        isCustom: item.isCustom === true,
    };

    const existingIndex = state.items.findIndex((entry) => entry.name === normalizedItem.name);
    if (existingIndex >= 0) {
        state.items[existingIndex] = normalizedItem;
    } else {
        state.items.push(normalizedItem);
    }

    state.items.sort((a, b) => String(a.label).localeCompare(String(b.label), 'de'));
    state.selectedItem = normalizedItem;
    state.search = '';
    state.category = 'all';
    searchInput.value = '';
    renderCategories();
    renderItemOptions();
    renderCatalog();
    openDetailModal();
    closeCreateItemModal();
}

function renderShopSelect() {
    shopSelect.innerHTML = '';
    for (const shop of state.shops) {
        const option = document.createElement('option');
        option.value = shop.key;
        option.textContent = `${shop.label} (${shop.key})`;
        shopSelect.appendChild(option);
    }
    if (state.selectedShopKey) {
        shopSelect.value = state.selectedShopKey;
    }
}

function renderShopLocationSelect() {
    const shop = getSelectedShop();
    shopLocationSelect.innerHTML = '';

    if (!shop || !Array.isArray(shop.locations) || shop.locations.length === 0) {
        const option = document.createElement('option');
        option.value = '0';
        option.textContent = 'Kein NPC';
        shopLocationSelect.appendChild(option);
        shopLocationSelect.disabled = true;
        state.selectedShopLocationIndex = 0;
        return;
    }

    shopLocationSelect.disabled = false;

    shop.locations.forEach((location, index) => {
        const option = document.createElement('option');
        option.value = String(index);
        option.textContent = `NPC ${index + 1} - ${location.x.toFixed(1)}, ${location.y.toFixed(1)}, ${location.z.toFixed(1)}`;
        shopLocationSelect.appendChild(option);
    });

    const safeIndex = Math.max(0, Math.min(state.selectedShopLocationIndex || 0, shop.locations.length - 1));
    state.selectedShopLocationIndex = safeIndex;
    shopLocationSelect.value = String(safeIndex);
}

function getSelectedAdminPlayer() {
    return state.players.find((player) => Number(player.id) === Number(state.selectedAdminPlayerId)) || null;
}

function getDetailTitle() {
    if (state.view === 'items') {
        return state.selectedItem ? state.selectedItem.label : 'Item Auswahl';
    }

    if (state.view === 'recipes') {
        const recipe = getSelectedRecipe();
        return recipe ? (recipe.label || recipe.key) : 'Rezept Editor';
    }

    if (state.view === 'players') {
        const player = getSelectedAdminPlayer();
        return player ? player.name : 'Spieler Auswahl';
    }

    if (state.view === 'props') {
        const prop = getSelectedProp();
        return prop ? (prop.label || `Prop ${prop.id}`) : 'Prop Auswahl';
    }

    const shop = getSelectedShop();
    return shop ? shop.label : 'Shop Auswahl';
}

function updateDetailVisibility() {
    detailModal.classList.toggle('hidden', !state.detailOpen);
    detailTitle.textContent = getDetailTitle();
}

function openDetailModal() {
    state.detailOpen = true;
    updateDetailVisibility();
}

function closeDetailModal() {
    state.detailOpen = false;
    updateDetailVisibility();
}

function updateCreateItemVisibility() {
    createItemModal.classList.toggle('hidden', !state.createItemOpen);
}

function openCreateItemModal() {
    state.createItemOpen = true;
    updateCreateItemVisibility();
    window.setTimeout(() => createItemName.focus(), 50);
}

function closeCreateItemModal() {
    state.createItemOpen = false;
    updateCreateItemVisibility();
}

function updateCreateShopVisibility() {
    createShopModal.classList.toggle('hidden', !state.createShopOpen);
}

function openCreateShopModal() {
    state.createShopOpen = true;
    updateCreateShopVisibility();
    window.setTimeout(() => createShopKey.focus(), 50);
}

function closeCreateShopModal() {
    state.createShopOpen = false;
    updateCreateShopVisibility();
}

function renderPlayerSummary() {
    const player = getSelectedAdminPlayer();
    if (!player) {
        adminSelectedPlayerLabel.textContent = 'Kein Spieler ausgewaehlt';
        adminSelectedPlayerMeta.textContent = 'Waehle links einen Spieler aus.';
        adminSelectedPlayerDescription.textContent = '';
        playerReviewText.textContent = 'Waehle einen Spieler aus, um Admin-Aktionen auszufuehren.';
        audienceText.textContent = 'Spieler Verwaltung';
        return;
    }

    adminSelectedPlayerLabel.textContent = player.name;
    adminSelectedPlayerMeta.textContent = `ID ${player.id} - Ping ${player.ping} - ${player.citizenid || 'keine CitizenID'}`;
    adminSelectedPlayerDescription.textContent = `Lizenz: ${player.license || 'unbekannt'}`;
    playerReviewText.textContent = `Du kannst ${player.name} heilen, zu ihm teleportieren, ihn zu dir holen oder seine Ruestung setzen.`;
    audienceText.textContent = `Spieler Aktionen fuer ${player.name}`;
}

function togglePlayerInventoryBlock(show) {
    playerInventoryBlock.classList.toggle('hidden', !show);
}

async function spawnVehicleForPlayer() {
    const player = getSelectedAdminPlayer();
    if (!player) return showSavedToast('Kein Spieler ausgewaehlt');
    const model = vehicleModelInput.value.trim();
    const plate = vehiclePlateInput.value.trim();
    if (!model) return showSavedToast('Fahrzeugmodell fehlt');

    post('spawnVehicle', { model, plate, targetId: Number(player.id) });
}

async function spectatePlayer() {
    const player = getSelectedAdminPlayer();
    if (!player) return showSavedToast('Kein Spieler ausgewaehlt');
    post('spectatePlayer', { targetId: Number(player.id) });
}

async function unspectateLocal() {
    post('unspectatePlayer', {});
}

async function viewPlayerInventory() {
    const player = getSelectedAdminPlayer();
    if (!player) return showSavedToast('Kein Spieler ausgewaehlt');
    try {
        const response = await post('getPlayerInventory', { targetId: Number(player.id) });
        const result = await response.json().catch(() => ({}));
        if (result && result.ok && Array.isArray(result.inventory)) {
            const list = result.inventory.map((it) => `${it.name || it.item || it.label || 'unknown'} x${it.amount || it.count || 1}`).join('<br>') || 'Leer';
            playerInventoryList.innerHTML = list;
            togglePlayerInventoryBlock(true);
            return;
        }
        showSavedToast(result.message || 'Inventar konnte nicht geladen werden');
    } catch (error) {
        showSavedToast('Inventar-Anfrage fehlgeschlagen');
    }
}

function renderPropSummary() {
    const prop = getSelectedProp();
    if (!prop) {
        propLabel.textContent = 'Kein Prop ausgewaehlt';
        propMeta.textContent = 'Waehle links einen platzierten Prop aus.';
        propCoords.textContent = '';
        propReviewText.textContent = 'Hier siehst du alle platzierten Crafting-Props auf dem Server.';
        audienceText.textContent = 'Prop Verwaltung';
        return;
    }

    propLabel.textContent = prop.label || 'Crafting Prop';
    propMeta.textContent = `ID ${prop.id} - ${prop.type || 'prop'} - ${prop.adminOnly ? 'Admin only' : 'Normal'} - ${prop.model || 'model unbekannt'}`;
    propCoords.textContent = prop.coords
        ? `${prop.coords.x.toFixed(2)}, ${prop.coords.y.toFixed(2)}, ${prop.coords.z.toFixed(2)}`
        : 'Keine Koordinaten';
    propReviewText.textContent = `Du kannst zu ${prop.label || 'diesem Prop'} teleportieren oder ihn komplett vom Server entfernen.`;
    audienceText.textContent = `Prop Aktionen fuer ${prop.label || `Prop ${prop.id}`}`;
}

function renderRecipeSummary() {
    const recipe = getSelectedRecipe();
    if (!recipe) {
        recipeLabel.textContent = 'Neues Rezept';
        recipeMeta.textContent = 'Erstelle ein neues Rezept oder waehle links ein bestehendes aus.';
        recipeBlueprintInfo.textContent = '';
        recipeReviewText.textContent = 'Wenn ein Bauplan-Item gesetzt ist, erscheint das Rezept im Crafting erst dann, wenn dieser Bauplan im Tisch-Inventar liegt.';
        audienceText.textContent = 'Rezept Verwaltung';
        deleteRecipeButton.disabled = true;
        return;
    }

    recipeLabel.textContent = recipe.label || recipe.key || 'Rezept';
    recipeMeta.textContent = `${recipe.key} - ${recipe.item} - ${recipe.amount || 1}x - ${Math.floor((recipe.duration || 0) / 1000)}s`;
    recipeBlueprintInfo.textContent = recipe.blueprintItem
        ? `Bauplan: ${recipe.blueprintLabel || recipe.blueprintItem}`
        : 'Kein Bauplan erforderlich';
    recipeReviewText.textContent = recipe.blueprintItem
        ? `Dieses Rezept ist versteckt, bis ${recipe.blueprintLabel || recipe.blueprintItem} im Tisch-Inventar liegt.`
        : 'Dieses Rezept ist ohne Bauplan sichtbar.';
    audienceText.textContent = `Rezept Editor fuer ${recipe.label || recipe.key}`;
    deleteRecipeButton.disabled = false;
}

function renderRecipeCards(recipes) {
    itemsList.innerHTML = '';

    if (!recipes.length) {
        itemsList.innerHTML = '<div class="empty-state">Noch keine Rezepte vorhanden.</div>';
        return;
    }

    for (const recipe of recipes) {
        const button = document.createElement('button');
        button.type = 'button';
        button.className = `item-card item${String(state.selectedRecipeKey) === String(recipe.key) ? ' active' : ''}`;
        button.innerHTML = `
            <div class="item-visual">
                <img src="${getImageUrl(recipe)}" alt="${recipe.label || recipe.key}">
                <span class="item-fallback hidden">${getVisualText(recipe)}</span>
            </div>
            <strong>${recipe.label || recipe.key}</strong>
            <div class="item-name">${recipe.item}</div>
            <div class="item-description">${recipe.blueprintItem ? `Bauplan: ${recipe.blueprintLabel || recipe.blueprintItem}` : 'Ohne Bauplan'} | ${recipe.amount || 1}x Output</div>
            <div class="item-footer">
                <span>${Math.floor((recipe.duration || 0) / 1000)}s</span>
                <span class="item-tag">Rezept</span>
            </div>
        `;
        button.addEventListener('click', () => {
            state.selectedRecipeKey = recipe.key;
            fillRecipeEditor(recipe);
            renderCatalog();
            openDetailModal();
        });
        const image = button.querySelector('img');
        const fallback = button.querySelector('.item-fallback');
        if (image) {
            image.addEventListener('error', () => {
                image.style.display = 'none';
                fallback?.classList.remove('hidden');
            }, { once: true });
            image.addEventListener('load', () => {
                image.style.display = 'block';
                fallback?.classList.add('hidden');
            }, { once: true });
        }
        itemsList.appendChild(button);
    }
}

function renderPlayerCards(players) {
    itemsList.innerHTML = '';

    for (const player of players) {
        const button = document.createElement('button');
        button.type = 'button';
        button.className = `item-card item${Number(state.selectedAdminPlayerId) === Number(player.id) ? ' active' : ''}`;
        button.innerHTML = `
            <div class="item-visual">
                <span class="item-fallback">${String(player.name || '??').slice(0, 2).toUpperCase()}</span>
            </div>
            <strong>${player.name}</strong>
            <div class="item-name">ID ${player.id}</div>
            <div class="item-description">CitizenID: ${player.citizenid || 'keine'} | Ping: ${player.ping}</div>
            <div class="item-footer">
                <span>${player.license ? 'Verbunden' : 'Unbekannt'}</span>
                <span class="item-tag">Spieler</span>
            </div>
        `;
        button.addEventListener('click', () => {
            state.selectedAdminPlayerId = Number(player.id);
            adminPlayerSelect.value = String(player.id);
            renderCatalog();
            openDetailModal();
        });
        itemsList.appendChild(button);
    }
}

function renderPropCards(props) {
    itemsList.innerHTML = '';

    if (!props.length) {
        itemsList.innerHTML = '<div class="empty-state">Es wurden noch keine Crafting-Props auf dem Server platziert.</div>';
        return;
    }

    for (const prop of props) {
        const button = document.createElement('button');
        button.type = 'button';
        button.className = `item-card item${Number(state.selectedPropId) === Number(prop.id) ? ' active' : ''}`;
        button.innerHTML = `
            <div class="item-visual">
                <span class="item-fallback">PR</span>
            </div>
            <strong>${prop.label || 'Crafting Prop'}</strong>
            <div class="item-name">ID ${prop.id}</div>
            <div class="item-description">${prop.type || 'prop'} | ${prop.adminOnly ? 'Admin only' : 'Normal'} | ${prop.model || 'model unbekannt'}</div>
            <div class="item-footer">
                <span>${prop.coords ? `${prop.coords.x.toFixed(1)}, ${prop.coords.y.toFixed(1)}` : 'Keine Koordinaten'}</span>
                <span class="item-tag">Prop</span>
            </div>
        `;
        button.addEventListener('click', () => {
            state.selectedPropId = Number(prop.id);
            renderCatalog();
            openDetailModal();
        });
        itemsList.appendChild(button);
    }
}

function updateItemReview() {
    const item = state.selectedItem;
    const amount = Math.max(1, Math.floor(Number(amountInput.value || 1)));
    const radius = Math.max(1, Math.floor(Number(radiusInput.value || state.limits.defaultNearbyDistance || 10)));
    let targetText = 'an dich selbst gerichtet';

    if (state.target === 'player') {
        const current = state.players.find((player) => String(player.id) === playerSelect.value);
        targetText = current ? `an Spieler ${current.id} (${current.name}) gerichtet` : 'an einen Spieler gerichtet';
    } else if (state.target === 'all') {
        targetText = 'an alle Spieler gerichtet';
    } else if (state.target === 'nearby') {
        targetText = `an alle Spieler in ${radius}m Umkreis gerichtet`;
    }

    audienceText.textContent = `Items ${targetText}`;
    reviewText.textContent = item ? `${amount}x ${item.label} wird ${targetText}.` : 'Waehle ein Item aus, stelle die Menge ein und entscheide, wohin es gegeben werden soll.';
}

function renderItemSelection() {
    const item = state.selectedItem;
    if (!item) {
        selectedLabel.textContent = 'Noch kein Item ausgewaehlt';
        selectedMeta.textContent = 'Waehle links ein Item aus.';
        selectedDescription.textContent = '';
        selectedCount.textContent = 'Keine Auswahl';
        deleteItemButton.disabled = true;
        updateItemReview();
        return;
    }

    selectedLabel.textContent = item.label;
    selectedMeta.textContent = `${item.name} - ${prettifyCategory(normalize(item.type))} - ${item.weight || 0} Gewicht${item.isCustom ? ' - Custom' : ''}`;
    selectedDescription.textContent = item.description || 'Keine Beschreibung vorhanden.';
    selectedCount.textContent = item.name;
    deleteItemButton.disabled = item.isCustom !== true;
    updateItemReview();
}

function renderItemCards(items) {
    itemsList.innerHTML = '';
    for (const item of items) {
        const button = document.createElement('button');
        const cardClass = getCardClass(item);
        button.type = 'button';
        button.className = `item-card ${cardClass}${state.selectedItem && state.selectedItem.name === item.name ? ' active' : ''}`;
        button.innerHTML = `
            <div class="item-visual">
                <img src="${getImageUrl(item)}" alt="${item.label}" loading="lazy">
                <span class="item-fallback hidden">${getVisualText(item)}</span>
            </div>
            <strong>${item.label}</strong>
            <div class="item-name">${item.name}</div>
            <div class="item-description">${item.description || 'Keine Beschreibung vorhanden.'}</div>
            <div class="item-footer">
                <span>${item.weight || 0}g</span>
                <span class="item-tag">${prettifyCategory(normalize(item.type))}</span>
            </div>
        `;
        button.addEventListener('click', () => {
            state.selectedItem = item;
            renderItemSelection();
            renderCatalog();
            openDetailModal();
        });
        const image = button.querySelector('img');
        const fallback = button.querySelector('.item-fallback');
        if (image) {
            image.addEventListener('error', () => {
                image.style.display = 'none';
                fallback?.classList.remove('hidden');
            }, { once: true });
            image.addEventListener('load', () => {
                image.style.display = 'block';
                fallback?.classList.add('hidden');
            }, { once: true });
        }
        itemsList.appendChild(button);
    }
}

function renderShopSummary() {
    const shop = getSelectedShop();
    if (!shop) {
        shopLabel.textContent = 'Kein Shop ausgewaehlt';
        shopMeta.textContent = 'Waehle oben einen Shop aus.';
        shopCoords.textContent = '';
        shopReviewText.textContent = 'Waehle einen Shop und danach ein Produkt oder trage ein neues Item ein.';
        return;
    }

    shopLabel.textContent = shop.label;
    shopMeta.textContent = `${shop.key} - ${shop.products.length} Produkte`;
    const currentLocation = Array.isArray(shop.locations) && shop.locations[state.selectedShopLocationIndex]
        ? shop.locations[state.selectedShopLocationIndex]
        : shop.coords;
    shopCoords.textContent = currentLocation ? `NPC ${state.selectedShopLocationIndex + 1}: ${currentLocation.x.toFixed(2)}, ${currentLocation.y.toFixed(2)}, ${currentLocation.z.toFixed(2)}` : 'Keine feste Position';

    if (state.selectedShopProductIndex == null) {
        shopReviewText.textContent = 'Neues Produkt anlegen oder ein vorhandenes Produkt links auswaehlen.';
    } else {
        const product = shop.products[state.selectedShopProductIndex];
        shopReviewText.textContent = product ? `Bearbeite ${product.label} in ${shop.label}.` : 'Neues Produkt anlegen oder ein vorhandenes Produkt links auswaehlen.';
    }

    audienceText.textContent = `Shop Editor fuer ${shop.label}`;
}

function fillShopEditor(product) {
    if (!product) {
        shopItemName.value = '';
        shopItemPrice.value = '0';
        shopItemCount.value = '1';
        shopItemCurrency.value = 'legal';
        shopItemLicense.value = 'no';
        shopItemGrade.value = '';
        shopItemMetadata.value = 'no';
        return;
    }

    shopItemName.value = product.name || '';
    shopItemPrice.value = product.price ?? 0;
    shopItemCount.value = product.amount ?? 0;
    shopItemCurrency.value = product.currency === 'Market_money' ? 'iligal' : 'legal';
    shopItemLicense.value = product.license ? 'yes' : 'no';
    shopItemGrade.value = product.grade ?? '';
    shopItemMetadata.value = product.metadata ? 'yes' : 'no';
}

function renderShopCards(products) {
    itemsList.innerHTML = '';
    for (const product of products) {
        const button = document.createElement('button');
        const cardClass = getCardClass(product);
        const active = state.selectedShopProductIndex === product.index - 1;
        button.type = 'button';
        button.className = `item-card ${cardClass}${active ? ' active' : ''}`;
        button.innerHTML = `
            <div class="item-visual">
                <img src="${getImageUrl(product)}" alt="${product.label}" loading="lazy">
                <span class="item-fallback hidden">${getVisualText(product)}</span>
            </div>
            <strong>${product.label}</strong>
            <div class="item-name">${product.name}</div>
            <div class="item-description">Preis: ${product.price} | Lager: ${product.amount === 0 ? 'Unendlich' : product.amount}${product.currency ? ` | ${product.currency}` : ''}</div>
            <div class="item-footer">
                <span>${product.license || product.grade != null ? 'Restriktionen aktiv' : 'Standard'}</span>
                <span class="item-tag">${prettifyCategory(normalize(product.type))}</span>
            </div>
        `;
        button.addEventListener('click', () => {
            state.selectedShopProductIndex = product.index - 1;
            fillShopEditor(product);
            renderShopSummary();
            renderCatalog();
            openDetailModal();
        });
        const image = button.querySelector('img');
        const fallback = button.querySelector('.item-fallback');
        if (image) {
            image.addEventListener('error', () => {
                image.style.display = 'none';
                fallback?.classList.remove('hidden');
            }, { once: true });
            image.addEventListener('load', () => {
                image.style.display = 'block';
                fallback?.classList.add('hidden');
            }, { once: true });
        }
        itemsList.appendChild(button);
    }
}

function renderCatalog() {
    if (state.view === 'items') {
        const filteredItems = getFilteredItems();
        resultsCount.textContent = `${filteredItems.length} Items`;
        if (!state.selectedItem && filteredItems.length) state.selectedItem = filteredItems[0];
        renderItemCards(filteredItems);
        renderItemSelection();
        updateDetailVisibility();
        return;
    }

    if (state.view === 'recipes') {
        const filteredRecipes = getFilteredRecipes();
        resultsCount.textContent = `${filteredRecipes.length} Rezepte`;
        selectedCount.textContent = state.selectedRecipeKey ? state.selectedRecipeKey : 'Kein Rezept';
        if (state.selectedRecipeKey == null && filteredRecipes.length) {
            state.selectedRecipeKey = filteredRecipes[0].key;
            fillRecipeEditor(filteredRecipes[0]);
        }
        renderRecipeCards(filteredRecipes);
        renderRecipeSummary();
        updateDetailVisibility();
        return;
    }

    if (state.view === 'players') {
        const filteredPlayers = getFilteredPlayers();
        resultsCount.textContent = `${filteredPlayers.length} Spieler`;
        selectedCount.textContent = state.selectedAdminPlayerId != null ? `ID ${state.selectedAdminPlayerId}` : 'Kein Spieler';
        if (state.selectedAdminPlayerId == null && filteredPlayers.length) {
            state.selectedAdminPlayerId = Number(filteredPlayers[0].id);
            adminPlayerSelect.value = String(filteredPlayers[0].id);
        }
        renderPlayerCards(filteredPlayers);
        renderPlayerSummary();
        updateDetailVisibility();
        return;
    }

    if (state.view === 'props') {
        const filteredProps = getFilteredProps();
        resultsCount.textContent = `${filteredProps.length} Props`;
        selectedCount.textContent = state.selectedPropId != null ? `ID ${state.selectedPropId}` : 'Kein Prop';
        if (state.selectedPropId == null && filteredProps.length) {
            state.selectedPropId = Number(filteredProps[0].id);
        }
        renderPropCards(filteredProps);
        renderPropSummary();
        updateDetailVisibility();
        return;
    }

    const filteredProducts = getFilteredShopProducts();
    resultsCount.textContent = `${filteredProducts.length} Shop-Produkte`;
    selectedCount.textContent = state.selectedShopKey || 'Kein Shop';
    renderShopLocationSelect();
    renderShopCards(filteredProducts);
    renderShopSummary();
    updateDetailVisibility();
}

function setView(view) {
    state.view = view;
    closeDetailModal();
    for (const tab of navTabs) {
        tab.classList.toggle('active', tab.dataset.view === view);
    }
    itemFiltersBlock.classList.toggle('hidden', view !== 'items');
    playerFiltersBlock.classList.toggle('hidden', view !== 'players');
    shopFiltersBlock.classList.toggle('hidden', view !== 'shops');
    itemsDock.classList.toggle('hidden', view !== 'items');
    recipesDock.classList.toggle('hidden', view !== 'recipes');
    playersDock.classList.toggle('hidden', view !== 'players');
    shopsDock.classList.toggle('hidden', view !== 'shops');
    propsDock.classList.toggle('hidden', view !== 'props');
    openCreateItemButton.textContent = view === 'recipes' ? 'Rezept erstellen' : 'Item erstellen';
    openCreateItemButton.classList.toggle('hidden', view !== 'items' && view !== 'recipes');
    renderCatalog();
}

function updateTargetUi() {
    for (const tab of targetTabs) {
        tab.classList.toggle('active', tab.dataset.target === state.target);
    }
    playerWrapper.classList.toggle('hidden', state.target !== 'player');
    radiusWrapper.classList.toggle('hidden', state.target !== 'nearby');
    updateItemReview();
}

function applyPayload(payload) {
    state.items = Array.isArray(payload.items) ? payload.items : [];
    state.shops = Array.isArray(payload.shops) ? payload.shops : [];
    state.players = Array.isArray(payload.players) ? payload.players : [];
    state.props = Array.isArray(payload.props) ? payload.props : [];
    state.recipes = Array.isArray(payload.recipes) ? payload.recipes : [];
    state.limits = payload.limits || state.limits;
    state.imageBase = payload.meta?.imageBase || '';

    if (!state.selectedShopKey && state.shops.length) {
        state.selectedShopKey = state.shops[0].key;
    }
    if (state.selectedAdminPlayerId == null && state.players.length) {
        state.selectedAdminPlayerId = Number(state.players[0].id);
    }
    if (state.selectedPropId != null && !state.props.find((prop) => Number(prop.id) === Number(state.selectedPropId))) {
        state.selectedPropId = null;
    }
    if (state.selectedPropId == null && state.props.length) {
        state.selectedPropId = Number(state.props[0].id);
    }
    if (state.selectedRecipeKey != null && !state.recipes.find((recipe) => String(recipe.key) === String(state.selectedRecipeKey))) {
        state.selectedRecipeKey = null;
    }
    if (state.selectedRecipeKey == null && state.recipes.length) {
        state.selectedRecipeKey = state.recipes[0].key;
        fillRecipeEditor(state.recipes[0]);
    }

    title.textContent = payload.meta?.title || 'Admin Overlay';
    subtitle.textContent = payload.meta?.subtitle || 'Items und Shops direkt im Overlay verwalten';
    amountInput.max = String(state.limits.maxAmount || 1000);
    radiusInput.value = String(state.limits.defaultNearbyDistance || 10);
    radiusInput.max = String(state.limits.maxNearbyDistance || 50);

    renderPlayers();
    renderCategories();
    renderItemOptions();
    renderRecipeItemOptions();
    if (state.selectedRecipeKey) {
        fillRecipeEditor(getSelectedRecipe());
    }
    renderShopSelect();
    renderShopLocationSelect();
    renderCatalog();
    updateTargetUi();
    updateDetailVisibility();
    updateCreateItemVisibility();
    updateCreateShopVisibility();
}

async function executePlayerAction(action, extra = {}) {
    const player = getSelectedAdminPlayer();
    if (!player) {
        showSavedToast('Kein Spieler ausgewaehlt');
        return;
    }

    const response = await post('playerAction', {
        action,
        targetId: Number(player.id),
        ...extra,
    });

    const result = await response.json().catch(() => ({}));
    if (result && result.message) {
        showSavedToast(result.message);
    }
}

async function executePropAction(action) {
    const prop = getSelectedProp();
    if (!prop) {
        showSavedToast('Kein Prop ausgewaehlt');
        return;
    }

    if (action === 'goto') {
        if (!prop.coords) {
            showSavedToast('Keine Position fuer diesen Prop gefunden');
            return;
        }

        try {
            const response = await post('teleportShop', {
                coords: prop.coords,
                message: `Zu ${prop.label || 'Prop'} teleportiert`,
            });
            const result = await response.json().catch(() => ({}));
            showSavedToast(result.message || 'Teleportiert');
        } catch (error) {
            showSavedToast('Teleport fehlgeschlagen');
        }
        return;
    }

    try {
        const response = await post('propAction', {
            action,
            propId: Number(prop.id),
        });
        const result = await response.json().catch(() => ({}));
        if (result && result.message) {
            showSavedToast(result.message);
            return;
        }
        showSavedToast('Aktion ausgefuehrt');
    } catch (error) {
        showSavedToast('Prop-Aktion fehlgeschlagen');
    }
}

function openOverlay(payload) {
    state.open = true;
    document.documentElement.classList.remove('nui-hidden');
    document.documentElement.classList.add('nui-visible');
    document.body.classList.remove('nui-hidden');
    document.body.classList.add('nui-visible');
    app.classList.remove('hidden');
    searchInput.value = state.search;
    applyPayload(payload);
    window.setTimeout(() => searchInput.focus(), 50);
}

function closeOverlay() {
    state.open = false;
    closeDetailModal();
    closeCreateItemModal();
    closeCreateShopModal();
    app.classList.add('hidden');
    document.documentElement.classList.remove('nui-visible');
    document.documentElement.classList.add('nui-hidden');
    document.body.classList.remove('nui-visible');
    document.body.classList.add('nui-hidden');
}

function submitGive() {
    if (!state.selectedItem) return;
    const amount = Math.floor(Number(amountInput.value || 1));
    if (!amount || amount < 1) return;

    const payload = {
        itemName: state.selectedItem.name,
        amount,
        giveType: state.target,
    };

    if (state.target === 'player') payload.targetId = Number(playerSelect.value || 0);
    if (state.target === 'nearby') {
        payload.radius = Math.min(Number(state.limits.maxNearbyDistance || 50), Math.max(1, Number(radiusInput.value || state.limits.defaultNearbyDistance || 10)));
    }

    post('giveItem', payload);
}

function resetCreateItemForm() {
    createItemName.value = '';
    createItemLabel.value = '';
    createItemType.value = 'item';
    createItemWeight.value = '0';
    createItemImage.value = '';
    createItemUnique.value = 'no';
    createItemUseable.value = 'no';
    createItemShouldClose.value = 'yes';
    createItemDescription.value = '';
}

async function createItem() {
    const itemName = createItemName.value.trim().toLowerCase();
    const label = createItemLabel.value.trim();

    if (!itemName || !label) {
        showSavedToast('Item Name und Label fehlen');
        return;
    }

    createItemButton.disabled = true;

    try {
        const response = await post('createItem', {
            name: itemName,
            label,
            type: createItemType.value,
            weight: Number(createItemWeight.value || 0),
            image: createItemImage.value.trim(),
            unique: createItemUnique.value === 'yes',
            useable: createItemUseable.value === 'yes',
            shouldClose: createItemShouldClose.value === 'yes',
            description: createItemDescription.value.trim(),
        });

        const result = await response.json().catch(() => ({}));

        if (result && result.message) {
            showSavedToast(result.message);
        } else {
            showSavedToast('Item Anfrage gesendet');
        }

        if (result && result.ok) {
            if (result.item) {
                upsertCreatedItem(result.item);
            }
            resetCreateItemForm();
        }
    } finally {
        window.setTimeout(() => {
            createItemButton.disabled = false;
        }, 350);
    }
}

async function deleteItem() {
    if (!state.selectedItem || state.selectedItem.isCustom !== true) {
        showSavedToast('Nur eigene Items koennen geloescht werden');
        return;
    }

    deleteItemButton.disabled = true;

    try {
        const response = await post('deleteItem', {
            name: state.selectedItem.name,
        });

        const result = await response.json().catch(() => ({}));

        if (result && result.message) {
            showSavedToast(result.message);
        }

        if (result && result.ok) {
            state.items = state.items.filter((item) => item.name !== state.selectedItem.name);
            state.selectedItem = state.items[0] || null;
            state.search = '';
            state.category = 'all';
            searchInput.value = '';
            renderCategories();
            renderItemOptions();
            renderCatalog();
        }
    } finally {
        window.setTimeout(() => {
            deleteItemButton.disabled = state.selectedItem?.isCustom !== true;
        }, 350);
    }
}

function openNewRecipeEditor() {
    resetRecipeEditor();
    renderCatalog();
    openDetailModal();
}

async function saveRecipe() {
    let ingredients;
    let metadata;

    try {
        ingredients = JSON.parse(recipeIngredientsInput.value || '{}');
    } catch (error) {
        showSavedToast('Zutaten JSON ist ungueltig');
        return;
    }

    try {
        metadata = recipeMetadataInput.value.trim() ? JSON.parse(recipeMetadataInput.value) : {};
    } catch (error) {
        showSavedToast('Metadata JSON ist ungueltig');
        return;
    }

    if (!recipeItemInput.value || !recipeLabelInput.value.trim()) {
        showSavedToast('Output Item und Label fehlen');
        return;
    }

    saveRecipeButton.disabled = true;

    try {
        const response = await post('saveRecipe', {
            key: recipeKeyInput.value.trim(),
            item: recipeItemInput.value.trim(),
            label: recipeLabelInput.value.trim(),
            amount: Number(recipeAmountInput.value || 1),
            duration: Number(recipeDurationInput.value || 5000),
            image: recipeImageInput.value.trim(),
            description: recipeDescriptionInput.value.trim(),
            ingredients,
            metadata,
            blueprintItem: recipeBlueprintItemInput.value.trim(),
            blueprintLabel: recipeBlueprintLabelInput.value.trim(),
            blueprintImage: recipeBlueprintImageInput.value.trim(),
            autoCreateBlueprint: recipeBlueprintAutoCreateInput.value === 'yes',
        });

        const result = await response.json().catch(() => ({}));
        if (result && result.message) {
            showSavedToast(result.message);
        }

        if (result && result.ok && result.recipe) {
            state.selectedRecipeKey = result.recipe.key;
        }
    } finally {
        window.setTimeout(() => {
            saveRecipeButton.disabled = false;
        }, 350);
    }
}

async function deleteRecipe() {
    const recipe = getSelectedRecipe();
    if (!recipe) {
        showSavedToast('Kein Rezept ausgewaehlt');
        return;
    }

    deleteRecipeButton.disabled = true;

    try {
        const response = await post('deleteRecipe', {
            key: recipe.key,
        });

        const result = await response.json().catch(() => ({}));
        if (result && result.message) {
            showSavedToast(result.message);
        }

        if (result && result.ok) {
            state.selectedRecipeKey = null;
            resetRecipeEditor();
        }
    } finally {
        window.setTimeout(() => {
            deleteRecipeButton.disabled = false;
        }, 350);
    }
}

function saveShopProduct() {
    if (!state.selectedShopKey) return;

    const payload = {
        shopKey: state.selectedShopKey,
        index: state.selectedShopProductIndex != null ? state.selectedShopProductIndex + 1 : null,
        product: {
            name: shopItemName.value.trim(),
            price: Number(shopItemPrice.value || 0),
            amount: Number(shopItemCount.value || 0),
            currency: shopItemCurrency.value === 'iligal' ? 'Market_money' : 'money',
            license: shopItemLicense.value === 'yes' ? 'weapon' : '',
            requiredGrade: shopItemGrade.value === '' ? null : Number(shopItemGrade.value),
            info: shopItemMetadata.value === 'yes' ? '{"registered": true}' : '',
        }
    };

    post('saveShopProduct', payload);
}

async function executeShopAction(action) {
    const shop = getSelectedShop();
    if (!shop) {
        showSavedToast('Kein Shop ausgewaehlt');
        return;
    }

    const selectedLocation = Array.isArray(shop.locations) && shop.locations[state.selectedShopLocationIndex]
        ? shop.locations[state.selectedShopLocationIndex]
        : null;

    if (action === 'goto_npc' || action === 'goto_shop') {
        const coords = action === 'goto_npc'
            ? selectedLocation
            : (shop.coords || selectedLocation);

        if (!coords) {
            showSavedToast('Keine Position fuer diesen Shop gefunden');
            return;
        }

        try {
            const response = await post('teleportShop', {
                coords,
                message: action === 'goto_npc'
                    ? `Zu NPC ${state.selectedShopLocationIndex + 1} teleportiert`
                    : `Zu ${shop.label} teleportiert`,
            });
            const result = await response.json().catch(() => ({}));
            showSavedToast(result.message || 'Teleportiert');
        } catch (error) {
            showSavedToast('Teleport fehlgeschlagen');
        }

        return;
    }

    if (action === 'move_npc_here' || action === 'delete_npc') {
        try {
            await post(action === 'move_npc_here' ? 'moveShopNpc' : 'deleteShopNpc', {
                shopKey: shop.key,
                locationIndex: state.selectedShopLocationIndex + 1,
            });
            showSavedToast(action === 'move_npc_here' ? 'NPC wird verschoben...' : 'NPC wird geloescht...');
        } catch (error) {
            showSavedToast('Shop-Aktion fehlgeschlagen');
        }

        return;
    }

    showSavedToast('Aktion wird ausgefuehrt...');

    try {
        const response = await post('shopAction', {
            action,
            shopKey: shop.key,
            locationIndex: state.selectedShopLocationIndex + 1,
        });

        const result = await response.json().catch(() => ({}));

        if (result && result.teleported) {
            showSavedToast(result.message || 'Teleportiert');
            return;
        }

        if (result && result.message) {
            showSavedToast(result.message);
            return;
        }

        showSavedToast('Keine Rueckmeldung vom Shop-Button');
    } catch (error) {
        showSavedToast('Shop-Aktion fehlgeschlagen');
    }
}

function openShopProductEditor() {
    if (!state.selectedShopKey) {
        showSavedToast('Kein Shop ausgewaehlt');
        return;
    }

    state.selectedShopProductIndex = null;
    fillShopEditor(null);
    renderShopSummary();
    updateDetailVisibility();
    openDetailModal();
}

function deleteShopProduct() {
    if (!state.selectedShopKey || state.selectedShopProductIndex == null) return;
    post('deleteShopProduct', {
        shopKey: state.selectedShopKey,
        index: state.selectedShopProductIndex + 1,
    });
}

function resetShopOverrides() {
    if (!state.selectedShopKey) return;
    post('resetShopOverrides', {
        shopKey: state.selectedShopKey,
    });
}

function createShop() {
    const shopKey = createShopKey.value.trim();
    const label = createShopLabel.value.trim();
    if (!shopKey || !label) return;

    post('createShop', {
        shopKey,
        label,
    });
    closeCreateShopModal();
}

window.addEventListener('message', (event) => {
    const { action, data } = event.data || {};
    if (action === 'open') openOverlay(data || {});
    else if (action === 'update') applyPayload(data || {});
    else if (action === 'close') closeOverlay();
    else if (action === 'saved') showSavedToast(data?.message || 'Gespeichert');
});

searchInput.addEventListener('input', (event) => {
    state.search = event.target.value || '';
    renderCatalog();
});

shopSelect.addEventListener('change', () => {
    state.selectedShopKey = shopSelect.value;
    state.selectedShopLocationIndex = 0;
    state.selectedShopProductIndex = null;
    fillShopEditor(null);
    renderCatalog();
});

shopLocationSelect.addEventListener('change', () => {
    state.selectedShopLocationIndex = Number(shopLocationSelect.value || 0) || 0;
    renderShopSummary();
});

adminPlayerSelect.addEventListener('change', () => {
    state.selectedAdminPlayerId = Number(adminPlayerSelect.value || 0) || null;
    renderCatalog();
    openDetailModal();
});

amountInput.addEventListener('input', updateItemReview);
radiusInput.addEventListener('input', updateItemReview);
playerSelect.addEventListener('change', updateItemReview);

for (const tab of targetTabs) {
    tab.addEventListener('click', () => {
        state.target = tab.dataset.target;
        updateTargetUi();
    });
}

for (const tab of navTabs) {
    tab.addEventListener('click', () => setView(tab.dataset.view));
}

giveButton.addEventListener('click', submitGive);
createItemButton.addEventListener('click', createItem);
deleteItemButton.addEventListener('click', deleteItem);
openShopAddProductButton.addEventListener('click', openShopProductEditor);
saveShopProductButton.addEventListener('click', saveShopProduct);
deleteShopProductButton.addEventListener('click', deleteShopProduct);
teleportToShopNpcButton.addEventListener('click', () => executeShopAction('goto_npc'));
teleportToShopMarkerButton.addEventListener('click', () => executeShopAction('goto_shop'));
moveShopNpcButton.addEventListener('click', () => executeShopAction('move_npc_here'));
deleteShopNpcButton.addEventListener('click', () => executeShopAction('delete_npc'));
createShopButton.addEventListener('click', createShop);
healPlayerButton.addEventListener('click', () => executePlayerAction('heal'));
teleportToPlayerButton.addEventListener('click', () => executePlayerAction('goto'));
teleportPlayerToMeButton.addEventListener('click', () => executePlayerAction('bring'));
setPlayerArmorButton.addEventListener('click', () => executePlayerAction('set_armor', {
    armor: Number(playerArmorInput.value || 0),
}));
teleportToPropButton.addEventListener('click', () => executePropAction('goto'));
deletePropButton.addEventListener('click', () => executePropAction('delete'));
saveRecipeButton.addEventListener('click', saveRecipe);
newRecipeButton.addEventListener('click', openNewRecipeEditor);
deleteRecipeButton.addEventListener('click', deleteRecipe);
refreshButton.addEventListener('click', () => post('refresh'));
openCreateItemButton.addEventListener('click', () => {
    if (state.view === 'recipes') {
        openNewRecipeEditor();
        return;
    }

    openCreateItemModal();
});
openCreateShopButton.addEventListener('click', openCreateShopModal);
closeButton.addEventListener('click', () => post('close'));
detailBackdrop.addEventListener('click', closeDetailModal);
detailCloseButton.addEventListener('click', closeDetailModal);
createItemBackdrop.addEventListener('click', closeCreateItemModal);
createItemCloseButton.addEventListener('click', closeCreateItemModal);
createShopBackdrop.addEventListener('click', closeCreateShopModal);
createShopCloseButton.addEventListener('click', closeCreateShopModal);

spawnVehicleButton.addEventListener('click', spawnVehicleForPlayer);
spectateButton.addEventListener('click', spectatePlayer);
unspectateButton.addEventListener('click', unspectateLocal);
viewInventoryButton.addEventListener('click', viewPlayerInventory);
setPlayerHealthButton.addEventListener('click', () => {
    const health = Number(playerHealthInput.value || 0);
    if (!health || health < 1) return showSavedToast('Ungueltiger HP-Wert');
    executePlayerAction('set_health', { health });
});

window.addEventListener('keydown', (event) => {
    if (!state.open) return;
    if (event.key === 'Escape') {
        if (state.createShopOpen) {
            closeCreateShopModal();
            return;
        }

        if (state.createItemOpen) {
            closeCreateItemModal();
            return;
        }

        if (state.detailOpen) {
            closeDetailModal();
            return;
        }

        post('close');
    }
});
