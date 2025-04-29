// Scroll-triggered animation
const observer = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      entry.target.classList.add('visible');
    }
  });
}, {
  threshold: 0.15
});
document.querySelectorAll('.privacy-card').forEach(el => observer.observe(el));

// Sticky header
window.addEventListener('scroll', () => {
  const header = document.querySelector('header');
  if (window.scrollY > 50) {
    header.classList.add('scrolled');
  } else {
    header.classList.remove('scrolled');
  }
});

// Mobile nav toggle
const navToggle = document.querySelector('.mobile-nav-toggle');
const navList = document.querySelector('nav ul');
navToggle.addEventListener('click', () => {
  navList.classList.toggle('active');
});
document.querySelectorAll('nav a').forEach(link => {
  link.addEventListener('click', () => {
    navList.classList.remove('active');
  });
});

// Load footer
fetch("../html/footer.html?v=1.0.0")
  .then(res => res.text())
  .then(html => {
    document.getElementById("footer-placeholder").innerHTML = html;
});