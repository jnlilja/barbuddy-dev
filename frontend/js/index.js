const notifyForm = document.querySelector('.notification-form');
const tagline = document.querySelector('.tagline');
const text = tagline.textContent;
tagline.textContent = '';

let i = 0;
function typewriter() {
  if (i < text.length) {
    tagline.textContent += text.charAt(i);
    i++;
    setTimeout(typewriter, 100);
  }
}
setTimeout(typewriter, 500);

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
document.querySelectorAll('[data-animate]').forEach(el => observer.observe(el));

// Sticky header
window.addEventListener('scroll', () => {
  const header = document.querySelector('header');
  if (window.scrollY > 100) {
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

// Smooth scroll
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
  anchor.addEventListener('click', function (e) {
    e.preventDefault();
    const targetId = this.getAttribute('href');
    if (!targetId || targetId === '#') return;
    const targetElement = document.querySelector(targetId);
    if (!targetElement) return;

    window.scrollTo({
      top: targetElement.offsetTop - 80,
      behavior: 'smooth'
    });
  });
});

// ✅ Toast logic
function showToast(message) {
  const toast = document.getElementById('notify-toast');
  if (!toast) return;
  toast.textContent = message;
  toast.classList.add('visible');
  setTimeout(() => {
    toast.classList.remove('visible');
  }, 3000);
}

// ✅ Form handling
if (notifyForm) {
  notifyForm.addEventListener('submit', function (e) {
    e.preventDefault();
    const emailInput = this.querySelector('.notification-input');
    const email = emailInput.value.trim();

    if (!validateEmail(email)) {
      showToast("Please enter a valid email address.");
      return;
    }

    showToast("Thanks! We'll notify you when we launch. 🎉");
    emailInput.value = '';
    // Later: send to backend via fetch()
  });
}

function validateEmail(email) {
  return /\S+@\S+\.\S+/.test(email);
}

fetch("/footer.html?v=1.0.0")
  .then(res => res.text())
  .then(html => {
    document.getElementById("footer-placeholder").innerHTML = html;
});
