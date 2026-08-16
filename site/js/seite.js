(function(){
  var wurzel = document.documentElement;

  var knopfModus = document.getElementById('schalter-modus');
  var textModus  = knopfModus.querySelector('.schalter__text');
  function istDunkel(){
    var g = wurzel.getAttribute('data-theme');
    if (g) return g === 'dark';
    return window.matchMedia('(prefers-color-scheme: dark)').matches;
  }
  function zeigeModus(){
    var d = istDunkel();
    knopfModus.setAttribute('aria-pressed', String(d));
    textModus.textContent = d ? 'Hell' : 'Dunkel';
  }
  try{ var g = localStorage.getItem('sfh-modus'); if (g) wurzel.setAttribute('data-theme', g); }catch(e){}
  zeigeModus();
  knopfModus.addEventListener('click', function(){
    var neu = istDunkel() ? 'light' : 'dark';
    wurzel.setAttribute('data-theme', neu);
    try{ localStorage.setItem('sfh-modus', neu); }catch(e){}
    zeigeModus();
  });

  var knopfSprache = document.getElementById('schalter-sprache');
  var textSprache  = knopfSprache.querySelector('.schalter__text');
  function setzeSprache(w){
    wurzel.setAttribute('data-sprache', w);
    var l = w === 'leicht';
    knopfSprache.setAttribute('aria-pressed', String(l));
    textSprache.textContent = l ? 'Alltagssprache' : 'Leichte Sprache';
    try{ localStorage.setItem('sfh-sprache', w); }catch(e){}
  }
  var gs = 'standard';
  try{ gs = localStorage.getItem('sfh-sprache') || 'standard'; }catch(e){}
  setzeSprache(gs);
  knopfSprache.addEventListener('click', function(){
    setzeSprache(wurzel.getAttribute('data-sprache') === 'leicht' ? 'standard' : 'leicht');
  });
})();
