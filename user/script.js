// script.js - Apple iPhone Clone Interactivity

document.addEventListener("DOMContentLoaded", () => {
    
    // Smooth scroll for chapter navigation
    const chapterNav = document.querySelector('.chapter-nav');
    
    // Intersection Observer for scroll animations
    const observerOptions = {
        root: null,
        rootMargin: '0px',
        threshold: 0.1
    };

    const observer = new IntersectionObserver((entries, observer) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('visible');
                // observer.unobserve(entry.target); // Unobserve if we only want it to trigger once
            }
        });
    }, observerOptions);

    // Apply fade-in animation to bento cards
    const bentoCards = document.querySelectorAll('.bento-card');
    bentoCards.forEach(card => {
        card.style.opacity = '0';
        card.style.transform = 'translateY(20px)';
        card.style.transition = 'opacity 0.8s ease-out, transform 0.8s ease-out';
        observer.observe(card);
    });

    // Make elements visible when intersected
    const styleSheet = document.createElement("style");
    styleSheet.innerText = `
        .visible {
            opacity: 1 !important;
            transform: translateY(0) !important;
        }
    `;
    document.head.appendChild(styleSheet);


    // Dynamic Chapter Nav resizing on scroll
    let lastScrollTop = 0;
    window.addEventListener('scroll', () => {
        let st = window.pageYOffset || document.documentElement.scrollTop;
        if (st > 44) {
             chapterNav.style.paddingTop = '8px';
             chapterNav.style.paddingBottom = '8px';
             const imgs = chapterNav.querySelectorAll('.chapter-item img');
             imgs.forEach(img => img.style.height = '30px');
        } else {
             chapterNav.style.paddingTop = '12px';
             chapterNav.style.paddingBottom = '0';
             const imgs = chapterNav.querySelectorAll('.chapter-item img');
             imgs.forEach(img => img.style.height = '35px');
        }
        lastScrollTop = st;
    });

    console.log("Apple iPhone clone interactivity loaded.");
});
