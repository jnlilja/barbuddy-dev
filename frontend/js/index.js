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

  // Start typing after a short delay
  setTimeout(typewriter, 500);

  // Intersection Observer for animations
  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('visible');
      }
    });
  }, {
    threshold: 0.15
  });

  document.querySelectorAll('[data-animate]').forEach(el => {
    observer.observe(el);
  });

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

  // Close mobile menu when clicking a link
  document.querySelectorAll('nav a').forEach(link => {
    link.addEventListener('click', () => {
      navList.classList.remove('active');
    });
  });

  // Smooth scroll for internal links
  document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function(e) {
      e.preventDefault();

      const targetId = this.getAttribute('href');
      if (targetId === '#') return;

      const targetElement = document.querySelector(targetId);
      if (!targetElement) return;

      window.scrollTo({
        top: targetElement.offsetTop - 80,
        behavior: 'smooth'
      });
    });
  });