/**
 * Apple Shop Configuration Logic
 * Mirrors the complex state interactions on the Buy iPhone 17 Pro page.
 */

document.addEventListener('DOMContentLoaded', () => {

    // --- State Management ---
    const State = {
        model: '17pro',
        color: 'natural_titanium',
        storage: '128gb',
        tradeIn: 'no',
        payment: 'full'
    };

    // --- Pricing Data Map (Mimicking Apple's Pricing Matrix) ---
    const Pricing = {
        '17pro': {
            base: 999,
            monthly: 41.62,
            storageOffsets: { '128gb': 0, '256gb': 100, '512gb': 300, '1tb': 500 }
        },
        '17promax': {
            base: 1199,
            monthly: 49.95,
            storageOffsets: { '256gb': 0, '512gb': 200, '1tb': 400 } // Note: Pro Max starts at 256GB
        }
    };

    // --- Image Data Map (Mimicking Apple's CDN Image Switching) ---
    const Images = {
        '17pro': {
            'natural_titanium': 'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/iphone-17-pro-model-unselect-gallery-2-202409?wid=5120&hei=3280&fmt=webp&qlt=70&.v=1729215089307',
            'desert_titanium': 'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/iphone-17-pro-desert-titanium-select?wid=940&hei=1112&fmt=png-alpha&.v=1728522332824',
            'white_titanium': 'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/iphone-17-pro-white-titanium-select?wid=940&hei=1112&fmt=png-alpha&.v=1728522332824',
            'black_titanium': 'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/iphone-17-pro-black-titanium-select?wid=940&hei=1112&fmt=png-alpha&.v=1728522332824'
        },
        '17promax': {
            'natural_titanium': 'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/iphone-17-pro-max-natural-titanium-select?wid=940&hei=1112&fmt=png-alpha&.v=1728522332824',
            'desert_titanium': 'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/iphone-17-pro-max-desert-titanium-select?wid=940&hei=1112&fmt=png-alpha&.v=1728522332824',
            'white_titanium': 'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/iphone-17-pro-max-white-titanium-select?wid=940&hei=1112&fmt=png-alpha&.v=1728522332824',
            'black_titanium': 'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/iphone-17-pro-max-black-titanium-select?wid=940&hei=1112&fmt=png-alpha&.v=1728522332824'
        }
    };

    // Formatting utility
    const formatCurrency = (amount) => {
        return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(amount);
    };

    const formatColorName = (val) => {
        return val.split('_').map(word => word.charAt(0).toUpperCase() + word.slice(1)).join(' ');
    };

    // --- Core UI Update Logic ---
    function updateUI() {
        // 1. Calculate Prices
        const modelData = Pricing[State.model];
        
        // Handle constraint: Pro Max starts at 256GB. If user had 128GB selected but switches to Pro Max, bump to 256GB automatically.
        if (State.model === '17promax' && State.storage === '128gb') {
            State.storage = '256gb';
            document.querySelector('input[name="storage"][value="256gb"]').checked = true;
            // Visually update the radio selections
            document.querySelectorAll('input[name="storage"]').forEach(radio => {
                const box = radio.closest('.radio-box');
                if (box) radio.checked ? box.classList.add('selected') : box.classList.remove('selected');
            });
        }

        const offset = modelData.storageOffsets[State.storage] || 0;
        const totalPrice = modelData.base + offset;
        const monthlyPrice = (totalPrice / 24).toFixed(2); // Approximate 24mo financing

        // 2. Update Dynamic Storage Options (Disable 128GB for Pro Max UI)
        const storage128Option = document.querySelector('input[name="storage"][value="128gb"]').closest('.radio-box');
        if (State.model === '17promax') {
            storage128Option.style.display = 'none';
        } else {
            storage128Option.style.display = 'block';
        }

        // 3. Update Storage Prices in the UI Grid dynamically
        Object.keys(modelData.storageOffsets).forEach(storageKey => {
            const storageOffset = modelData.storageOffsets[storageKey];
            const optionPrice = modelData.base + storageOffset;
            const optionMonthly = (optionPrice / 24).toFixed(2);
            
            const radioEl = document.querySelector(`input[name="storage"][value="${storageKey}"]`);
            if (radioEl) {
                const priceContainer = radioEl.closest('.radio-box').querySelector('.price');
                if (priceContainer) {
                    priceContainer.innerHTML = `From $${optionPrice}<br>or $${optionMonthly}/mo. for 24 mo.*`;
                }
            }
        });

        // 4. Update the Gallery Image
        const imageElement = document.getElementById('primary-product-image');
        if (imageElement && Images[State.model] && Images[State.model][State.color]) {
            // Add a slight fade effect by resetting opacity
            imageElement.style.opacity = 0.5;
            setTimeout(() => {
                imageElement.src = Images[State.model][State.color];
                imageElement.style.opacity = 1;
                imageElement.style.transition = "opacity 0.3s ease-in-out";
            }, 50);
        }

        // 5. Update The Final Summary Box
        const modelText = State.model === '17pro' ? 'iPhone 17 Pro' : 'iPhone 17 Pro Max';
        const storageText = State.storage.toUpperCase();
        const colorText = formatColorName(State.color);
        
        document.querySelector('.summary-spec').textContent = `${modelText} ${storageText} ${colorText}`;
        
        // Update Payment Box Logic
        const paymentBoxPayFull = document.querySelector('input[name="payment"][value="full"]').closest('.radio-box');
        if (paymentBoxPayFull) {
            paymentBoxPayFull.querySelector('.price').textContent = formatCurrency(totalPrice);
        }

        // Final Cart Display
        if (State.payment === 'full') {
            document.querySelector('.summary-price').textContent = formatCurrency(totalPrice);
        } else {
            document.querySelector('.summary-price').textContent = `$${monthlyPrice}/mo. for 24 mo.*`;
        }
    }

    // --- Event Listeners ---
    
    // Listen to Radio Box Clicks (Model, Storage, TradeIn, Payment)
    const radioBoxes = document.querySelectorAll('.radio-box input[type="radio"]');
    radioBoxes.forEach(radio => {
        radio.addEventListener('change', (e) => {
            const groupName = e.target.getAttribute('name');
            const value = e.target.value;

            // Update visual selection borders
            document.querySelectorAll(`input[name="${groupName}"]`).forEach(sibling => {
                const box = sibling.closest('.radio-box');
                if(box) box.classList.remove('selected');
            });
            e.target.closest('.radio-box').classList.add('selected');

            // Update State
            State[groupName] = value;
            
            // Trigger recalculations
            updateUI();
        });
    });

    // Listen to Color Swatch Clicks
    const colorSwatches = document.querySelectorAll('.color-swatch input');
    const colorNameLabel = document.getElementById('color-name');
    colorSwatches.forEach(swatch => {
        swatch.addEventListener('change', (e) => {
            const value = e.target.value;

            // Visual ring selection update
            document.querySelectorAll('.color-swatch').forEach(s => s.classList.remove('selected'));
            e.target.closest('.color-swatch').classList.add('selected');
            
            // Update Label text next to "Color."
            colorNameLabel.textContent = `- ${formatColorName(value)}`;

            // Update State
            State.color = value;

            // Trigger recalculations
            updateUI();
        });
    });

    // Initialize UI on load
    updateUI();
});
