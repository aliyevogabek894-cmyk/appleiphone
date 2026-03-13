// Admin Panel Interactions
document.addEventListener('DOMContentLoaded', () => {
    // Add hover effects or dynamic data loading here
    const navLinks = document.querySelectorAll('.nav-links a');
    
    // Simulate navigation click
    navLinks.forEach(link => {
        link.addEventListener('click', (e) => {
            e.preventDefault();
            
            // Remove active class from all
            document.querySelectorAll('.nav-links li').forEach(li => {
                li.classList.remove('active');
            });
            
            // Add active class to clicked
            link.parentElement.classList.add('active');
        });
    });

    // Add row hover interaction to tables
    const tableRows = document.querySelectorAll('.data-table tbody tr');
    tableRows.forEach(row => {
        row.addEventListener('mouseenter', () => {
            row.style.backgroundColor = 'rgba(0,0,0,0.02)';
            row.style.cursor = 'pointer';
        });
        row.addEventListener('mouseleave', () => {
            row.style.backgroundColor = 'transparent';
        });
    });

    console.log("Apple Admin Panel Loaded successfully.");
});
